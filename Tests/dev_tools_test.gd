extends SceneTree
## Integration check: run with --script res://Tests/dev_tools_test.gd.
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)

func _run() -> void:
	var scene := load("res://Scenes/game.tscn") as PackedScene
	var game := scene.instantiate()
	root.add_child(game)
	current_scene = game
	await create_timer(0.25).timeout
	var context := root.get_node("DevTools") as DevToolsContext
	check(context.tools.size() == 3, "Only console, logger and recorder should be registered.")
	check(context.tool(&"reporter") == null and context.tool(&"inspector") == null, "Unrequested tools must be absent.")
	check(context.execute('echo "toolkit ready"') == "toolkit ready", "Console command dispatch failed.")
	var help := context.help_text()
	check("record" in help and "log" in help and not "noclip" in help and not "set score" in help, "Command catalog scope is wrong.")
	var avatar := get_first_node_in_group("player") as CharacterBody2D
	check(avatar != null, "Host player did not spawn.")
	var console := context.tool(&"console")
	console.open_console()
	await process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.devtools-checks/console.png")
	var position_before := avatar.global_position if avatar != null else Vector2.ZERO
	var event := InputEventAction.new()
	event.action = "right"
	event.pressed = true
	Input.parse_input_event(event)
	await create_timer(0.1).timeout
	check(paused and context.any_modal_open(), "Console should pause gameplay.")
	check(avatar == null or avatar.global_position == position_before, "Player moved while the console owned input.")
	event = InputEventAction.new()
	event.action = "right"
	event.pressed = false
	Input.parse_input_event(event)
	console.close_console()
	check(not paused and not context.any_modal_open(), "Console did not restore pause state.")
	var logger := context.tool(&"logger") as DevDebugLog
	logger.open_log()
	check(logger.is_open and paused, "Error log did not open as a modal.")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.devtools-checks/log.png")
	logger.close()
	push_warning("DEVTOOLS_EXPECTED_WARNING")
	push_error("DEVTOOLS_EXPECTED_ERROR")
	await process_frame
	var warning_found := false
	var error_found := false
	for entry in logger.get_entries():
		warning_found = warning_found or "DEVTOOLS_EXPECTED_WARNING" in str(entry)
		error_found = error_found or "DEVTOOLS_EXPECTED_ERROR" in str(entry)
	check(warning_found and error_found, "Native engine warnings/errors were not captured.")
	var archive := logger.export_logs("res://.devtools-checks/exports")
	check(not archive.is_empty() and FileAccess.file_exists(archive), "Diagnostic ZIP export failed.")
	var fps := context.get_node("FPSTracker")
	await create_timer(0.3).timeout
	check("FPS" in fps.label.text, "FPS label was not populated.")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.devtools-checks/game.png")
		var recorder := context.tool(&"recorder")
		recorder.output_directory = "res://.devtools-checks/recordings"
		recorder.ffmpeg_cache_directory = ProjectSettings.get_setting("dev_tools/test_ffmpeg_cache", "user://dev_toolkit/ffmpeg")
		recorder.capture_fps = 15
		recorder.start_recording()
		var deadline := Time.get_ticks_msec() + 180000
		while recorder.pending_recording and Time.get_ticks_msec() < deadline:
			await create_timer(0.25).timeout
		check(recorder.recording, "Recorder did not start: " + recorder.last_error)
		if recorder.recording:
			await create_timer(1.5).timeout
			recorder.stop_recording()
			while recorder.finalizing and Time.get_ticks_msec() < deadline:
				await create_timer(0.1).timeout
			check(not recorder.last_path.is_empty() and FileAccess.file_exists(recorder.last_path), "Real recording did not finish: " + recorder.last_error)
			print("RECORDING_PATH: ", recorder.last_path)
	print("DEVTOOLS_TEST: ", "PASS" if failures.is_empty() else "FAIL: " + str(failures))
	quit(0 if failures.is_empty() else 1)
