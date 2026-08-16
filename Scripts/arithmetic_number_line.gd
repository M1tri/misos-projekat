class_name ArithmeticNumberLine
extends Node2D

var points : Array[float]
var lineLength : float = 200

func draw_number_line():
	add_vertical_line(0, 40)
	add_label(Vector2(0, -40), str(points[0]))
	var intervalEnd : Line2D = add_vertical_line(0, 40)
	
	var intervalEndTween : Tween = create_tween()
	intervalEndTween.tween_property(
		intervalEnd,
		"position:x",
		lineLength,
		1.5
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).finished.connect(
		func():
			add_label(Vector2(lineLength, -40), str(points.back()))
	)
	
	var baseLine : Line2D = Line2D.new()
	
	baseLine.points = [Vector2(0, 0), Vector2(0, 0)]
	baseLine.default_color = Color.BLACK
	baseLine.width = 6
	
	var baseLineTween : Tween = create_tween()
	baseLineTween.tween_method(
		func(t):
			baseLine.points[1] = Vector2(t, 0),
			0,
			lineLength,
			1.5
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).finished.connect(mark_points)
	
	add_child(baseLine)

func mark_points():
	var start : float = points.front()
	var end : float = points.back()
	
	var intervalSize : float = end-start
	
	for i in range(1, points.size()-1):
		var x_pos : float = ((points[i] - start) / intervalSize) * lineLength
		var line : Line2D = add_vertical_line(x_pos, 0)
		var lineTween : Tween = line.create_tween()
		lineTween.tween_method(
			func(t):
				line.points[0].y = -t/2
				line.points[1].y = t/2,
			0,
			20,
			1.6
		).set_trans(Tween.TRANS_BACK).finished.connect(
			func(): 
				add_label(Vector2(x_pos, -20), str(points[i]))
				)
		
		await get_tree().create_timer(0.4).timeout

func add_vertical_line(x_pos : float, total_height : float) -> Line2D:
	var line : Line2D = Line2D.new()
	line.points = [Vector2(x_pos, -total_height/2), Vector2(x_pos, total_height/2)]
	line.width = 6
	line.default_color = Color.BLACK
	add_child(line)
	
	return line

func add_label(pos : Vector2, text : String):
	var label : Label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color.BLACK)
	add_child(label)
	label.position = pos - label.size/2
