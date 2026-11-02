#!/usr/bin/env python3
"""Compile lesson data and a procedural illustration shader into offline HTML."""

import argparse
import json
from pathlib import Path
import re
import sys
from urllib.parse import urlsplit


SHAPES = [
    "computer", "book", "network", "blocks", "branch", "funnel",
    "spark", "globe", "heart", "tree", "magnifier", "clock",
]
SKILL_DIR = Path(__file__).resolve().parent.parent


def validate_lesson(value):
    if not isinstance(value, dict):
        raise ValueError("lesson must be a JSON object")
    if not isinstance(value.get("title"), str) or not value["title"].strip():
        raise ValueError("lesson.title must be nonempty text")
    scenes = value.get("scenes")
    if not isinstance(scenes, list) or not scenes:
        raise ValueError("lesson.scenes must be a nonempty array")
    seen = set()
    clean = {"title": value["title"], "scenes": []}
    for index, scene in enumerate(scenes):
        if not isinstance(scene, dict):
            raise ValueError(f"scene {index + 1} must be an object")
        for key in ("id", "title", "narration", "shape", "visual"):
            if not isinstance(scene.get(key), str) or not scene[key].strip():
                raise ValueError(f"scene {index + 1}.{key} must be nonempty text")
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", scene["id"]):
            raise ValueError(f"scene {index + 1}.id must use lowercase slug format")
        if scene["id"] in seen:
            raise ValueError(f"duplicate scene id: {scene['id']}")
        if scene["shape"] not in SHAPES:
            raise ValueError(f"unknown shape {scene['shape']!r}; choose from {', '.join(SHAPES)}")
        seen.add(scene["id"])
        result = {key: scene[key] for key in ("id", "title", "narration", "shape", "visual")}
        if "motion" in scene:
            if scene["motion"] not in ("still", "turn", "spin"):
                raise ValueError(f"scene {index + 1}.motion must be still, turn, or spin")
            result["motion"] = scene["motion"]
        if "source" in scene:
            source = scene["source"]
            if not isinstance(source, str) or urlsplit(source).scheme != "https" or not urlsplit(source).netloc:
                raise ValueError(f"scene {index + 1}.source must be an HTTPS URL")
            result["source"] = source
        clean["scenes"].append(result)
    return clean


def script_json(value):
    # JSON is embedded in a script element, whose closing tag the HTML parser sees.
    return json.dumps(value, ensure_ascii=True).replace("<", "\\u003c").replace(">", "\\u003e").replace("&", "\\u0026")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("lesson", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--shader", type=Path, default=SKILL_DIR / "assets" / "visual.frag")
    args = parser.parse_args()
    try:
        lesson = validate_lesson(json.loads(args.lesson.read_text(encoding="utf-8")))
        shader = args.shader.read_text(encoding="utf-8")
        template = (SKILL_DIR / "assets" / "lesson.html").read_text(encoding="utf-8")
        rendered = template.replace("__SHADER_JSON__", script_json(shader))
        rendered = rendered.replace("__SHAPES_JSON__", script_json(SHAPES))
        # Substitute lesson data last, so data cannot introduce another template marker.
        rendered = rendered.replace("__LESSON_JSON__", script_json(lesson))
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
        print(json.dumps({"html": str(args.output.resolve()), "scenes": len(lesson["scenes"])}))
    except (ValueError, OSError) as error:
        print(f"Cannot build lesson: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
