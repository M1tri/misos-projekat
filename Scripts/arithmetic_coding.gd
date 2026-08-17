extends Node2D

var symbolTable : SymbolTableContainer

var inputDisplay : InputDisplay

var input : LineEdit

@onready var inputAnalysisTimer : Timer = $InputAnalysisTimer

var arithmeticCodingVisualizer : ArithmeticCodingVisualizer

func _ready() -> void:
	symbolTable = get_tree().get_first_node_in_group("SymbolTableContainer")
	inputDisplay = get_tree().get_first_node_in_group("InputDisplay")
	input = get_tree().get_first_node_in_group("Input")
	inputDisplay.set_new_input.connect(start_input_analysis)
	
	arithmeticCodingVisualizer = get_tree().get_first_node_in_group("ACV")

func _on_start_button_pressed() -> void:
	inputDisplay.set_new_input_text(input.text)
	arithmeticCodingVisualizer.arithmetic_compress(input.text)

func start_input_analysis():
	inputAnalysisTimer.start()

func _on_input_analysis_timer_timeout() -> void:
	var nextChar : String = inputDisplay.consume_char()
	
	if nextChar != "":
		symbolTable.process_symbol(nextChar)
		inputAnalysisTimer.start()
	else:
		symbolTable.sort()
