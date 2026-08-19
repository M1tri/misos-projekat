extends Node2D

var mainInput : LineEdit

var inputDisplay : InputDisplay

var symbolTableContainer : SymbolTableContainer

var shannonTreeVisualizer : ShannonTreeVisualizer

var stepsTable : StepsTable

var input_text : String = ""
var inputPos : int = -1

@onready var inputAnalysisTimer : Timer = $InputAnalysisTimer
@onready var treeTimer : Timer = $TreeTimer
@onready var start_button : Button = $GUI/HBoxContainer/InputAndCounting/InputMargin/Input/StartButton
@onready var codingTimer : Timer = $CodingTimer

@onready var temp_coded : RicherLabel = $GUI/HBoxContainer/Tree/MarginContainer/VBoxContainer/Coded/VBoxContainer/Coded
@onready var temp_decoded : RicherLabel = $GUI/HBoxContainer/Tree/MarginContainer/VBoxContainer/Coded/VBoxContainer/Decoded

@onready var text_count_label : Label = $GUI/HBoxContainer/InputAndCounting/InputMargin/Input/TextCount

var is_coding : bool = false

func _ready() -> void:
	mainInput = get_tree().get_first_node_in_group("Input")
	mainInput.text_changed.connect(text_changed)
	
	inputDisplay = get_tree().get_first_node_in_group("InputDisplay")
	inputDisplay.set_new_input.connect(start_input_analysis)
	
	symbolTableContainer  = get_tree().get_first_node_in_group("SymbolTableContainer")
	symbolTableContainer.set_column_name(1, "symbol")
	symbolTableContainer.set_column_name(2, "frequency")
	
	shannonTreeVisualizer = get_tree().get_first_node_in_group("ShannonTreeVisualizer")
	
	stepsTable = get_tree().get_first_node_in_group("StepsTable")
	
	start_button.disabled = true

func text_changed(new_text : String):
	input_text = new_text
	
	if input_text.length() == 0:
		start_button.disabled = true
	else:
		start_button.disabled = false
	
	text_count_label.text = str(input_text.length()) + "/10"

func _on_start_button_pressed() -> void:
	if input_text.length() == 0:
		return
	
	inputDisplay.set_new_input_text(input_text)
	inputPos = 0
	
	var unique : Array[String] = []
	for c in input_text:
		if c not in unique:
			unique.append(c)
	
	symbolTableContainer.reset()
	symbolTableContainer.adjust_font_size(unique.size())
	
	stepsTable.reset()
	
	shannonTreeVisualizer.reset()

func start_input_analysis():
	inputAnalysisTimer.start()

func _on_input_analysis_timer_timeout() -> void:
	next_char()

func next_char():
	if inputPos < 0 or inputPos >= input_text.length():
		inputDisplay.reset_highlight()
		symbolTableContainer.sort()
		
		await symbolTableContainer.sorted
		
		var root : ShannonTreeNode = stepsTable.calculate_shannon_tree(mainInput.text)
		
		shannonTreeVisualizer.DrawTree(root)
		shannonTreeVisualizer.NextStep()
		treeTimer.start()
		return
	
	var next : String = input_text[inputPos]
	
	symbolTableContainer.process_symbol(next)
	inputAnalysisTimer.start()
	inputDisplay.highlight_char(inputPos)
	inputPos += 1

func _on_tree_timer_timeout() -> void:
	var finished : bool = shannonTreeVisualizer.NextStep()
	stepsTable.NextStep()
	
	if not finished:
		treeTimer.start()
	else:
		inputPos = 0
		codingTimer.start()
		is_coding = true
		temp_coded.set_new_text("")
		
		symbolTableContainer.set_column_name(2, "code")
		for symbol in input_text:
			symbolTableContainer.change_symbol_counter_text(symbol, stepsTable.get_code(symbol))


func _on_coding_timer_timeout() -> void:
	if is_coding:
		NextCodeStep()
	else:
		NextDecodeStep()

func NextCodeStep():
	var symbol : String = input_text[inputPos]
	
	var delay : float = 0.5
	
	inputDisplay.highlight_char(inputPos)
	symbolTableContainer.highlight_row(symbol, delay)
	shannonTreeVisualizer.light_up_leaf(symbol, delay)
	
	temp_coded.add_char(stepsTable.get_code(symbol))
	
	inputPos += 1
	if inputPos < input_text.length():
		codingTimer.start()
	else:
		curr_node = shannonTreeVisualizer.shannonTreeRoot
		code_pos = 0
		is_coding = false
		codingTimer.start()
		curr_node.highlight()

var curr_node : ShannonTreeNode = null
var code_pos : int = -1

func NextDecodeStep():
	var bit : String = temp_coded.get_char(code_pos)
	temp_coded.highlight_char(code_pos)
	
	curr_node.unhighlight()
	if bit == "0":
		curr_node = curr_node.leftChild
	elif bit == "1":
		curr_node = curr_node.rightChild
	
	curr_node.highlight()
	if curr_node.is_leaf():
		await get_tree().create_timer(.5).timeout
		var symbol : String = curr_node.get_symbol()
		temp_decoded.add_char(symbol)
		
		curr_node.unhighlight()
		curr_node = shannonTreeVisualizer.shannonTreeRoot
		curr_node.highlight()
	
	code_pos += 1
	if code_pos < temp_coded.display_text.length():
		codingTimer.start()
	else:
		curr_node.unhighlight()
