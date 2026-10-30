# Developer tools for Death-is_good

This project loads `dev_tools.tscn` once through the `DevTools` autoload. It contains only the FPS display, command console, error/debug log and gameplay recorder.

| Control | Action |
| --- | --- |
| Backtick / tilde | Open or close the console |
| F5 | Open or close the error/debug log |
| F6 | Start or stop lossless game recording |
| F8 | Show or hide the FPS display (bottom-right) |
| Escape | Close the console or log |

Opening the console or log pauses gameplay and preserves the previous pause and mouse state. The FPS display and recorder continue processing while paused. No player, movement, death, animation or level scripts were changed for this integration.

## Console commands

- `help`: list the enabled commands.
- `echo "message"`: print a message in the console.
- `log open`, `log export`, `log folder`: view engine/game events, export diagnostic logs, or open their export folder.
- `record start`, `record stop`, `record status`, `record folder`: control recording and locate clips.

Commands are editable resources in `default_commands.tres`. Remnant's gameplay commands (teleport, noclip, fly, scores, flags and Blackboard setters) are not installed. Neither the F1 issue reporter nor the F2/F3/F4 inspectors is installed. Shared context/adapter resources remain to support the three portable tools; their optional host hooks are unused.

Game code can write structured messages through:

```gdscript
DevTools.log_info("A gameplay event", "game")
DevTools.log_warning("An unexpected condition", "game")
DevTools.log_error("An operation failed", "game")
```

Godot engine output, warnings and errors are captured automatically by the native log sink. The tracker retains bounded per-session logs and offers a diagnostic ZIP export. It can preserve evidence from an interrupted session, but cannot guarantee capture of every native crash or forced termination.

## Local files and recorder setup

- Logs and exported ZIPs: `user://debug_logs/` (use `log folder` to open exports).
- Editor-run clips: `.recordings/<timestamp>/recording.mkv` plus `recording.json`.
- Exported-game clips: writable `user://recordings/` fallback.
- Recording uses native viewport resolution, lossless RGB H.264 video and stereo float PCM game audio at 60 FPS by default. Change `capture_fps` on the recorder node if needed.
- The first recording on Windows x86_64 automatically downloads and verifies a private FFmpeg copy if no encoder is available. It does not change PATH. Setup only runs when recording is requested. An explicit `ffmpeg_path` can select an installed encoder instead.
- Webcam/microphone input mode is disabled in this integration. Its helper remains a preload dependency of Remnant's recorder; no camera or microphone is opened by normal recording.
- Reports, clips, diagnostic exports and test profiles stay local. `.recordings/` and `.devtools-checks/` are ignored by Git.

## Provenance and changes — October 30, 2026

Portable console, logger, recorder and their required support files came from [CoolBeanGames/Remnant-GD](https://github.com/CoolBeanGames/Remnant-GD/tree/f560444bbdec3886b20c0d13987faac2c1104b4d/addons/dev_toolkit), revision `f560444bbdec3886b20c0d13987faac2c1104b4d`. That revision has no standalone FPS overlay; `fps_tracker.gd` is a small host addition. The scene and command catalog were narrowed to the requested systems. The recorder's optional input-mode key now explicitly ignores `KEY_NONE`, allowing that shortcut to stay disabled.

Tested with installed Godot 4.7.2. The host keeps its existing Forward+/D3D12 settings. No engine upgrade or gameplay configuration change was required.

## Verification

Run the focused integration check with:

```text
Godot --headless --path PROJECT --script res://Tests/dev_tools_test.gd
Godot --path PROJECT --script res://Tests/dev_tools_test.gd
```

Use a temporary APPDATA environment for these processes to isolate their user data. Rendered mode exercises the real recorder and may trigger its private FFmpeg setup. The test intentionally emits `DEVTOOLS_EXPECTED_WARNING` and `DEVTOOLS_EXPECTED_ERROR` to verify engine log capture; success is `DEVTOOLS_TEST: PASS` and exit code 0.

Verified command scope/dispatch, pause restoration and blocked movement while typing, native engine warning/error capture, diagnostic ZIP export, FPS text, and actual rendered recording. Rendered tests passed using both Compatibility/OpenGL and the game's Forward+/D3D12 renderer. A completed 1152×648, 15 FPS test clip contained lossless RGB H.264 and stereo 48 kHz PCM audio, and decoded successfully. Screenshots of gameplay, console and logger were visually reviewed. The normal recorder default remains 60 FPS.

The existing player animation interpolation warning is visible in the logger and remains unchanged. This is outside the requested developer-tool port.
