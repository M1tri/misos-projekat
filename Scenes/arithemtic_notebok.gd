class_name ArithmeticNotebook
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

func clear_text():
	text_label.text = ""

func add_button(button_text : String) -> Button:
	var button : Button = Button.new()
	
	button.text = button_text
	
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	buttons_container.add_child(button)
	
	return button

func clear_buttons():
	for button in buttons_container.get_children():
		button.queue_free()
