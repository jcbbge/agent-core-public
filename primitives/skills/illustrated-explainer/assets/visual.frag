#version 300 es
precision highp float;
precision highp int;

uniform vec2 uResolution;
uniform float uTime;
uniform float uYaw;
uniform float uPitch;
uniform int uFrom;
uniform int uTo;
uniform float uMix;
uniform vec3 uInk;
out vec4 outColor;

// Original procedural illustrations. No image assets or external shader source.
// Scene indices: 0 laptop, 1 book, 2 network, 3 stack, 4 branching path,
// 5 funnel, 6 lightbulb, 7 globe, 8 heart, 9 tree, 10 magnifier, 11 clock.
// All objects are lit and ordered-dithered, with rotation supplied in radians.
// uResolution is the actual cell-grid size, not the CSS display size.
// At uMix = 1 the destination illustration is fully formed.

const float PI = 3.141592653589793;

float disk(vec2 p, float radius) {
  return length(p) - radius;
}

float roundedBox(vec2 p, vec2 halfSize, float radius) {
  vec2 outside = abs(p) - halfSize + radius;
  return length(max(outside, 0.0)) + min(max(outside.x, outside.y), 0.0) - radius;
}

float stroke(vec2 p, vec2 start, vec2 end, float radius) {
  vec2 direction = end - start;
  float along = clamp(dot(p - start, direction) / dot(direction, direction), 0.0, 1.0);
  return length(p - start - along * direction) - radius;
}

float ring(vec2 p, float radius, float thickness) {
  return abs(length(p) - radius) - thickness;
}

float cross2(vec2 a, vec2 b) {
  return a.x * b.y - a.y * b.x;
}

float triangle(vec2 p, vec2 a, vec2 b, vec2 c) {
  float edgeDistance = min(stroke(p, a, b, 0.0),
    min(stroke(p, b, c, 0.0), stroke(p, c, a, 0.0)));
  vec3 sides = vec3(cross2(b - a, p - a), cross2(c - b, p - b), cross2(a - c, p - c));
  bool inside = all(greaterThanEqual(sides, vec3(0.0))) || all(lessThanEqual(sides, vec3(0.0)));
  return inside ? -edgeDistance : edgeDistance;
}

// Intersect normalized half-planes: a conservative distance for a trapezoid.
float taper(vec2 p, float bottomWidth, float topWidth, float halfHeight) {
  float slope = (topWidth - bottomWidth) / (2.0 * halfHeight);
  float widthAtHeight = 0.5 * (bottomWidth + topWidth) + slope * p.y;
  return max(abs(p.y) - halfHeight, (abs(p.x) - widthAtHeight) / sqrt(1.0 + slope * slope));
}

