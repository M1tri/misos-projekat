extends Node2D

var mainInput : LineEdit

var inputDisplay : InputDisplay

var symbolTableContainer : SymbolTableContainer

var shannonTreeVisualizer : ShannonTreeVisualizer

var stepsTable : StepsTable

@onready var inputAnalysisTimer : Timer = $InputAnalysisTimer
@onready var treeTimer : Timer = $TreeTimer

func _ready() -> void:
	mainInput = get_tree().get_first_node_in_group("Input")
	inputDisplay = get_tree().get_first_node_in_group("InputDisplay")
	inputDisplay.set_new_input.connect(start_input_analysis)
	
	symbolTableContainer  = get_tree().get_first_node_in_group("SymbolTableContainer")
	
	shannonTreeVisualizer = get_tree().get_first_node_in_group("ShannonTreeVisualizer")
	
	stepsTable = get_tree().get_first_node_in_group("StepsTable")

func _on_start_button_pressed() -> void:
	inputDisplay.set_new_input_text(mainInput.text)
	
	symbolTableContainer.reset()
	symbolTableContainer.adjust_font_size(mainInput.text.length())
	
	stepsTable.reset()
	
	shannonTreeVisualizer.reset()

func start_input_analysis():
	inputAnalysisTimer.start()

func _on_input_analysis_timer_timeout() -> void:
	next_char()

func next_char():
	var next : String = inputDisplay.consume_char()
	if next == "":
		symbolTableContainer.sort()
		var root : ShannonTreeNode = stepsTable.calculate_shannon_tree(mainInput.text)
		shannonTreeVisualizer.DrawTree(root)
		shannonTreeVisualizer.NextStep()
		treeTimer.start()
		return
	
	symbolTableContainer.process_symbol(next)
	inputAnalysisTimer.start()


func _on_tree_timer_timeout() -> void:
	var finished : bool = shannonTreeVisualizer.NextStep()
	stepsTable.NextStep()
	if not finished:
		treeTimer.start()
