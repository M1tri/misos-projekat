class_name StepsTable
extends VBoxContainer

const INT_MAX : int = 9223372036854775807

var shannon_tree_node_scene : PackedScene = preload("res://misos-projekat/Scenes/tree_node.tscn")

var codes : Dictionary[String, String] = {}
var steps : Array[String] = []
var stepsPos : int = -1
var stepLabels : Array[ShannonTableLable] = []

class ShannonSymbol:
	var text : String
	var frequency : int
	
	func _init(_text : String, _frequency : int) -> void:
		text = _text
		frequency = _frequency

func calculate_shannon_tree(message : String) -> ShannonTreeNode:
	var symbolFrequencies : Dictionary[String, int] = {}
	
	for s in message:
		if s in symbolFrequencies:
			symbolFrequencies[s] += 1
		else:
			codes[s] = ""
			symbolFrequencies[s] = 1
	
	var symbols : Array[ShannonSymbol] = []
	for s in symbolFrequencies:
		symbols.append(ShannonSymbol.new(s, symbolFrequencies[s]))
	
	symbols.sort_custom(
		func (s1 : ShannonSymbol, s2: ShannonSymbol):
			return s1.frequency > s2.frequency
			)
	
	var root : ShannonTreeNode = shannon_fanno(symbols)
	stepsPos = 0
	
	return root

func NextStep():
	if stepsPos < 0 or stepsPos >= steps.size():
		return
	
	var stepLabel : ShannonTableLable = ShannonTableLable.new()
	stepLabel.text = steps[stepsPos]
	add_child(stepLabel)
	stepLabels.append(stepLabel)
	stepsPos += 1

func reset():
	codes.clear()
	steps.clear()
	for l in stepLabels:
		l.queue_free()
	stepLabels.clear()

func shannon_fanno(symbols : Array[ShannonSymbol]) -> ShannonTreeNode:
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
	
	var left : Array[ShannonSymbol] = []
	var right : Array[ShannonSymbol] = []
	
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
	
	var step_text : String = str(steps.size()+1) + ": "
	step_text += arr_to_str(symbols) + " → "
	step_text += arr_to_str(left) + " [[color=red]" + str(arr_sum(left)) + "[/color]]"
	step_text += " | " + arr_to_str(right) + " [[color=red]" + str(arr_sum(right)) + "[/color]]"
	
	steps.append(
		 step_text
		)
	
	node.leftChild = shannon_fanno(left)
	node.rightChild = shannon_fanno(right)
	
	return node

func get_code(symbol : String) -> String:
	if symbol not in codes:
		return ""
	return codes[symbol]

func arr_to_str(array : Array[ShannonSymbol]) -> String:
	var ret : String = ""
	for i in range(0, array.size()-1):
		ret += array[i].text + " "
	ret += array.back().text
	return ret 

func arr_sum(array : Array[ShannonSymbol]) -> int:
	var sum : int = 0
	for s in array:
		sum += s.frequency
	return sum
