#!/usr/bin/env node
// Export a built lesson through real Chromium/WebGL, without a web server.
'use strict';
const fs = require('node:fs/promises');
const path = require('node:path');
const { pathToFileURL } = require('node:url');
const { execFileSync } = require('node:child_process');

function loadPlaywright() {
  try { return require('playwright'); }
  catch (error) {
    if (error.code !== 'MODULE_NOT_FOUND') throw error;
    try {
      const root = execFileSync('npm', ['root', '-g'], { encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
      return require(path.join(root, 'playwright'));
    } catch {
      throw new Error('Playwright is unavailable. Install Playwright and its Chromium browser, or use the lesson’s PNG/SVG download buttons.');
    }
  }
}

async function main() {
  const [source, flag, destination, ...extra] = process.argv.slice(2);
  if (!source || flag !== '--output-dir' || !destination || extra.length) {
    throw new Error('Usage: node export_lesson.cjs <lesson.html> --output-dir <directory>');
  }
  const htmlPath = path.resolve(source), outputDir = path.resolve(destination);
  await fs.access(htmlPath);
  const { chromium } = loadPlaywright();
  const browser = await chromium.launch({ headless: true, args: ['--enable-unsafe-swiftshader', '--use-angle=swiftshader'] });
  try {
    const page = await browser.newPage({ viewport: { width: 760, height: 560 }, reducedMotion: 'reduce' });
    const failures = [];
    page.on('pageerror', error => failures.push(error.message));
    // The compiled artifact is offline. Refuse unexpected remote loads during export.
    await page.route(/^https?:/, route => route.abort());
    await page.goto(pathToFileURL(htmlPath).href, { waitUntil: 'load' });
    await page.waitForFunction(() => window.lessonArtifact?.ready || window.lessonArtifact?.error, null, { timeout: 30000 });
    const state = await page.evaluate(() => ({ ready: window.lessonArtifact.ready, error: window.lessonArtifact.error, count: window.lessonArtifact.lesson.scenes.length }));
    if (!state.ready) throw new Error(state.error);
    if (failures.length) throw new Error(failures.join('\n'));
    await fs.mkdir(outputDir, { recursive: true });
    const images = [];
    for (let i = 0; i < state.count; i++) {
      const artifact = await page.evaluate(index => {
        window.lessonArtifact.setScene(index);
        return window.lessonArtifact.snapshot({ poster: true });
      }, i);
      if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(artifact.id)) throw new Error('Unsafe scene id in artifact.');
      const png = path.join(outputDir, artifact.id + '.png'), svg = path.join(outputDir, artifact.id + '.svg');
      await fs.writeFile(png, Buffer.from(artifact.png, 'base64'));
      await fs.writeFile(svg, artifact.svg, 'utf8');
      images.push({ id: artifact.id, png, svg, dots: artifact.dots, width: artifact.width, height: artifact.height });
    }
    if (failures.length) throw new Error(failures.join('\n'));
    const result = { html: htmlPath, images };
    await fs.writeFile(path.join(outputDir, 'manifest.json'), JSON.stringify(result, null, 2) + '\n');
    process.stdout.write(JSON.stringify(result, null, 2) + '\n');
  } finally { await browser.close(); }
}

main().catch(error => { process.stderr.write('Cannot export lesson: ' + error.message + '\n'); process.exitCode = 1; });
