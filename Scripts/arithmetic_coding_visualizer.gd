class_name ArithmeticCodingVisualizer
extends Control

const TOP_PADDING : int = 50

var number_lines : Array[ArithmeticNumberLine] = []
var numberLine_spacing : float

func _draw() -> void:
	draw_grid()

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

func reset():
	for n in number_lines:
		n.queue_free()
	number_lines.clear()

func calculate_numberLine_spacing(total_lines : int):
	var total_space : float = (size.y - TOP_PADDING)
	var space_per_line : float = total_space / total_lines
	numberLine_spacing = space_per_line

func get_number_line_y_pos(prev_number_lines):
	return TOP_PADDING + prev_number_lines * numberLine_spacing

func arithmetic_compress(message : String):
	reset()
	calculate_numberLine_spacing(message.length())
	var symbol_percentages : Dictionary[String, float] = {}
	
	for s in message:
		if s in symbol_percentages:
			symbol_percentages[s] += 1
		else:
			symbol_percentages[s] = 1
	
	for s in symbol_percentages:
		symbol_percentages[s] = symbol_percentages[s] / message.length()
		#print(s + " : " + str(symbol_percentages[s]))
	#print("----------------")
	
	var points : Array[float] = get_points(0, 1, symbol_percentages)
	var symbols : Array[String] = symbol_percentages.keys()
	
	draw_number_line(points, symbols)
	await get_tree().create_timer(4).timeout

	for i in range(0, message.length()-1):
		var pos : int = symbols.find(message[i])
		
		assert(pos != -1, "Should not happen, every symbol from message has to be here")
		
		await add_lines(number_lines.back().get_symbol_interval(message[i]))
		
		var start : float = points[pos]
		var end : float = points[pos+1]
		
		points = get_points(start, end, symbol_percentages)
		draw_number_line(points, symbols)
		await get_tree().create_timer(4).timeout
	
	number_lines.back().mark_interval_midpoint(message[message.length()-1])

func add_lines(symbolInterval : Array[float]):
		var lastNumberLine : ArithmeticNumberLine = number_lines.back()
		
		var subIntervalStart : Vector2 = Vector2(
			lastNumberLine.position.x + symbolInterval[0], 
			lastNumberLine.position.y
		)
		
		var subIntervalEnd : Vector2 = Vector2(
			lastNumberLine.position.x + symbolInterval[1], 
			lastNumberLine.position.y
		)
		
		var nextNumberLineStart : Vector2 = Vector2(
			size.x/10,
			get_number_line_y_pos(number_lines.size())
		)
		
		var nextNumberLineEnd : Vector2 = Vector2(
			size.x - size.x/10,
			get_number_line_y_pos(number_lines.size())
		)
		
		var direction : Vector2 = nextNumberLineStart-subIntervalStart
		var start_line_slope : float = abs(direction.angle_to(Vector2.DOWN))
		var start_line_length : float = remap(start_line_slope, 0, PI/2, 0.8, 0.95)
		
		print("***")
		print(subIntervalStart)
		print(nextNumberLineStart)
		print(start_line_slope)
		print("***")
		
		draw_shortened_pointed_line(subIntervalStart, nextNumberLineStart, start_line_length, 2.0)
		
		direction = nextNumberLineEnd-subIntervalEnd
		var end_line_slope : float = abs(direction.angle_to(Vector2.DOWN))
		var end_line_length : float = remap(end_line_slope, 0, PI/2, 0.8, .95)
		
		draw_shortened_pointed_line(subIntervalEnd, nextNumberLineEnd, end_line_length, 2.0)
		
		var subIntervalLine : Line2D = Line2D.new()
		
		subIntervalLine.default_color = Color.REBECCA_PURPLE
		subIntervalLine.width = 6
		
		subIntervalLine.points = [
			subIntervalStart,
			subIntervalEnd
		]
		
		add_child(subIntervalLine)
		
		var subIntervalLineTween : Tween = subIntervalLine.create_tween()
		await subIntervalLineTween.tween_method(
			func (t):
				subIntervalLine.points[0] = lerp(
					subIntervalStart,
					nextNumberLineStart,
					t
				)
				subIntervalLine.points[1] = lerp(
					subIntervalEnd,
					nextNumberLineEnd,
					t
				),
				0.0,
				1.0,
				2.0
		).finished

func draw_shortened_pointed_line(start : Vector2, end : Vector2, length_percentage : float, growth_time : float):
	if length_percentage > 1.0:
		length_percentage = 1.0
	
	var line : Line2D = Line2D.new()
	
	var lineDirection : Vector2 = end-start
	var lineEnd = start + length_percentage*lineDirection
	
	line.width = 4
	line.default_color = Color.RED
	line.points = [
		start, 
		start
	]
	
	add_child(line)
	
	var lineTween : Tween = line.create_tween()
	await lineTween.tween_method(
		func (t):
			line.points[1] = lerp(
				start, 
				lineEnd, 
				t
			),
		0.0,
		1.0,
		growth_time
	).finished
	
	var arrow_dir : Vector2 = (lineEnd - start).normalized()
	var arrow_len : float = 20.0
	
	var arrow_tip1 : Vector2 = lineEnd + arrow_dir.rotated(deg_to_rad(180+45))*arrow_len
	var arrow_tip2 : Vector2 = lineEnd + arrow_dir.rotated(deg_to_rad(180-45))*arrow_len
	
	var arrow_line1 : Line2D = Line2D.new()
	
	arrow_line1.default_color = Color.RED
	arrow_line1.width = 3
	arrow_line1.points = [lineEnd, lineEnd]
	
	var arrow_line1Tween : Tween = create_tween()
	arrow_line1Tween.tween_method(
		func (t): arrow_line1.points[1] = lerp(lineEnd, arrow_tip1, t),
		0.0,
		1.0,
		.6
	)
	
	add_child(arrow_line1)
	
	var arrow_line2 : Line2D = Line2D.new()
	var arrow_line2Tween : Tween = create_tween()
		
	arrow_line2Tween.tween_method(
		func (t): arrow_line2.points[1] = lerp(lineEnd, arrow_tip2, t),
		0.0,
		1.0,
		.6
	)
	
	arrow_line2.default_color = Color.RED
	arrow_line2.width = 3
	arrow_line2.points = [lineEnd, arrow_tip2]
	
	add_child(arrow_line2)

func get_points(start : float, end : float, symbol_percentages) -> Array[float]:
	var points : Array[float] = []
	points.append(start)
	
	var index : int = 1
	for s in symbol_percentages:
		points.append(points[index-1] + (end-start) * symbol_percentages[s])
		#print(s + " : " + str(points[index]))
		index += 1
	
	return points

func draw_number_line(points : Array[float], symbols : Array[String]):
	var numberLine : ArithmeticNumberLine = ArithmeticNumberLine.new()
	numberLine.position.y = get_number_line_y_pos(number_lines.size())
	
	numberLine.position.x = size.x/10.0
	numberLine.lineLength = size.x - 2*(size.x/10)
	
	add_child(numberLine)
	number_lines.append(numberLine)
	numberLine.draw_number_line(points, symbols)
