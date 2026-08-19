class_name ShannonTableLable
extends RichTextLabel

func _ready() -> void:
	
	self.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	
	var style : StyleBoxFlat = StyleBoxFlat.new()
	
	fit_content = true
	bbcode_enabled = true
	
	add_theme_font_size_override("normal_font_size", 24)
	add_theme_color_override("default_color", Color.BLACK)
	
	style.draw_center = false
	
	style.border_width_top = 0
	style.border_width_left = 0
	style.border_width_right = 0
	style.border_width_bottom = 2
	
	style.border_color = Color.BLACK
	
	add_theme_stylebox_override("normal", style)
