---
name: illustrated-explainer
description: Turn a topic, explanation, or ongoing discussion into a sequence of teaching points with supplemental metaphorical illustrations. Produce a standalone illustrated lesson and individual PNG/SVG artwork in a procedural dithered style, independent of a chat interface. Use for requests for picture-book-like explanations, visual teaching companions, or illustrations that unfold alongside narration.
---

# Illustrated explainer

Create a teaching companion: a point is explained, an illustration gives it a visual anchor, and the next point brings the next illustration. The agent chooses the metaphor. The user need not describe the objects.

## Teaching and art direction

- Ground the sequence in the user's topic and actual discussion. Use the intended audience and depth already given; otherwise start with an accessible explanation. Ask only when a missing detail would materially change the lesson.
- Give each scene one teaching point and a short narration. This narration can be read aloud by a person or another system; this skill does not synthesize speech.
- Choose an object or metaphor that reinforces that point. A model might be a computer; prediction might be a branching path; context might be an open book. These are examples, not a fixed mapping. Make consecutive illustrations meaningfully different when the concepts change.
- Illustrations are supplemental, so they need not literally depict an abstract subject. Keep the explanation accurate and make the metaphor's role clear in `visual`. Avoid a metaphor that implies a false mechanism or an unsupported claim.
- Describe motion treatments with motion-design terminology: turntable rotation, idle animation, and morph transitions. Choose the illustration's subject from the teaching point; a reference to a motion treatment does not prescribe an object to depict.
- Sequence the ideas, not the agent's tool calls or research status. An illustration of searching belongs to a lesson about searching, not merely to a web search happening in the background.
- For an ongoing discussion, illustrate the current point and append new scenes as new points arrive. Reuse the existing lesson JSON and stable scene IDs. Do not invent future conversation or silently replace earlier scenes.
- For a full-topic request, make a coherent short sequence with as many scenes as the explanation needs. Do not force a slide count or turn it into a comprehensive course.

## Make the artifact

Work in the user's chosen destination or a task-specific artifact directory. Resolve bundled paths relative to this `SKILL.md`; no absolute machine paths belong in portable invocations.

Write a UTF-8 lesson JSON file:

```json
{
  "title": "How language models continue text",
  "scenes": [
    {
      "id": "prediction",
      "title": "Many possible next steps",
      "narration": "A language model assigns probabilities to possible next tokens. A decoding method chooses the next token, and the process repeats.",
      "shape": "branch",
      "visual": "A branching path represents several possible continuations, rather than a machine knowing the future."
    }
  ]
}
```

Choose `shape` from `computer`, `book`, `network`, `blocks`, `branch`, `funnel`, `spark`, `globe`, `heart`, `tree`, `magnifier`, or `clock`. These shapes are starting points for metaphor, not an ontology of topics. If they cannot support a requested illustration, make a lesson-specific copy of `assets/visual.frag`, modify the relevant shape geometry, and pass it with `--shader`. Keep shared skill assets unchanged for individual lessons. Use a generated raster illustration instead only when the requested medium calls for it, and report that change of medium.

Set a scene's optional `motion` to `still` (a static pose, the default), `turn` (idle animation with oscillating rotation), or `spin` (a continuous 360° turntable animation). Choose restrained motion that supports the explanation. The reader can change modes or drag the object to choose an angle; focused illustrations also accept arrow keys. Reduced-motion preferences suppress automatic rotation. Built-in objects are shallow extrusions and show their thin sides when turned edge-on. Custom geometry intended for a turntable animation should have meaningful depth.

An optional scene `source` field accepts an HTTPS link supporting its factual teaching content. Verify factual material using the agent's normal research tools; the procedural renderer does not verify the explanation.

Build the self-contained lesson (Python standard library only):

```bash
python3 <skill-dir>/scripts/build_lesson.py <output-dir>/lesson.json --output <output-dir>/lesson.html
```

The HTML contains the narration, illustrated scenes, previous/next controls, optional timed playback, object motion controls, and PNG/SVG download buttons. It needs a WebGL2-capable browser; opening the file requires no server, chat app, login, or model API. Lesson playback waits for the reader to start it; requested scene motion starts when the scene appears. Motion pauses while the document is hidden or the illustration is offscreen. The narration remains readable if WebGL2 is unavailable, but illustration export cannot succeed without it.

Export one transparent PNG and one SVG per scene:

```bash
node <skill-dir>/scripts/export_lesson.cjs <output-dir>/lesson.html --output-dir <output-dir>/images
```

The exporter needs Playwright and its Chromium browser, installed locally or globally. Check availability before installation. If unavailable, keep the HTML artifact and explain that automatic image export is unverified; its browser download buttons are another route. Never claim missing exports exist. SVG export encodes the dither cells as vector paths, preserving the dot artwork; it does not recover editable semantic object outlines from pixels.

Animation lives in the HTML artifact. PNG and SVG exports are still frames: browser downloads preserve the chosen angle, while batch exports use a deterministic poster angle. Do not describe these image files as animated.

## Check and deliver

Inspect the rendered illustrations, not just the JSON. Check that the object is recognizable, the sequence advances correctly, the narration matches each visual, and exported images contain actual nonempty artwork. Keep a single scene when only one teaching point was requested.

Deliver the standalone HTML and the scene images, with a brief description of the chosen teaching sequence. Retain the JSON so another agent can extend the lesson. When the host supports inline HTML, show the finished sequence through its HTML preview/render tools; for use elsewhere, provide the PNG files and paths. Do not build a chat application around it.

Read [references/provenance.md](references/provenance.md) when tracing the upstream technique or explaining what was extracted and what was newly implemented.
