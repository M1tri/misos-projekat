class_name InputDisplay
extends RichTextLabel

signal set_new_input

var inputText : String = ""
var textPos : int = -1

var eraser : Eraser
var eraserPanel : MarginContainer

func _ready() -> void:
	for child in get_children():
		if child is Sprite2D:
			eraser = child
		elif child is MarginContainer:
			eraserPanel = child

func erase():
	var eraserTween : Tween = create_tween()
	
	eraser.start_rotating()
	@warning_ignore("integer_division")
	eraserTween.tween_property(
		eraser, 
		"position:x", 
		eraser.texture.get_width()/2, 
		1.8
	)
	
	var eraserPanelTween : Tween = create_tween()
	eraserPanelTween.tween_property(
		eraserPanel,
		"theme_override_constants/margin_left",
		8,
		1.8
	)
	
	@warning_ignore("integer_division")
	eraserTween.tween_property(
		eraser, 
		"position:x",
		 self.size.x-eraser.texture.get_width()/2, 
		0.5
	).finished.connect(finish_setting_input)

func set_new_input_text(new_input_text : String):
	eraserPanel.size = self.size
	eraserPanel.add_theme_constant_override("margin_left", eraser.position.x)
	
	inputText = new_input_text
	textPos = 0
	erase()

func finish_setting_input():
	eraser.stop_rotating()
	eraserPanel.add_theme_constant_override("margin_left", eraser.position.x)
	
	self.text = inputText
	var total_chars : int = self.get_total_character_count()
	self.visible_characters = 0
	
	var tween : Tween = create_tween()
	tween.tween_property(self, "visible_characters", total_chars, 1.0).finished.connect(
		func (): 
			set_new_input.emit()
			)

func consume_char() -> String:
	if textPos < 0 or textPos >= inputText.length():
		return ""
	
	var curr : String = inputText[textPos]
	
	var new_label_text : String = ""
	for i in range(0, inputText.length()):
		var letter : String = inputText[i]
		if i == textPos:
			letter = "[color=red]" + letter + "[/color]"
		new_label_text += letter
	
	textPos += 1
	self.text = new_label_text
	
	return curr
