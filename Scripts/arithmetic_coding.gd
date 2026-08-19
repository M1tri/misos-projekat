extends Node2D

var symbolTable : SymbolTableContainer

var inputDisplay : InputDisplay

var input : LineEdit

@onready var start_button : Button = $GUI/HBoxContainer/InputAndVisual/Input/HBoxContainer/StartButton

@onready var inputAnalysisTimer : Timer = $InputAnalysisTimer

var arithmeticCodingVisualizer : ArithmeticCodingVisualizer

var input_text : String = ""
var input_pos : int = -1

@onready var text_count_label : Label = $GUI/HBoxContainer/InputAndVisual/Input/HBoxContainer/TextCount

func _ready() -> void:
	symbolTable = get_tree().get_first_node_in_group("SymbolTableContainer")
	symbolTable.set_column_name(1, "symbol")
	symbolTable.set_column_name(2, "frequency")
	
	inputDisplay = get_tree().get_first_node_in_group("InputDisplay")
	inputDisplay.set_new_input.connect(start_input_analysis)
	
	input = get_tree().get_first_node_in_group("Input")
	input.text_changed.connect(input_changed)
	
	arithmeticCodingVisualizer = get_tree().get_first_node_in_group("ACV")
	arithmeticCodingVisualizer.processing_symbol.connect(highlight)
	
	start_button.disabled = true

func input_changed(new_text : String):
	input_text = new_text
	
	if input_text.length() == 0:
		start_button.disabled = true
	else:
		start_button.disabled = false
	
	text_count_label.text = str(input_text.length()) + "/6"

func _on_start_button_pressed() -> void:
	symbolTable.reset()
	symbolTable.adjust_font_size(input_text.length())
	arithmeticCodingVisualizer.reset()
	inputDisplay.set_new_input_text(input_text)

func start_input_analysis():
	if input_text.length() == 0:
		return
	
	input_pos = 0
	inputAnalysisTimer.start()

func _on_input_analysis_timer_timeout() -> void:
	if input_pos >= input_text.length():
		symbolTable.sort()
		inputDisplay.reset_highlight()
		arithmeticCodingVisualizer.arithmetic_compress(input_text)
		
		return
	
	var nextChar : String = input_text[input_pos]
	
	symbolTable.process_symbol(nextChar)
	inputDisplay.highlight_char(input_pos)
	
	input_pos += 1
	
	inputAnalysisTimer.start()

func highlight(text_pos : int):
	inputDisplay.highlight_char(text_pos)
