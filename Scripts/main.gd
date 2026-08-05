extends Node2D

const ALPHABET : String = "abcdefghijklmnopqrstuvwxyz0123456789"

@onready var lineEdit : LineEdit = $PanelContainer/VBoxContainer/Input/LineEdit

func _on_line_edit_text_changed(new_text: String) -> void:
	if (new_text.length() < 1):
		return
	
	var last = new_text[new_text.length()-1]
	if last not in ALPHABET:
		var cursor_pos = lineEdit.caret_column
		lineEdit.text = new_text.substr(0, new_text.length()-1)
		lineEdit.caret_column = cursor_pos - 1