float illustration(int scene, vec2 p) {
  if (scene == 0) {
    // Laptop: a framed screen above a broad keyboard deck.
    float screen = roundedBox(p - vec2(0.0, 0.20), vec2(0.59, 0.40), 0.055);
    float opening = roundedBox(p - vec2(0.0, 0.20), vec2(0.50, 0.31), 0.025);
    float body = max(screen, -opening);
    float deck = taper(p - vec2(0.0, -0.32), 0.72, 0.55, 0.12);
    float touchpad = roundedBox(p - vec2(0.0, -0.33), vec2(0.16, 0.035), 0.015);
    body = min(body, max(deck, -touchpad));
    body = min(body, stroke(p, vec2(-0.29, 0.28), vec2(0.18, 0.28), 0.025));
    return min(body, stroke(p, vec2(-0.29, 0.12), vec2(0.01, 0.12), 0.025));
  }
  if (scene == 1) {
    // Open book, with a central gutter and three lines on each page.
    float pages = min(roundedBox(p - vec2(-0.33, 0.0), vec2(0.30, 0.48), 0.04),
      roundedBox(p - vec2(0.33, 0.0), vec2(0.30, 0.48), 0.04));
    for (int row = 0; row < 3; row++) {
      float y = 0.26 - float(row) * 0.18;
      float leftLine = stroke(p, vec2(-0.49, y), vec2(-0.16, y - 0.035), 0.021);
      float rightLine = stroke(p, vec2(0.16, y - 0.035), vec2(0.49, y), 0.021);
      pages = max(pages, -min(leftLine, rightLine));
    }
    return min(pages, roundedBox(p - vec2(0.0, -0.02), vec2(0.025, 0.51), 0.015));
  }
  if (scene == 2) {
    // Connected knowledge: six round nodes around a central hub.
    float network = disk(p, 0.18);
    for (int node = 0; node < 6; node++) {
      float angle = float(node) * PI / 3.0 + PI / 6.0;
      vec2 endpoint = 0.59 * vec2(cos(angle), sin(angle));
      network = min(network, stroke(p, vec2(0.0), endpoint, 0.034));
      network = min(network, disk(p - endpoint, 0.115));
    }
    return max(network, -disk(p, 0.075));
  }
  if (scene == 3) {
    // Three staggered blocks, each with an inset identifying mark.
    float stack = 10.0;
    for (int tier = 0; tier < 3; tier++) {
      vec2 center = vec2(tier == 1 ? 0.10 : -0.08, -0.39 + float(tier) * 0.37);
      float block = roundedBox(p - center, vec2(0.51, 0.155), 0.035);
      float label = stroke(p - center, vec2(-0.28, 0.0), vec2(0.08, 0.0), 0.022);
      stack = min(stack, max(block, -label));
    }
    return stack;
  }
  if (scene == 4) {
    // A shared trunk separates into three possible routes.
    vec2 junction = vec2(0.0, -0.12);
    float routes = stroke(p, vec2(0.0, -0.66), junction, 0.055);
    for (int branch = 0; branch < 3; branch++) {
      vec2 endpoint = vec2(float(branch - 1) * 0.54, branch == 1 ? 0.62 : 0.44);
      routes = min(routes, stroke(p, junction, endpoint, 0.045));
      routes = min(routes, disk(p - endpoint, 0.10));
    }
    return min(routes, disk(p - junction, 0.10));
  }
  if (scene == 5) {
    // Wide input narrows into a single output channel.
    float bowl = taper(p - vec2(0.0, 0.20), 0.14, 0.65, 0.29);
    float rim = stroke(p, vec2(-0.64, 0.51), vec2(0.64, 0.51), 0.045);
    float stem = roundedBox(p - vec2(0.0, -0.35), vec2(0.12, 0.28), 0.025);
    float mouth = stroke(p, vec2(-0.48, 0.39), vec2(0.48, 0.39), 0.025);
    return max(min(min(bowl, rim), stem), -mouth);
  }
  if (scene == 6) {
    // A lightbulb with a filament, screw base, and five short rays.
    vec2 bulbCenter = vec2(0.0, 0.12);
    float bulb = disk(p - bulbCenter, 0.36);
    bulb = min(bulb, roundedBox(p - vec2(0.0, -0.28), vec2(0.16, 0.14), 0.035));
    bulb = min(bulb, roundedBox(p - vec2(0.0, -0.48), vec2(0.13, 0.045), 0.025));
    float filament = min(stroke(p, vec2(-0.12, 0.15), vec2(0.0, -0.07), 0.023),
      stroke(p, vec2(0.0, -0.07), vec2(0.12, 0.15), 0.023));
    bulb = max(bulb, -filament);
    for (int ray = 0; ray < 5; ray++) {
      float angle = float(ray) * PI / 4.0;
      vec2 direction = vec2(cos(angle), sin(angle));
      bulb = min(bulb, stroke(p, bulbCenter + direction * 0.50, bulbCenter + direction * 0.65, 0.026));
    }
    return bulb;
  }
  if (scene == 7) {
    // Globe: boundary, latitude lines, and a narrow meridian ellipse.
    float globe = ring(p, 0.61, 0.035);
    float meridian = abs(length(p / vec2(0.30, 0.61)) - 1.0) * 0.30 - 0.022;
    float latitudes = min(abs(p.y), abs(abs(p.y) - 0.28)) - 0.022;
    globe = min(globe, max(disk(p, 0.61), min(meridian, latitudes)));
    return globe;
  }
  if (scene == 8) {
    // Heart built from two lobes and a pointed lower body.
    float lobes = min(disk(p - vec2(-0.22, 0.22), 0.32), disk(p - vec2(0.22, 0.22), 0.32));
    return min(lobes, triangle(p, vec2(-0.52, 0.20), vec2(0.52, 0.20), vec2(0.0, -0.61)));
  }
  if (scene == 9) {
    // A rounded tree canopy, visible trunk, and a small ground line.
    float canopy = min(disk(p - vec2(-0.29, 0.26), 0.30), disk(p - vec2(0.27, 0.30), 0.30));
    canopy = min(canopy, disk(p - vec2(0.0, 0.53), 0.29));
    float trunk = stroke(p, vec2(0.0, -0.63), vec2(0.0, 0.20), 0.075);
    trunk = min(trunk, stroke(p, vec2(0.0, -0.02), vec2(-0.25, 0.24), 0.045));
    trunk = min(trunk, stroke(p, vec2(0.0, 0.08), vec2(0.23, 0.34), 0.045));
    return min(min(canopy, trunk), stroke(p, vec2(-0.34, -0.66), vec2(0.34, -0.66), 0.03));
  }
  if (scene == 10) {
    // Magnifying glass with a substantial diagonal handle.
    float lens = ring(p - vec2(-0.12, 0.13), 0.39, 0.055);
    float handle = stroke(p, vec2(0.18, -0.17), vec2(0.60, -0.60), 0.082);
    return min(lens, handle);
  }
  // Clock is also the deterministic fallback for an invalid scene index.
  float clock = ring(p, 0.61, 0.05);
  clock = min(clock, stroke(p, vec2(0.0), vec2(0.0, 0.36), 0.038));
  clock = min(clock, stroke(p, vec2(0.0), vec2(0.27, -0.12), 0.045));
  clock = min(clock, disk(p, 0.065));
  for (int tick = 0; tick < 12; tick++) {
    float angle = float(tick) * PI / 6.0;
    vec2 location = 0.50 * vec2(cos(angle), sin(angle));
    clock = min(clock, disk(p - location, tick % 3 == 0 ? 0.029 : 0.018));
  }
  return clock;
}

