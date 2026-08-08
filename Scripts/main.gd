extends Node2D

const ALPHABET : String = "abcdefghijklmnopqrstuvwxyz0123456789"
const INT_MAX = 9223372036854775807

@onready var lineEdit : LineEdit = $PanelContainer/VBoxContainer/Input/LineEdit
@onready var shannonTreeVisualizer = $PanelContainer/VBoxContainer/Visualizations/TreeVisualizer
@onready var inputAnalysis = $PanelContainer/VBoxContainer/Visualizations/InputAnalysis

var shannon_tree_node_scene : PackedScene = preload("res://misos-projekat/Scenes/tree_node.tscn")

var codes : Dictionary[String, String] = {}
var steps : Array[String] = []
var root : ShannonTreeNode = null

var text : String
var textPos : int

var symbolsTable : Dictionary[String, Symbol] = {}
var symbolLabels : Dictionary[String, Label] = {}

func _on_line_edit_text_changed(new_text: String) -> void:
	if (new_text.length() < 1):
		return
	
	var last = new_text[new_text.length()-1]
	if last not in ALPHABET:
		var cursor_pos = lineEdit.caret_column
		lineEdit.text = new_text.substr(0, new_text.length()-1)
		lineEdit.caret_column = cursor_pos - 1

func _on_start_pressed() -> void:
	inputAnalysis.set_text(lineEdit.text)
	text = lineEdit.text
	textPos = 0
	randomAhh.start()

func show_tree():
	#var symbolsTable : Dictionary[String, Symbol]
	#for symbol in lineEdit.text:
	#	if (symbol in symbolsTable):
	#		symbolsTable[symbol].frequency += 1
	#	else:
	#		symbolsTable[symbol] = Symbol.new(symbol, 1)
	
	var symbol_array : Array[Symbol] = []
	for symbol in symbolsTable:
		symbol_array.append(symbolsTable[symbol])
	
	symbol_array.sort_custom(func (a : Symbol, b : Symbol) : return a.frequency > b.frequency)
	codes.clear()
	for s in symbol_array:
		print(s.text, " ", s.frequency)
		codes[s.text] = ""
	
	steps.clear()
	root = shannon_fanno(symbol_array)
	
	print("Steps:")
	for step in steps:
		print(step)
	
	print("Codes:")
	for symbol in codes:
		print(symbol, " : ", codes[symbol])
	
	shannonTreeVisualizer.DrawTree(root)

func shannon_fanno(symbols : Array[Symbol]) -> ShannonTreeNode:
	if (symbols.size() == 1):
		var leaf : ShannonTreeNode = shannon_tree_node_scene.instantiate()
		leaf.text = symbols[0].text + "\n" + codes[symbols[0].text]
		return leaf
	
	var split : int = 1
	var best_split : int = 1
	var best_diff : int = INT_MAX
	
	while (split < symbols.size()-1):
		
		var left_sum : int = 0
		for i in range(0, split):
			left_sum += symbols[i].frequency
		
		var right_sum : int = 0
		for i in range(split, symbols.size()):
			right_sum += symbols[i].frequency
		
		var diff : int = abs(left_sum - right_sum)
		
		if (diff < best_diff):
			best_diff = diff
			best_split = split
			split += 1
		else:
			break
	
	var left : Array[Symbol] = []
	var right : Array[Symbol] = []
	
	for i in range(0, best_split):
		left.append(symbols[i])
		codes[symbols[i].text] += "0"
	
	for i in range(best_split, symbols.size()):
		right.append(symbols[i])
		codes[symbols[i].text] += "1"
	
	var text : String = ""
	for s in symbols:
		text += s.text
	
	var node : ShannonTreeNode = shannon_tree_node_scene.instantiate()
	node.text = text
	
	steps.append("Step " + str(steps.size()+1) + ": " + arr_to_str(left) + " | " + arr_to_str(right))
	
	node.leftChild = shannon_fanno(left)
	node.rightChild = shannon_fanno(right)
	
	return node

func arr_to_str(array : Array[Symbol]) -> String:
	var ret : String = ""
	for s in array:
		ret += "(" + s.text + ", " + str(s.frequency) + ") "
	
	return ret 

@onready var nextStepButton : Button = $PanelContainer/VBoxContainer/Visualizations/VBoxContainer/NextStepButton
func _on_next_step_cooldown_timeout() -> void:
	nextStepButton.disabled = false

@onready var randomAhh : Timer = $RandomAhh
@onready var sideBarTable : VBoxContainer = $PanelContainer/VBoxContainer/Visualizations/VBoxContainer/SideBarWrapper/SideBarTable
@onready var negro = $PanelContainer/VBoxContainer/Visualizations/VBoxContainer/SideBarWrapper
func _on_random_ahh_timeout() -> void:
	inputAnalysis.highlight_letter(textPos)
	var symbol = text[textPos]
	
	if symbol in symbolsTable:
		symbolsTable[symbol].frequency += 1
		symbolLabels[symbol].text = symbol + " | " + str(symbolsTable[symbol].frequency)
	else:
		symbolsTable[symbol] = Symbol.new(symbol, 1)
		var new_label : Label = Label.new()
		new_label.text = symbol + " | 1"
		
		sideBarTable.add_child(new_label)
		symbolLabels[symbol] = new_label
	
	if textPos+1 < text.length():
		textPos += 1
		randomAhh.start()
