# Verified p5.brush starting point

Acquired 2026-11-04 from the [upstream API reference](https://github.com/acamposuribe/p5.brush) and the npm manifests for [p5.brush 3.0.0](https://registry.npmjs.org/p5.brush/3.0.0) and [p5 2.3.4](https://registry.npmjs.org/p5/2.3.4). Recheck these for a new implementation rather than treating this date's latest versions as permanent.

This release of p5.brush peers on p5 `^2.2`. Its browser build is `dist/p5.brush.js`; p5's global browser build is `lib/p5.min.js`. Load p5 first, then p5.brush. The corresponding immutable CDN URLs are:

```html
<script src="https://cdn.jsdelivr.net/npm/p5@2.3.4/lib/p5.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/p5.brush@3.0.0/dist/p5.brush.js"></script>
```

Use a `WEBGL` canvas. In instance mode call `brush.instance(p)` before assigning `p.setup`/`p.draw`. Keep coordinates explicit; WEBGL's origin starts in the center. For an upper-left layout, translate by `(-width/2, -height/2)` before painting.

Verified API shapes:

```js
randomSeed(seed); noiseSeed(seed); // seeds p5.brush too
brush.scaleBrushes(3);           // tune to canvas size, call once
brush.noField();
brush.noHatch();
brush.noStroke();
brush.fill('#b1bea3', 85);       // watercolor, opacity 0..255
brush.fillBleed(0.25, 'out');   // strength 0..1
brush.fillTexture(0.6, 0.4, true, 0.25);
// granulation, pigment edge, scatter, pigment split
brush.polygon([[10,10], [210,12], [208,110], [11,108]]);
brush.noFill();
brush.set('rotring', '#34323e', 0.7);
brush.spline([[10,130,0.4], [65,145,1.2], [160,140,0.9], [210,160,0.4]], 0.55);
```

`brush.spline(points, curvature)` accepts `[x,y,pressure]` points, curvature `0..1`. `brush.line(x1,y1,x2,y2)` is also available. `brush.beginShape(curvature)`, `brush.vertex(x,y,pressure)`, `brush.endShape(true)` closes a shape.

The current API calls bleed `fillBleed`, and pressure paths may use `beginStroke`/`move`/`endStroke`. Do not assume the original prompt's `brush.bleed` or `brush.segment` exist. Use the documented methods of the selected release.

Paint a stable layer once; keep crisp text/interaction in a separate DOM or SVG overlay when that avoids repainting every watercolor shape per frame. Native canvas/SVG can supply grain, text, highlights or accessibility, while the material washes and ink wires still come from p5.brush. Avoid unbounded large canvases: browser texture limits and watercolor rendering time should inform the viewport/resolution.