float objectDistance(int scene, vec3 p) {
  float profile = illustration(scene, p.xy);
  // Rounded shallow extrusion; the added radius preserves the silhouette size.
  vec2 distances = vec2(profile + 0.018, abs(p.z) - 0.095 + 0.018);
  return min(max(distances.x, distances.y), 0.0) + length(max(distances, 0.0)) - 0.018;
}

vec3 objectCoordinates(vec3 p) {
  // Fixed camera tilt, then rotation around the object's upright axis.
  float y = cos(uPitch) * p.y - sin(uPitch) * p.z;
  float z = sin(uPitch) * p.y + cos(uPitch) * p.z;
  return vec3(cos(uYaw) * p.x - sin(uYaw) * z, y, sin(uYaw) * p.x + cos(uYaw) * z);
}

float sceneDistance(vec3 world) {
  vec3 p = objectCoordinates(world);
  float blend = clamp(uMix, 0.0, 1.0);
  if (blend <= 0.0 || uFrom == uTo) return objectDistance(uFrom, p);
  if (blend >= 1.0) return objectDistance(uTo, p);
  return mix(objectDistance(uFrom, p), objectDistance(uTo, p), blend);
}

vec3 surfaceNormal(vec3 p) {
  const float delta = 0.002;
  return normalize(vec3(
    sceneDistance(p + vec3(delta, 0.0, 0.0)) - sceneDistance(p - vec3(delta, 0.0, 0.0)),
    sceneDistance(p + vec3(0.0, delta, 0.0)) - sceneDistance(p - vec3(0.0, delta, 0.0)),
    sceneDistance(p + vec3(0.0, 0.0, delta)) - sceneDistance(p - vec3(0.0, 0.0, delta))));
}

// Bayer's recursive 2x2 ordering expanded to 4x4 using coordinate bits.
// Thresholds lie strictly between zero and one; zero coverage is transparent.
float ditherThreshold(ivec2 cell) {
  int x0 = cell.x & 1;
  int y0 = cell.y & 1;
  int x1 = (cell.x >> 1) & 1;
  int y1 = (cell.y >> 1) & 1;
  int rank = 4 * (2 * (x0 ^ y0) + y0) + 2 * (x1 ^ y1) + y1;
  return (float(rank) + 0.5) / 16.0;
}

void main() {
  vec2 resolution = max(uResolution, vec2(1.0));
  vec2 screen = (2.0 * gl_FragCoord.xy - resolution) / min(resolution.x, resolution.y);
  screen *= 0.98;
  outColor = vec4(0.0);

  // Orthographic camera. Every illustration fits inside this bounding sphere.
  const float bound = 1.05;
  float radialSquared = dot(screen, screen);
  if (radialSquared >= bound * bound) return;
  float halfChord = sqrt(bound * bound - radialSquared);
  vec3 origin = vec3(screen, 2.6);
  const vec3 direction = vec3(0.0, 0.0, -1.0);
  float travel = 2.6 - halfChord;
  float end = 2.6 + halfChord;
  bool hit = false;
  for (int step = 0; step < 80; step++) {
    float distanceToSurface = sceneDistance(origin + direction * travel);
    if (distanceToSurface < 0.0015) {
      hit = true;
      break;
    }
    travel += max(distanceToSurface * 0.78, 0.0005);
    if (travel > end) break;
  }
  if (!hit) return;

  vec3 normal = surfaceNormal(origin + direction * travel);
  vec3 light = normalize(vec3(-0.55, 0.75, 1.0));
  float diffuse = max(dot(normal, light), 0.0);
  float coverage = clamp(0.31 + 0.63 * (1.0 - diffuse), 0.0, 1.0);
  if (coverage >= ditherThreshold(ivec2(gl_FragCoord.xy))) outColor = vec4(uInk, 1.0);
}
