@tool class_name QuickNotesToastLabel extends Label

var twn: Tween
var settings := EditorInterface.get_editor_settings()

func toast(_text: String, color_setting: StringName = &"text_editor/theme/highlighting/text_color", lasts_for: float = 1.0) -> void:
	if twn: twn.kill()
	text = _text
	self["theme_override_colors/font_color"] = settings.get_setting(color_setting)
	twn = create_tween()
	twn.tween_property(self, ^"modulate:a", 0.0, lasts_for).from(1.0)
