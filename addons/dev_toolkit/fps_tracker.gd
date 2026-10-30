extends CanvasLayer
## Small, noninteractive FPS overlay. F8 toggles visibility.
@export var toggle_key: Key = KEY_F8
@export var update_interval: float = 0.25
var label: Label
var elapsed: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 90
	label = Label.new()
	label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	label.position = Vector2(-160, -40)
	label.size = Vector2(144, 28)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(label)
	_update_label()

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= update_interval:
		elapsed = 0.0
		_update_label()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == toggle_key or event.physical_keycode == toggle_key:
			visible = not visible
			get_viewport().set_input_as_handled()

func _update_label() -> void:
	label.text = "%d FPS" % Engine.get_frames_per_second()
