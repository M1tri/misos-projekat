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

func _draw() -> void:
	draw_grid()

func reset():
	for tree_node in tree_nodes:
		tree_node.queue_free()
	tree_nodes.clear()
	sequence.clear()
	sequence_pos = -1
	
	queue_redraw()

func DrawTree(root : ShannonTreeNode):
	reset()
	
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
		add_child(node)
		tree_nodes.append(node)
	
	sequence_pos += 1
	return false

func draw_grid():
	var cell_size : Vector2i = Vector2i(25, 25)
	
	@warning_ignore("integer_division", "narrowing_conversion")
	var x_step_count : int = self.size.x / cell_size.x

	@warning_ignore("integer_division", "narrowing_conversion")
	var y_step_count : int = self.size.y / cell_size.y
	
	for x in range(0, x_step_count):
		draw_line(Vector2(x*cell_size.x, 0), Vector2(x*cell_size.x, self.size.y), Color.GRAY)
	
	for y in range(0, y_step_count):
		draw_line(Vector2(0, y*cell_size.y), Vector2(self.size.x, y*cell_size.y), Color.GRAY)
