class_name RicherLabel
extends RichTextLabel

var display_text : String = ""

func set_new_text(new_text : String):
	display_text = new_text

func highlight_char(char_pos : int):
	if char_pos < 0 or char_pos >= display_text.length():
		return
	
	var new_label_text : String = ""
	for i in range(0, display_text.length()):
		var letter : String = display_text[i]
		if i == char_pos:
			letter = "[color=red]" + letter + "[/color]"
		new_label_text += letter
	
	self.text = new_label_text

func get_char(char_pos : int) -> String:
	if char_pos < 0 or char_pos >= display_text.length():
		return ""
	
	return display_text[char_pos]

func add_char(new_char : String):
	display_text += new_char
	self.text = display_text
