class_name SymbolTableContainer
extends Control

const SYMBOL_FONT_SIZE_DEFAULT : int = 48
const SYMBOL_COUNTER_DISTANCE : int = 40
const DISTANCE_FROM_TABLE_TOP : int = 50
const SYMBOL_SPACING : int = 5

var active_font_size : int = SYMBOL_FONT_SIZE_DEFAULT

var clip : Sprite2D

var symbols : Dictionary[String, Symbol] = {}

class Symbol:
	var symbolText : String
	var symbolCount : int
	var textLabel : Label
	var counterLabel : Label
	
	func _init(_symbolText : String, _textLabel : Label, _counterLabel : Label) -> void:
		symbolText = _symbolText
		symbolCount = 1
		
		textLabel = _textLabel
		textLabel.text = symbolText
		
		counterLabel = _counterLabel
		counterLabel.text = str(symbolCount)
	
	func inc_count():
		symbolCount += 1
		counterLabel.text = str(symbolCount)
		
		counterLabel.pivot_offset = counterLabel.size / 2
		
		counterLabel.add_theme_color_override("font_color", Color.RED)
		var colorTween : Tween = counterLabel.create_tween()
		colorTween.tween_property(counterLabel, "theme_override_colors/font_color", Color.BLACK, 0.5)
		
		counterLabel.scale = Vector2(2, 2)
		var scaleTween : Tween = counterLabel.create_tween()
		scaleTween.tween_property(counterLabel, "scale", Vector2(1, 1), 0.5)
		
		var rotationTween : Tween = counterLabel.create_tween()
		rotationTween.tween_property(counterLabel, "rotation", deg_to_rad(-10), 0.25)
		rotationTween.tween_property(counterLabel, "rotation", deg_to_rad(10), 0.25)
		rotationTween.tween_property(counterLabel, "rotation", 0, 0.25)

func _ready() -> void:
	for child in get_children():
		if child is Sprite2D:
			clip = child as Sprite2D

func _draw() -> void:
	if clip:
		clip.position.x = self.size.x/2

func calculate_y_pos(elementNumber : int):
	return DISTANCE_FROM_TABLE_TOP + (active_font_size + SYMBOL_SPACING) * elementNumber

func adjust_font_size(max_elements : int):
	var max_y_pos : int = calculate_y_pos(max_elements)
	while max_y_pos > (size.y - active_font_size):
		active_font_size -= 1
		max_y_pos = calculate_y_pos(max_elements)

func process_symbol(symbolText : String):
	if symbolText in symbols:
		symbols[symbolText].inc_count()
		return
	
	var width : float = size.x
	
	@warning_ignore("integer_division")
	var symbol_x_pos : int = int(width) / 2
	var symbol_y_pos : int = calculate_y_pos(symbols.size())
	
	var newSymbol : Label = Label.new()
	newSymbol.text = symbolText
	newSymbol.add_theme_font_size_override("font_size", active_font_size)
	newSymbol.add_theme_color_override("font_color", Color.BLACK)
	
	@warning_ignore("integer_division")
	var newSymbolTargetPos : Vector2 = Vector2(
		symbol_x_pos - newSymbol.size.x/2 - SYMBOL_COUNTER_DISTANCE,
		symbol_y_pos
	)
	
	newSymbol.position.x = -active_font_size
	newSymbol.position.y = symbol_y_pos
	newSymbol.modulate.a = 0
	
	var tweenPos : Tween = create_tween()
	tweenPos.tween_property(newSymbol, "position", newSymbolTargetPos, 0.5)
	
	var tweenOpacity : Tween = create_tween()
	tweenOpacity.tween_property(newSymbol, "modulate:a", 1, 0.5)
	
	var symbolCounterLabel : Label = Label.new() 
	symbolCounterLabel.add_theme_font_size_override("font_size", active_font_size)
	symbolCounterLabel.add_theme_color_override("font_color", Color.BLACK)
	
	@warning_ignore("integer_division")
	var symbolCounterLabelTargetPos : Vector2 = Vector2(
		symbol_x_pos + symbolCounterLabel.size.x/2 + SYMBOL_COUNTER_DISTANCE/2,
		symbol_y_pos
	)
	
	symbolCounterLabel.position.x = -active_font_size
	symbolCounterLabel.position.y = symbol_y_pos
	symbolCounterLabel.modulate.a = 0
	
	symbolCounterLabel.position = Vector2(symbolCounterLabel.position.x, symbolCounterLabel.position.y)

	var tweenPosCounter : Tween = create_tween()
	tweenPosCounter.tween_property(symbolCounterLabel, "position", symbolCounterLabelTargetPos, 1.0)
	
	var tweenOpacityCounter : Tween = create_tween()
	tweenOpacityCounter.tween_property(symbolCounterLabel, "modulate:a", 1, 0.8)
	
	add_child(newSymbol)
	add_child(symbolCounterLabel)
	
	symbols[symbolText] = Symbol.new(symbolText, newSymbol, symbolCounterLabel)

func sort():
	var symbolsArray : Array[Symbol] = symbols.values()
	
	symbolsArray.sort_custom(
		func (s1 : Symbol, s2 : Symbol): 
			return s1.symbolCount > s2.symbolCount
			)
	
	for i in range(0, symbolsArray.size()):
		var target_y_pos : float = calculate_y_pos(i)
		
		var textLabelTween : Tween = symbolsArray[i].textLabel.create_tween()
		textLabelTween.tween_property(
			symbolsArray[i].textLabel,
			"position:y",
			target_y_pos,
			1.0
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
		
		var counterLabelTween : Tween = symbolsArray[i].counterLabel.create_tween()
		counterLabelTween.tween_property(
			symbolsArray[i].counterLabel,
			"position:y",
			target_y_pos,
			1.0
		).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)

func reset():
	for symbol : Symbol in symbols.values():
		symbol.counterLabel.queue_free()
		symbol.textLabel.queue_free()
	
	symbols.clear()
