# Provenance

Inspected 2026-11-02: [shridharathi/visual-agent-chat](https://github.com/shridharathi/visual-agent-chat) at commit [b70fa83758fa30619aca3666bc519a9510beb068](https://github.com/shridharathi/visual-agent-chat/tree/b70fa83758fa30619aca3666bc519a9510beb068).

- [src/prompt.ts](https://github.com/shridharathi/visual-agent-chat/blob/b70fa83758fa30619aca3666bc519a9510beb068/src/prompt.ts) asks the model to select one of 34 shape names and emit scene/status markers.
- [public/index.html](https://github.com/shridharathi/visual-agent-chat/blob/b70fa83758fa30619aca3666bc519a9510beb068/public/index.html) contains signed-distance shape functions, extrusion, raymarching, morphing, and ordered dithering. It creates a WebGL2 canvas rather than calling an image-generation or vectorization service.
- The upstream README and shader comment attribute their dithering core to Paper Shaders under Apache-2.0; the repository itself had no top-level license file in the inspected tree. That statement does not establish a license for other upstream code.

This skill carries forward the mechanism—agent-selected visual metaphor, procedural solid, shaded dither cells, and transitions—but uses newly written shader geometry and artifact code. It does not bundle the upstream chat frontend or shader implementation. Teaching narration, persistent scene sequences, PNG export, and SVG cell-path export are new parts of this skill. No API model identifier, account configuration, or external service is embedded.
