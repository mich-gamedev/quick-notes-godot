@tool class_name QuickNotesDock extends Panel

@onready var edit_tabs: TabContainer = %EditTabs
@onready var editor_theme = EditorInterface.get_editor_theme()
@onready var settings = EditorInterface.get_editor_settings()
@onready var tab_edit: TextEdit = %Edit
@onready var tab_preview: RichTextLabel = %Preview
@onready var save: Button = %Save
@onready var font_size: SpinBox = %FontSize

@onready var plugin: QuickNotesEditorPlugin:
	set(v):
		if is_instance_valid(v):
			plugin = v
			plugin_supplied.emit()

signal plugin_supplied


func _enter_tree() -> void:
	await get_tree().process_frame
	for i in edit_tabs.get_child_count():
		match edit_tabs.get_child(i).name:
			&"Edit":
				edit_tabs.set_tab_icon(i, editor_theme.get_icon(&"Edit", &"EditorIcons"))
			&"Preview":
				edit_tabs.set_tab_icon(i, editor_theme.get_icon(&"GuiVisibilityVisible", &"EditorIcons"))

	save.icon = editor_theme.get_icon(&"Save", &"EditorIcons")
	settings.settings_changed.connect(_setting_changed)
	if !plugin:
		return
	var file = FileAccess.open(plugin.get_setting("defaults/default_path"), FileAccess.READ)
	edit_tabs.current_tab = plugin.get_setting("defaults/default_tab")
	tab_edit.text = file.get_as_text()
	_on_edit_text_changed()
	font_size.value = plugin.get_setting("display/font_size")

func _setting_changed() -> void:
	if settings.get_setting("interface/editor/dock_tab_style"):
		var parent = get_parent()
		if parent is TabContainer:
			parent.set_tab_icon(get_index(), preload("uid://dpq7d22ylxs3o"))

func _on_edit_text_changed() -> void:
	tab_preview.text = ""
	var formatting : Dictionary = {
		"- ": get_setting("formatting/replace_bullet_points_with"),
		"[ ]": get_setting("formatting/replace_unchecked_boxes_with"),
		"[x]": get_setting("formatting/replace_checked_boxes_with")
	}
	var lines := tab_edit.text.split("\n")
	if tab_edit.text.is_empty():
		lines = tab_edit.placeholder_text.split("\n")
	for i in lines.size():
		var new_line = lines[i]
		var stripped = lines[i].lstrip(" 	")
		for replace_with in formatting:
			if !stripped.begins_with(replace_with): continue
			var amount_of_indents = lines[i].length() - stripped.length()
			var rest_of_line = lines[i].substr(amount_of_indents + replace_with.length())
			var accum_indents: String
			for j in amount_of_indents:
				accum_indents += lines[i][j]
			new_line = accum_indents + formatting[replace_with] + " " + rest_of_line
		tab_preview.text += new_line + "\n"


func get_setting(s: String) -> Variant:
	return settings.get_setting("plugin/quick_notes/" + s)


func _on_save_pressed() -> void:
	plugin.save()
	%ToastMessage.toast("Saved to %s" % String(get_setting("defaults/default_path")).get_file())


func _on_font_size_value_changed(value: float) -> void:
	tab_preview["theme_override_font_sizes/normal_font_size"] = value
	tab_preview["theme_override_font_sizes/bold_font_size"] = value
	tab_preview["theme_override_font_sizes/bold_italics_font_size"] = value
	tab_preview["theme_override_font_sizes/italics_font_size"] = value
	tab_preview["theme_override_font_sizes/mono_font_size"] = value
	settings.set_setting("plugin/quick_notes/display/font_size", value)
