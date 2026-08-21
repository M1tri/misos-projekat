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
var started_decoding : bool = false
var last_highlighted : int = -1

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
	var finished_coding : bool = next_coding_step()
	
	if not finished_coding:
		coding_timer.start()

func next_coding_step() -> bool:
	inputDisplay.highlight_char(input_pos)
	var c : String = input_text[input_pos]
	
	if not lzw_dict.contains(p+c):
		var output_code : String = str(lzw_dict.get_code(p))
		var representing : String = p
		var string : String = p+c
		
		lzw_dict.add_symbol(string)
		var code_word : String = str(lzw_dict.get_code(string))
		
		var step_text : String = ""
		step_text += "P = " + "[color=red]" + p + "[/color]" 
		step_text += ", C = " + "[color=blue]" + c + "[/color] | "
		step_text += "P + C = " + "[color=green]" + p + c + "[/color] (NIJE U REČNIKU) | "
		step_text += "Na izlazu kod za P: " + output_code + " | "
		step_text += "P = " + "[color=blue]" + c + "[/color]"
		
		lzw_step_table.add_step(step_text)
		
		codes.append(lzw_dict.get_code(p))
		coded.add_substr(" " + output_code)
		p = c
		
		lzw_dict.add_row([output_code, representing, code_word, string])
	else:
		var step_text : String = ""
		step_text += "P = " + "[color=red]" + p + "[/color]" 
		step_text += ", C = " + "[color=blue]" + c + "[/color] | "
		step_text += "P + C = " + "[color=green]" + p + c + "[/color] (JESTE U REČNIKU) | "
		step_text += "P = " + "[color=green]" + p + c + "[/color]"
		
		lzw_step_table.add_step(step_text)
		p = p+c
	
	input_pos += 1
	var finished : bool = input_pos >= input_text.length() 
	
	if finished:
		coded.add_substr(" " + str(lzw_dict.get_code(p)))
		codes.append(lzw_dict.get_code(p))
	
	return finished

func start_decoding():
	lzw_dict.reset()
	lzw_dict.set_columns(["Izlazni simbol", "Kod", "Kod", "Simbol"])
	code_pos = 0
	
	lzw_step_table.reset()
	
	old = codes[code_pos]
	last_highlighted = coded.highlight_substr(str(old), 0)
	var s : String = lzw_dict.get_symbol(old)
	decoded.add_substr(s)
	code_pos += 1
	
	lzw_step_table.add_step("Old= " + str(old) + ", S= " + s)
	
	if code_pos < codes.size():
		decoding_timer.start()

func _on_decoding_timer_timeout() -> void:
	var finished_decoding : bool = next_decode_step()
	
	if not finished_decoding:
		decoding_timer.start()

func next_decode_step() -> bool:
	var new : int = codes[code_pos]
	last_highlighted = coded.highlight_substr(str(new), last_highlighted)
	
	var s : String
	if not lzw_dict.containts_code(new):
		s = lzw_dict.get_symbol(old)
		s += s[0]
	else:
		s = lzw_dict.get_symbol(new)
	
	var c : String = s[0]
	decoded.add_substr(s)
	var new_symbol : String = lzw_dict.get_symbol(old) + c 
	lzw_dict.add_symbol(new_symbol)
	
	var output_symbol : String = s
	var output_code : String = str(lzw_dict.get_code(s))
	var new_symbol_code : String = str(lzw_dict.get_code(new_symbol))
	
	lzw_dict.add_row([output_symbol, output_code, new_symbol, new_symbol_code])
	
	old = new
	
	lzw_step_table.add_step(
		"Old= " + str(old) + ", S= " + s + ", New= " + str(new) + ", C= " + c
	)
	
	code_pos += 1
	var finished : bool = code_pos >= codes.size()
	return finished

func _on_start_decoding_pressed() -> void:
	start_decoding()
