class_name InputDisplay
extends RichTextLabel

signal set_new_input

var inputText : String = ""
var textPos : int = -1

func set_new_input_text(new_input_text : String):
	inputText = new_input_text
	textPos = 0
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
