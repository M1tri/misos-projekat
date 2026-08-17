class_name ArithmeticCodingVisualizer
extends Control

const PADDING : int = 50

var number_lines : Array[ArithmeticNumberLine] = []

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

func arithmetic_compress(message : String):
	var symbol_percentages : Dictionary[String, float] = {}
	
	for s in message:
		if s in symbol_percentages:
			symbol_percentages[s] += 1
		else:
			symbol_percentages[s] = 1
	
	for s in symbol_percentages:
		symbol_percentages[s] = symbol_percentages[s] / message.length()
		print(s + " : " + str(symbol_percentages[s]))
	print("----------------")
	
	var points : Array[float] = get_points(0, 1, symbol_percentages)
	var symbols : Array[String] = symbol_percentages.keys()
	
	draw_number_line(points, symbols)
	
	for i in range(0, message.length()):
		await get_tree().create_timer(4).timeout
		var pos : int = symbols.find(message[i])
		
		assert(pos != -1, "Should not happen, every symbol from message has to be here")
		
		await add_lines(number_lines.back().get_symbol_interval(message[i]))
		
		var start : float = points[pos]
		var end : float = points[pos+1]
		
		points = get_points(start, end, symbol_percentages)
		draw_number_line(points, symbols)

func add_lines(symbolInterval : Array[float]):
		var lastNumberLine : ArithmeticNumberLine = number_lines.back()
		var startLine : Line2D = Line2D.new()
		
		var startLineStart : Vector2 = Vector2(
			lastNumberLine.position.x + symbolInterval[0], 
			lastNumberLine.position.y
		)
		
		var startLineEnd : Vector2 = Vector2(
			size.x/10, 
			lastNumberLine.position.y + (lastNumberLine.TOTAL_HEIGHT + PADDING)
		)
		
		startLine.width = 4
		startLine.default_color = Color.RED
		startLine.points = [
			startLineStart, 
			startLineStart
			]
		
		var startLineTween : Tween = startLine.create_tween()
		startLineTween.tween_method(
			func (t):
				startLine.points[1] = lerp(startLineStart, startLineEnd, t),
			0.0,
			1.0,
			.5
		)
		
		add_child(startLine)
		
		var endLine : Line2D = Line2D.new()
		
		var endLineStart : Vector2 = Vector2(
			lastNumberLine.position.x + symbolInterval[1], 
			lastNumberLine.position.y
		) 
		
		var endLineEnd : Vector2 = Vector2(
			size.x/10 + lastNumberLine.lineLength, 
			lastNumberLine.position.y + (lastNumberLine.TOTAL_HEIGHT + PADDING)
		)
	
		endLine.width = 4
		endLine.default_color = Color.RED
		endLine.points = [
			endLineStart,
			endLineStart
			]
		add_child(endLine)
		
		var endLineTween : Tween = startLine.create_tween()
		endLineTween.tween_method(
			func (t):
				endLine.points[1] = lerp(endLineStart, endLineEnd, t),
			0.0,
			1.0,
			.5
		)
		
		var mockInterval : Line2D = Line2D.new()
		mockInterval.default_color = Color.REBECCA_PURPLE
		mockInterval.width = 6
		
		var beggining_x_start : float = startLineStart.x
		var beggining_x_end : float = startLineEnd.x
		
		var ending_x_start : float = endLineStart.x
		var ending_x_end : float = endLineEnd.x
		
		mockInterval.points = [
			Vector2(beggining_x_start, lastNumberLine.position.y),
			Vector2(ending_x_start, lastNumberLine.position.y)
		]
		
		add_child(mockInterval)
		
		var mockIntervalTween : Tween = mockInterval.create_tween()
		await mockIntervalTween.tween_method(
			func (t):
				mockInterval.points[0] = lerp(
					Vector2(beggining_x_start, lastNumberLine.position.y),
					Vector2(beggining_x_end, lastNumberLine.position.y + (lastNumberLine.TOTAL_HEIGHT + PADDING)),
					t
				)
				mockInterval.points[1] = lerp(
					Vector2(ending_x_start, lastNumberLine.position.y),
					Vector2(ending_x_end, lastNumberLine.position.y + (lastNumberLine.TOTAL_HEIGHT + PADDING)),
					t
				),
				0.0,
				1.0,
				0.5
		).finished

func get_points(start : float, end : float, symbol_percentages) -> Array[float]:
	var points : Array[float] = []
	points.append(start)
	
	var index : int = 1
	for s in symbol_percentages:
		points.append(points[index-1] + (end-start) * symbol_percentages[s])
		print(s + " : " + str(points[index]))
		index += 1
	
	return points

func draw_number_line(points : Array[float], symbols : Array[String]):
	var numberLine : ArithmeticNumberLine = ArithmeticNumberLine.new()
	numberLine.position.y = (number_lines.size() + 1) * (numberLine.TOTAL_HEIGHT + PADDING)
	
	numberLine.position.x = size.x/10.0
	numberLine.lineLength = size.x - 2*(size.x/10)
	
	add_child(numberLine)
	number_lines.append(numberLine)
	numberLine.draw_number_line(points, symbols)
