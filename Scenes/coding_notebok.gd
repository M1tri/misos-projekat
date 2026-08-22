class_name CodingNotebook
extends VBoxContainer

var text_label : RichTextLabel
var buttons_container : HBoxContainer

signal displayed_text

func _ready() -> void:
	for child in get_children():
		if child is RichTextLabel:
			text_label = child as RichTextLabel
		elif child is HBoxContainer:
			buttons_container = child as HBoxContainer

func display_text(text : String, duration : float):
	text_label.text = text
	var char_count : int = text_label.get_total_character_count()
	text_label.visible_characters = 0
	
	var visible_chars_tween : Tween = text_label.create_tween()
	visible_chars_tween.tween_property(
		text_label,
		"visible_characters",
		char_count,
		duration
	).finished.connect(func (): displayed_text.emit())

func append_text(text : String, duration : float):
	var old_char_count : int = text_label.get_total_character_count()
	text_label.append_text(text)
	
	var char_count : int = text_label.get_total_character_count()
	text_label.visible_characters = old_char_count

	var visible_chars_tween : Tween = text_label.create_tween()
	visible_chars_tween.tween_property(
		text_label,
		"visible_characters",
		char_count,
		duration
	).finished.connect(func (): displayed_text.emit())

func clear_text():
	text_label.text = ""

func add_button(button_text : String, one_press : bool = true) -> Button:
	var button : Button = Button.new()
	
	button.text = button_text
	
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	buttons_container.add_child(button)
	
	if one_press:
		button.pressed.connect(func(): button.disabled = true)
	
	return button

func clear_buttons():
	for button in buttons_container.get_children():
		button.queue_free()
