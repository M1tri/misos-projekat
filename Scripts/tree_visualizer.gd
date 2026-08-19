class_name ShannonTreeVisualizer
extends Control

const Y_STEP = 100
const X_STEP = 100

class Step:
	var nodesToAdd : Array[ShannonTreeNode]
	
	func _init() -> void:
		nodesToAdd = []
	
	func add(node : ShannonTreeNode):
		nodesToAdd.append(node)

var current_leaf : int = 0
var leaf_count : int = 0

var tree_nodes : Array[ShannonTreeNode] = []
var sequence : Array[Step] = []
var sequence_pos : int = -1

var lines : Array[Line2D] = []
var lineLabels : Array[Label] = []

var shannonTreeRoot : ShannonTreeNode = null

func reset():
	for tree_node in tree_nodes:
		tree_node.queue_free()
	
	tree_nodes.clear()
	sequence.clear()
	sequence_pos = -1
	
	for line in lines:
		line.queue_free()
	lines.clear()
	
	queue_redraw()
	shannonTreeRoot = null

func DrawTree(root : ShannonTreeNode):
	reset()
	shannonTreeRoot = root
	
	leaf_count = CountLeaves(root)
	current_leaf = 0
	
	AssignPositions(root, 0)
	
	var firstStep : Step = Step.new()
	firstStep.add(root)
	sequence.append(firstStep)
	
	CalculateSequence(root, 0)
	sequence_pos = 0

func CountLeaves(node : ShannonTreeNode) -> int:
	if node.leftChild == null and node.rightChild == null:
		return 1
	
	var count = 0
	
	if node.leftChild:
		count += CountLeaves(node.leftChild)
	
	if node.rightChild:
		count += CountLeaves(node.rightChild)
	
	return count

func AssignPositions(node : ShannonTreeNode, depth : int):
	if node.leftChild:
		AssignPositions(node.leftChild, depth + 1)
	
	if node.leftChild == null and node.rightChild == null:
		node.target_pos = Vector2(
			(current_leaf - leaf_count / 2.0) * X_STEP + size.x / 2,
			50 + depth * Y_STEP
		)
		
		current_leaf += 1
	
	if node.rightChild:
		AssignPositions(node.rightChild, depth + 1)
	
	if node.leftChild and node.rightChild:
		node.target_pos = Vector2(
			(node.leftChild.target_pos.x + node.rightChild.target_pos.x) / 2,
			50 + depth * Y_STEP
		)

func CalculateSequence(node : ShannonTreeNode, depth : int):
	node.radius -= 2*depth
	
	if node.leftChild == null and node.rightChild == null:
		return
	
	var step : Step = Step.new()
	if (node.leftChild):
		node.leftChild.position = node.target_pos
		step.add(node.leftChild)
	
	if (node.rightChild):
		node.rightChild.position = node.target_pos
		step.add(node.rightChild)
	
	sequence.append(step)
	
	if (node.leftChild):
		CalculateSequence(node.leftChild, depth+1)
	
	if (node.rightChild):
		CalculateSequence(node.rightChild, depth+1)

func NextStep() -> bool:
	if sequence_pos == -1 or sequence_pos >= sequence.size():
		return true
	
	for node : ShannonTreeNode in sequence[sequence_pos].nodesToAdd: 
		node.draw_line.connect(draw_line_between_nodes)
		add_child(node)
		tree_nodes.append(node)
	
	sequence_pos += 1
	return false

func move_tree(dx : float, dy : float):
	if shannonTreeRoot == null:
		return
		
	for line in lines:
		line.queue_free()
	lines.clear()
	
	for label in lineLabels:
		label.queue_free()
	lineLabels.clear()
	
	move_tree_internal(dx, dy, shannonTreeRoot)

func move_tree_internal(dx : float, dy : float, node : ShannonTreeNode):
	node.position = node.position + Vector2(dx, dy)
	node.target_pos = node.position
	
	if node.leftChild:
		move_tree_internal(dx, dy, node.leftChild)
		draw_line_between_nodes(node, node.leftChild, "0", Vector2(-10, -10))
	
	if node.rightChild:
		move_tree_internal(dx, dy, node.rightChild)
		draw_line_between_nodes(node, node.rightChild, "1", Vector2(10, -10))

func light_up_leaf(symbol : String, delay : float):
	if shannonTreeRoot == null:
		return
	
	light_up_leaf_internal(symbol, shannonTreeRoot, delay)

func light_up_leaf_internal(symbol : String, node : ShannonTreeNode, delay : float) -> bool:
	if node.is_leaf() and node.get_symbol().contains(symbol):
		node.light_up(delay)
		return true
	
	if node.leftChild != null and light_up_leaf_internal(symbol, node.leftChild, delay):
		return true
	
	if node.rightChild != null and light_up_leaf_internal(symbol, node.rightChild, delay):
		return true
	
	return false

func draw_line_between_nodes(
	node1 : ShannonTreeNode, 
	node2 : ShannonTreeNode, 
	lineText : String,
	labelOffset : Vector2):
	var direction = (node2.target_pos - node1.target_pos).normalized()
	
	var start = node1.target_pos + direction*node1.radius
	var end = node2.target_pos - direction*node2.radius
	
	var line : Line2D = Line2D.new()
	line.points = [start, end]
	line.default_color = Color.BLACK
	line.width = 2
	add_child(line)
	lines.append(line)
	
	var middle : Vector2 = (start + end) / 2
	
	middle.x += labelOffset.x
	middle.y += labelOffset.y
	
	var lineLabel : Label = Label.new()
	lineLabel.add_theme_font_size_override("font_size", 18)
	lineLabel.add_theme_color_override("font_color", Color.REBECCA_PURPLE)
	
	lineLabel.text = lineText
	lineLabel.position = middle
	
	add_child(lineLabel)
	lineLabel.position -= lineLabel.size/2
	lineLabels.append(lineLabel)
