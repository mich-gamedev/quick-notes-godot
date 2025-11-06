@tool
extends EditorPlugin

var dock: Control
const INTERFACE = preload("uid://bf7qcsvak5qk1")
const SETTING_INFO = "res://addons/quick_notes_dock/setting_info.json"
var editor_settings := EditorInterface.get_editor_settings()

func _enable_plugin() -> void:
	var file = FileAccess.open(SETTING_INFO, FileAccess.READ)
	var data : Array = JSON.parse_string(file.get_as_text())
	for i: Dictionary in data:
		var info = i.duplicate()
		info.erase("default")
		if !editor_settings.has_setting(i.name):
			editor_settings.set_setting(i.name, i.default)
		editor_settings.set_initial_value(i.name, i.default, false)
		editor_settings.add_property_info(info)

func _disable_plugin() -> void:
	# Remove autoloads here.
	pass

func _enter_tree() -> void:
	dock = INTERFACE.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock)

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()

func _get_plugin_icon() -> Texture2D:
	return preload("uid://dpq7d22ylxs3o") # "stick_note.svg"
