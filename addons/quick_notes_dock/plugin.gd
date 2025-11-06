@tool
class_name QuickNotesEditorPlugin extends EditorPlugin

var dock: Control
const INTERFACE = preload("uid://bf7qcsvak5qk1")
const SETTING_INFO = "res://addons/quick_notes_dock/setting_info.json"
var editor_settings := EditorInterface.get_editor_settings()

func _enter_tree() -> void:
	var file = FileAccess.open(SETTING_INFO, FileAccess.READ)
	var data : Array = JSON.parse_string(file.get_as_text())
	for i: Dictionary in data:
		if "hint" in i: i.hint = int(i.hint)
		if "type" in i: i.type = int(i.type)
		var info = i.duplicate()
		info.erase("default")
		if !editor_settings.has_setting(i.name):
			editor_settings.set_setting(i.name, i.default)
		editor_settings.set_initial_value(i.name, i.default, false)
		editor_settings.add_property_info(info)
	await get_tree().process_frame
	dock = INTERFACE.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock)
	dock.plugin = self

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	dock.free()

func _get_plugin_icon() -> Texture2D:
	return preload("uid://dpq7d22ylxs3o") # "stick_note.svg"

func save():
	var file = FileAccess.open(get_setting("defaults/default_path"), FileAccess.WRITE)
	file.store_string(dock.get_node(^"%Edit").text)
	file.close()

func get_setting(s: String) -> Variant:
	return editor_settings.get_setting("plugin/quick_notes/" + s)

func _save_external_data() -> void:
	save()
