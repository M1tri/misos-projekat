extends Node2D

var mainInput : LineEdit

var inputDisplay : InputDisplay

var symbolTableContainer : SymbolTableContainer

@onready var inputAnalysisTimer : Timer = $InputAnalysisTimer

func _ready() -> void:
	mainInput = get_tree().get_first_node_in_group("Input")
	inputDisplay = get_tree().get_first_node_in_group("InputDisplay")
	inputDisplay.set_new_input.connect(start_input_analysis)
	
	symbolTableContainer  = get_tree().get_first_node_in_group("SymbolTableContainer")

func _on_start_button_pressed() -> void:
	inputDisplay.set_new_input_text(mainInput.text)

func start_input_analysis():
	inputAnalysisTimer.start()

func _on_input_analysis_timer_timeout() -> void:
	next_char()

func next_char():
	var next : String = inputDisplay.consume_char()
	if next == "":
		symbolTableContainer.sort()
		return
	
	symbolTableContainer.process_symbol(next)
	inputAnalysisTimer.start()
