---
name: video-transcribe
description: Download a video from a URL (YouTube, Twitter/X, TikTok, or any yt-dlp supported source) and transcribe it locally with a Whisper model. Use when user drops a video link and wants a transcript, or says "transcribe this", "extract audio from", "get the transcript of".
metadata:
  version: "1.0"
  tags: whisper, transcription, video, youtube, twitter, tiktok, local
---

# Video Transcribe Skill

Transcribes any yt-dlp-supported video URL locally with a Whisper model. Nothing is sent to a
transcription service.

---

## Dependencies

| Tool | Location | Purpose |
|------|----------|---------|
| `yt-dlp` | `yt-dlp` on PATH | Download + extract audio |
| A local Whisper engine | on PATH | Local transcription |
| Model | `$WHISPER_MODEL_PATH` | A Whisper model in the engine's format |

Use whichever local engine the machine has: `whisperkit-cli` on Apple Silicon, `whisper-cli`
(whisper.cpp) elsewhere, or another Whisper runtime. Install what is missing with the machine's
own package manager.

---

## Procedure

### 1. Extract slug from URL
Use the last non-empty path segment of the URL as the filename slug.
- `https://www.tiktok.com/t/ZTkwgpy6v/` → slug = `ZTkwgpy6v`
- `https://youtu.be/dQw4w9WgXcQ` → slug = `dQw4w9WgXcQ`
- `https://twitter.com/i/status/123456` → slug = `123456`

### 2. Download audio
```bash
SLUG="<slug>"
yt-dlp --force-overwrites --no-part -x --audio-format wav -o "/tmp/${SLUG}.wav" "<URL>"
```

### 3. Transcribe
Run the local engine on the audio file with `$WHISPER_MODEL_PATH`. For example:

```bash
whisperkit-cli transcribe --audio-path /tmp/${SLUG}.wav --model-path $WHISPER_MODEL_PATH  # Apple Silicon
whisper-cli -m $WHISPER_MODEL_PATH -f /tmp/${SLUG}.wav                                     # whisper.cpp
```

### 4. Cleanup — REQUIRED after transcription
```bash
rm -f /tmp/${SLUG}.wav /tmp/${SLUG}.mp4 /tmp/${SLUG}.orig.wav
```

### 5. Output
- Drop the transcript directly in chat as an artifact
- Do NOT write to a file unless the user explicitly asks

---

## Notes

- Works with YouTube, Twitter/X, TikTok, Vimeo, and any yt-dlp-supported platform
- Runs fully offline after download — no API calls, no data leaves the machine
- Model: a Whisper large-v3-turbo model at `$WHISPER_MODEL_PATH`
- **Never** use a generic shared filename — always use the URL slug. Reusing `/tmp/transcript_audio.wav` causes silent cache poisoning across sessions.
- `--force-overwrites` and `--no-part` prevent yt-dlp from serving stale cached downloads
- Always delete all temp files after transcription — no audio or video artifacts should persist
