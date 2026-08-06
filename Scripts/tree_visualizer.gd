class_name ShannonTreeVisualizer
extends Control

const Y_STEP = 100
const X_STEP = 100

var current_leaf : int = 0
var leaf_count : int = 0

var tree_nodes : Array[ShannonTreeNode] = []

func reset():
	for tree_node in tree_nodes:
		tree_node.queue_free()
	tree_nodes.clear()
	queue_redraw()

func DrawTree(root : ShannonTreeNode):
	reset()
	leaf_count = CountLeaves(root)
	current_leaf = 0
	
	AssignPositions(root, 0)
	
	AnimateTree(root, 0)


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


func AnimateTree(node : ShannonTreeNode, depth : int):
	node.radius -= 2*depth
	add_child(node)
	tree_nodes.append(node)
	
	await get_tree().create_timer(1).timeout
	if node.leftChild:
		node.leftChild.position = node.position
		AnimateTree(node.leftChild, depth + 1)
	
	await get_tree().create_timer(1).timeout
	if node.rightChild:
		node.rightChild.position = node.position
		AnimateTree(node.rightChild, depth + 1)
