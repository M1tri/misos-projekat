class_name ShannonTableLable
extends Label

func _ready() -> void:
	
	var style : StyleBoxFlat = StyleBoxFlat.new()
	
	add_theme_color_override("font_color", Color.BLACK)
	
	style.draw_center = false
	
	style.border_width_top = 0
	style.border_width_left = 0
	style.border_width_right = 0
	style.border_width_bottom = 2
	
	style.border_color = Color.BLACK
	
	add_theme_stylebox_override("normal", style)
