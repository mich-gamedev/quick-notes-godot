@tool extends Panel

@onready var edit_tabs: TabContainer = %EditTabs
@onready var editor_theme = EditorInterface.get_editor_theme()
@onready var settings = EditorInterface.get_editor_settings()
@onready var tab_edit: TextEdit = %Edit
@onready var tab_preview: RichTextLabel = %Preview
@onready var save: Button = %Save



func _ready() -> void:
	for i in edit_tabs.get_child_count():
		match edit_tabs.get_child(i).name:
			&"Edit":
				edit_tabs.set_tab_icon(i, editor_theme.get_icon(&"Edit", &"EditorIcons"))
			&"Preview":
				edit_tabs.set_tab_icon(i, editor_theme.get_icon(&"GuiVisibilityVisible", &"EditorIcons"))

	save.icon = editor_theme.get_icon(&"Save", &"EditorIcons")
	settings.settings_changed.connect(_setting_changed)
	await get_tree().process_frame
	_setting_changed()

func _setting_changed() -> void:
	if settings.get_setting("interface/editor/dock_tab_style"):
		var parent = get_parent()
		if parent is TabContainer:
			parent.set_tab_icon(get_index(), preload("uid://dpq7d22ylxs3o"))

func _on_edit_text_changed() -> void:
	tab_preview.text = ""
	var formatting : Dictionary[String, String] = {"- ": get_setting("replace_bullet_points_with"), "[ ]": get_setting("replace_unchecked_boxes_with"), "[x]": get_setting("replace_checked_boxes_with")}
	var lines := tab_edit.text.split("\n")
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
	return settings.get_setting("plugin/quick_notes/formatting/" + s)
