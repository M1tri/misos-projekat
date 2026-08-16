class_name ArithmeticCodingVisualizer
extends Control

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

func draw_number_line():
	var numberLine : ArithmeticNumberLine = ArithmeticNumberLine.new()
	numberLine.position.y = size.y/2
	
	numberLine.position.x = size.x/10.0
	numberLine.lineLength = size.x - 2*(size.x/10)
	
	numberLine.points = [0, 0.2, 0.4, 0.6, 0.8, 1.0]
	add_child(numberLine)
	numberLine.draw_number_line()
