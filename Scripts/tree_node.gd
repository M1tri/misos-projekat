class_name ShannonTreeNode
extends Node2D

var target_pos : Vector2

var leftChild : ShannonTreeNode = null
var rightChild : ShannonTreeNode = null

var text : String = ""

var radius : int = 48

@onready var body : Polygon2D = $Polygon2D
@onready var label : Label = $Label

@onready var outline : Line2D = $Line2D

func _ready() -> void:
	label.text = text
	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	var points = PackedVector2Array()
	var seg : int = 32
	
	var step : float = 2*PI/seg
	for i in range(seg+1):
		var angle = i * step
		points.append(radius * Vector2(cos(angle), sin(angle)))
	
	#body.polygon = points
	outline.points = points
	outline.default_color = Color.BLACK
	outline.width = 4
	outline.antialiased = true
