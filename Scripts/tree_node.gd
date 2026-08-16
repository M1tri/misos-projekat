class_name ShannonTreeNode
extends Node2D

signal draw_line(node1 : ShannonTreeNode, node2 : ShannonTreeNode)

var target_pos : Vector2

var leftChild : ShannonTreeNode = null
var rightChild : ShannonTreeNode = null

var text : String = ""

const DEFAULT_RADIUS : int = 48
var radius : float = DEFAULT_RADIUS

@onready var body : Polygon2D = $Polygon2D
@onready var label : Label = $Label

@onready var outline : Line2D = $Line2D

@onready var hitboxCollsionShape : CollisionShape2D = $Hitbox/CollisionShape2D

func _ready() -> void:
	label.text = text
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	draw_outline(radius, Color.BLACK)
	
	var circle_shape : CircleShape2D = CircleShape2D.new()
	circle_shape.radius = radius
	hitboxCollsionShape.shape = circle_shape
	
	if leftChild:
		draw_line.emit(self, leftChild)
	
	if rightChild:
		draw_line.emit(self, rightChild)

func draw_outline(r : float, color : Color):
	var points = PackedVector2Array()
	var seg : int = 32
	
	var step : float = 2*PI/seg
	for i in range(seg+1):
		var angle = i * step
		points.append((r) * Vector2(cos(angle), sin(angle)))
	
	outline.points = points
	outline.default_color = color
	outline.width = 4
	outline.antialiased = true

func _on_hitbox_mouse_entered() -> void:
	draw_outline(DEFAULT_RADIUS+5, Color.RED)

func _on_hitbox_mouse_exited() -> void:
	draw_outline(DEFAULT_RADIUS, Color.BLACK)
