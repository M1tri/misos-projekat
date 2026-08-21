extends Node2D

var symbolTable : SymbolTableContainer

var inputDisplay : InputDisplay

var input : LineEdit

@onready var start_button : Button = $GUI/HBoxContainer/InputAndVisual/Input/HBoxContainer/StartButton

@onready var inputAnalysisTimer : Timer = $InputAnalysisTimer

var arithmeticCodingVisualizer : ArithmeticCodingVisualizer

var arithmetic_notebook : ArithmeticNotebook

var input_text : String = ""
var input_pos : int = -1

@onready var text_count_label : Label = $GUI/HBoxContainer/InputAndVisual/Input/HBoxContainer/TextCount

func _ready() -> void:
	symbolTable = get_tree().get_first_node_in_group("SymbolTableContainer")
	symbolTable.set_column_name(1, "symbol")
	symbolTable.set_column_name(2, "frequency")
	
	inputDisplay = get_tree().get_first_node_in_group("InputDisplay")
	inputDisplay.set_new_input.connect(start_input_analysis)
	
	input = get_tree().get_first_node_in_group("Input")
	input.text_changed.connect(input_changed)
	
	arithmeticCodingVisualizer = get_tree().get_first_node_in_group("ACV")
	arithmeticCodingVisualizer.processing_symbol.connect(highlight)
	
	arithmetic_notebook = get_tree().get_first_node_in_group("ArithmeticNotebook")
	print(arithmetic_notebook)
	
	start_button.disabled = true

func input_changed(new_text : String):
	input_text = new_text
	
	if input_text.length() == 0:
		start_button.disabled = true
	else:
		start_button.disabled = false
	
	text_count_label.text = str(input_text.length()) + "/6"

func _on_start_button_pressed() -> void:
	symbolTable.reset()
	symbolTable.adjust_font_size(input_text.length())
	arithmeticCodingVisualizer.reset()
	inputDisplay.set_new_input_text(input_text)

func start_input_analysis():
	arithmetic_notebook.display_text(
		"Prvi korak je da vidimo koji sve karakteri ima i kolko put se svaki javlja",
		2.0
		)
	
	await arithmetic_notebook.displayed_text
	
	var button_begin : Button = arithmetic_notebook.add_button("Zapocni brojanje")
	await button_begin.pressed
	
	input_pos = 0
	inputAnalysisTimer.start()

func finish_input_analysis():
	inputDisplay.reset_highlight()
	
	arithmetic_notebook.clear_text()
	arithmetic_notebook.clear_buttons()
	
	arithmetic_notebook.display_text(
		"Nakon toga neophodno je da odredimo verovatnoce za svaki simbol " +
		"tako sto cemo broj pojavljivanja svakog simbola podeliti ukupnim brojem simbola.",
		2.0
	)
	
	await arithmetic_notebook.displayed_text
	
	var button : Button = arithmetic_notebook.add_button("Odredi verovatnoce")
	
	await button.pressed
	
	var count : Dictionary[String, float] = {}
	for c in input_text:
		if c in count:
			count[c] += 1.0
		else:
			count[c] = 1.0
	
	var first_count : int = count[input_text[0]] as int
	for c in count:
		count[c] = count[c] / input_text.length()
	
	arithmetic_notebook.display_text(
		"Na primer za simbol " + input_text[0] + " on se pojavljuje " + str(first_count) + " puta " +
		"a ukupan broj simbola je " + str(input_text.length()) + " , na osnovu toga njegovu verovatnocu racunamo kao " + 
		str(first_count) + "/" + str(input_text.length()) + " = " + str(count[input_text[0]]).pad_decimals(2), 
		2.0
	)
	
	await arithmetic_notebook.displayed_text
	symbolTable.change_symbol_counter_text(input_text[0], str(count[input_text[0]]).pad_decimals(2))
	
	arithmetic_notebook.clear_buttons()
	button = arithmetic_notebook.add_button("Zavrsi racunanje verovatnoca")
	
	await button.pressed
	
	for c in count:
		symbolTable.change_symbol_counter_text(c, str(count[c]).pad_decimals(2))
	
	symbolTable.sort()
	
	#arithmeticCodingVisualizer.arithmetic_compress(input_text)


func _on_input_analysis_timer_timeout() -> void:
	if input_pos >= input_text.length():
		finish_input_analysis()
		return
	
	var nextChar : String = input_text[input_pos]
	
	symbolTable.process_symbol(nextChar)
	inputDisplay.highlight_char(input_pos)
	
	input_pos += 1
	
	inputAnalysisTimer.start()

func highlight(text_pos : int):
	inputDisplay.highlight_char(text_pos)
