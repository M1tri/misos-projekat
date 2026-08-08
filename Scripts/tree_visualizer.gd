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
	NextStep()

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

func NextStep():
	if sequence_pos == -1 or sequence_pos >= sequence.size():
		return
	
	for node : ShannonTreeNode in sequence[sequence_pos].nodesToAdd: 
		add_child(node)
		tree_nodes.append(node)
	
	sequence_pos += 1

@onready var nextStepButton : Button = $"../VBoxContainer/NextStepButton"
@onready var nextStepTimer : Timer = $"../VBoxContainer/NextStepCooldown"

func _on_next_step_button_pressed() -> void:
	NextStep()
	nextStepButton.disabled = true
	nextStepTimer.start()

func _on_prev_step_button_pressed() -> void:
	var lastNode : ShannonTreeNode = tree_nodes.pop_back()
	if (lastNode != null):
		remove_child(lastNode)
		sequence_pos -= 1
