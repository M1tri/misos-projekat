class_name SymbolTableContainer
extends Control

signal finished_sorting

const SYMBOL_FONT_SIZE_DEFAULT : int = 38

var active_font_size : int = SYMBOL_FONT_SIZE_DEFAULT

var clip : Sprite2D

func _ready() -> void:
	for child in get_children():
		if child is Sprite2D:
			clip = child as Sprite2D

func _draw() -> void:
	if clip:
		clip.position.x = self.size.x/2

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

var symbols : Dictionary[String, Symbol] = {}

func adjust_font_size(max_elements : int):
	var max_y_pos : int = 25 + (active_font_size+2) * max_elements
	while max_y_pos > (size.y - active_font_size):
		active_font_size -= 1
		max_y_pos = (active_font_size+2) * max_elements

func process_symbol(symbolText : String):
	if symbolText in symbols:
		symbols[symbolText].inc_count()
		return
	
	var width : float = size.x
	
	@warning_ignore("integer_division")
	var symbol_x_pos : int = int(width) / 2
	var symbol_y_pos : int = 25 + (active_font_size + 2) * symbols.size()
	
	var newSymbol : Label = Label.new()
	newSymbol.text = symbolText
	newSymbol.add_theme_font_size_override("font_size", active_font_size)
	newSymbol.add_theme_color_override("font_color", Color.BLACK)
	
	newSymbol.position.x = -active_font_size
	newSymbol.position.y = symbol_y_pos
	newSymbol.modulate.a = 0
		
	var tweenPos : Tween = create_tween()
	tweenPos.tween_property(newSymbol, "position", Vector2(symbol_x_pos-20, symbol_y_pos), 0.5)
	
	var tweenOpacity : Tween = create_tween()
	tweenOpacity.tween_property(newSymbol, "modulate:a", 1, 0.5)
	
	var symbolCounterLabel : Label = Label.new() 
	symbolCounterLabel.add_theme_font_size_override("font_size", active_font_size)
	symbolCounterLabel.add_theme_color_override("font_color", Color.BLACK)
	
	symbolCounterLabel.position.x = -active_font_size
	symbolCounterLabel.position.y = symbol_y_pos
	symbolCounterLabel.modulate.a = 0
	
	symbolCounterLabel.position = Vector2(symbolCounterLabel.position.x, symbolCounterLabel.position.y)

	var tweenPosCounter : Tween = create_tween()
	tweenPosCounter.tween_property(symbolCounterLabel, "position", Vector2(symbol_x_pos+20, symbol_y_pos), 1.0)
	
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
		var target_y_pos : float = (active_font_size + 2) * i
		
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
