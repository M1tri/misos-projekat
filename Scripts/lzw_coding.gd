extends Control

var inputDisplay : InputDisplay

var input : LineEdit

@onready var start_button : Button = $GUI/HBoxContainer/Input/MarginContainer/Input/StartButton

var lzw_dict : LZWDictionary
var lzw_step_table : LZWStepTable

var input_text : String = ""
var input_pos : int = -1

var p : String = ""

var codes : Array[int] = []
var code_pos : int = -1
var old : int

@onready var text_count_label : Label = $GUI/HBoxContainer/Input/MarginContainer/Input/TextCount

@onready var coding_timer : Timer = $CodingTimer
@onready var decoding_timer : Timer = $DecodingTimer

@onready var coded : RicherLabel = $GUI/HBoxContainer/Visualization/Board/VBoxContainer/MarginContainer/HBoxContainer/Coded
@onready var decoded : RicherLabel = $GUI/HBoxContainer/Visualization/Board/VBoxContainer/MarginContainer/HBoxContainer/Decoded

func _ready() -> void:
	inputDisplay = get_tree().get_first_node_in_group("InputDisplay")
	inputDisplay.set_new_input.connect(start_input_analysis)
	
	input = get_tree().get_first_node_in_group("Input")
	input.text_changed.connect(input_changed)
	
	lzw_dict = get_tree().get_first_node_in_group("LZWDict")
	
	lzw_step_table = get_tree().get_first_node_in_group("LZWStepTable")
	
	start_button.disabled = true

func start_input_analysis():
	input_pos = 0
	coding_timer.start()

func input_changed(new_text : String):
	input_text = new_text
	
	if input_text.length() == 0:
		start_button.disabled = true
	else:
		start_button.disabled = false
	
	text_count_label.text = str(input_text.length()) + "/16"

func _on_start_button_pressed() -> void:
	inputDisplay.set_new_input_text(input_text)

func _on_coding_timer_timeout() -> void:
	inputDisplay.highlight_char(input_pos)
	var c : String = input_text[input_pos]
	
	if not lzw_dict.contains(p+c):
		var output_code : String = str(lzw_dict.get_code(p))
		var representing : String = p
		var string : String = p+c
		
		lzw_dict.add_symbol(string)
		var code_word : String = str(lzw_dict.get_code(string))
		
		lzw_step_table.add_output_step(p, c, output_code)
		
		codes.append(lzw_dict.get_code(p))
		coded.append_text(" " + output_code)
		p = c
		
		lzw_dict.add_row([output_code, representing, code_word, string])
	else:
		lzw_step_table.add_normal_step(p, c)
		p = p+c
	
	input_pos += 1
	if input_pos < input_text.length():
		coding_timer.start()
	else:
		coded.append_text(" " + str(lzw_dict.get_code(p)))
		codes.append(lzw_dict.get_code(p))
		
		await get_tree().create_timer(1).timeout
		
		lzw_dict.reset()
		code_pos = 0
		
		old = codes[code_pos]
		decoded.append_text(lzw_dict.get_symbol(old))
		code_pos += 1
		
		if code_pos < codes.size():
			decoding_timer.start()

func _on_decoding_timer_timeout() -> void:
	var new : int = codes[code_pos]
	
	var s : String
	if not lzw_dict.containts_code(new):
		s = lzw_dict.get_symbol(old)
		s += s[0]
	else:
		s = lzw_dict.get_symbol(new)
	
	var c : String = s[0]
	decoded.append_text(s)
	lzw_dict.add_symbol(lzw_dict.get_symbol(old) + c)
	old = new
	
	code_pos += 1
	if code_pos < codes.size():
		decoding_timer.start()
