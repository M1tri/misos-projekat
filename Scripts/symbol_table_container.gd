class_name SymbolTableContainer
extends Control

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
		
		counterLabel.add_theme_color_override("font_color", Color.RED)
		var colorTween : Tween = counterLabel.create_tween()
		colorTween.tween_property(counterLabel, "theme_override_colors/font_color", Color.WHITE, 0.5)

const SYMBOL_FONT_SIZE : int = 38

var symbols : Dictionary[String, Symbol] = {}

func process_symbol(symbolText : String):
	if symbolText in symbols:
		symbols[symbolText].inc_count()
		return
	
	var width : float = size.x
	var height : float = size.y
	
	@warning_ignore("integer_division")
	var symbol_x_pos : int = int(width) / 5
	var symbol_y_pos : int = (SYMBOL_FONT_SIZE + 2) * symbols.size()
	
	var newSymbol : Label = Label.new()
	newSymbol.text = symbolText
	newSymbol.add_theme_font_size_override("font_size", SYMBOL_FONT_SIZE)
	
	newSymbol.position.x = -SYMBOL_FONT_SIZE
	newSymbol.position.y = symbol_y_pos
	newSymbol.modulate.a = 0
	
	var tweenPos : Tween = create_tween()
	tweenPos.tween_property(newSymbol, "position", Vector2(symbol_x_pos, symbol_y_pos), 0.5)
	
	var tweenOpacity : Tween = create_tween()
	tweenOpacity.tween_property(newSymbol, "modulate:a", 1, 0.5)
	
	var symbolCounterLabel : Label = Label.new() 
	symbolCounterLabel.add_theme_font_size_override("font_size", SYMBOL_FONT_SIZE)

	symbolCounterLabel.position.x = -SYMBOL_FONT_SIZE
	symbolCounterLabel.position.y = symbol_y_pos
	symbolCounterLabel.modulate.a = 0
	
	var tweenPosCounter : Tween = create_tween()
	tweenPosCounter.tween_property(symbolCounterLabel, "position", Vector2(symbol_x_pos+45, symbol_y_pos), 1.0)
	
	var tweenOpacityCounter : Tween = create_tween()
	tweenOpacityCounter.tween_property(symbolCounterLabel, "modulate:a", 1, 0.8)
	
	add_child(newSymbol)
	add_child(symbolCounterLabel)
	
	symbols[symbolText] = Symbol.new(symbolText, newSymbol, symbolCounterLabel)

func sort():
	var symbolsArray : Array[Symbol] = symbols.values()
	
	symbolsArray.sort_custom(func (s1 : Symbol, s2 : Symbol): return s1.symbolCount > s2.symbolCount)
	
	for i in range(0, symbolsArray.size()):
		var target_y_pos : float = (SYMBOL_FONT_SIZE + 2) * i
		
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
