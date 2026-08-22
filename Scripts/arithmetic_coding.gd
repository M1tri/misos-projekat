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
	arithmeticCodingVisualizer.finished_step.connect(next_code_step)
	arithmeticCodingVisualizer.finished_coding.connect(finish_coding)
	
	arithmetic_notebook = get_tree().get_first_node_in_group("ArithmeticNotebook")
	
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
		"1) Za svaki simbol određuje se broj njegovih pojavljivanja u ulaznom nizu.",
		2.0
		)
	
	await arithmetic_notebook.displayed_text
	
	var button_begin : Button = arithmetic_notebook.add_button("Zapocni brojanje")
	await button_begin.pressed
	
	input_pos = 0
	inputAnalysisTimer.start()
	
func _on_input_analysis_timer_timeout() -> void:
	if input_pos >= input_text.length():
		finish_input_analysis()
		return
	
	var nextChar : String = input_text[input_pos]
	
	symbolTable.process_symbol(nextChar)
	inputDisplay.highlight_char(input_pos)
	
	input_pos += 1
	
	inputAnalysisTimer.start()

func finish_input_analysis():
	inputDisplay.reset_highlight()
	
	arithmetic_notebook.clear_text()
	arithmetic_notebook.clear_buttons()
	
	arithmetic_notebook.display_text(
		"2) Nakon toga, neophodno je da odredimo verovatnoće za svaki simbol. " +
		"Verovatnoća simbola dobija se deljenjem broja njegovih pojavljivanja " + 
		"sa ukupnim brojem simbola u ulaznom nizu.\n\tP(s) = broj pojavljivanja simbola / ukupan broj simbola",
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
		"Na primer za simbol " + input_text[0] + ", broj njegovih pojavljivanja je " + 
		str(first_count) + ", a ulazni niz je dužine " + str(input_text.length()) + ", pa je na osnovu formule:" +
		"\n\tP(" + input_text[0] + ") = " + str(first_count) + " / " + str(input_text.length()) + " = " 
		+ str(count[input_text[0]]).pad_decimals(2),
		2.0
	)
	
	await arithmetic_notebook.displayed_text
	symbolTable.change_symbol_counter_text(input_text[0], str(count[input_text[0]]).pad_decimals(2))
	
	arithmetic_notebook.clear_buttons()
	button = arithmetic_notebook.add_button("Zavrsi racunanje verovatnoca")
	
	await button.pressed
	
	for c in count:
		symbolTable.change_symbol_counter_text(c, str(count[c]).pad_decimals(2))
	
	arithmetic_notebook.clear_text()
	arithmetic_notebook.clear_buttons()
	
	arithmetic_notebook.display_text(
		"3) Početni interval [0,1) deli se prema verovatnoćama simbola. " +
		"Za svaki simbol izračunava dužina podintervala po formuli:\n" +
		"(G−D)⋅P(s)\nG - gornja granica intervala\nD - donja granica intervala " + 
		"Dodavanjem te dužine na trenutnu poziciju dobija se gornja granica podintervala. ",
		2.0
	)
	
	await arithmetic_notebook.displayed_text
	await arithmetic_notebook.add_button("Dalje").pressed
	
	var unique : Array[String] = count.keys()
	
	const max_primer : int = 2
	var prev : float = 0
	for i in range(0, unique.size()):
		if i >= max_primer:
			break
		var cur : String = unique[i]
		
		var msg : String = ""
		msg += "Simbol " + str(cur) + ":\n"
		msg += "Trenutna pozicija: " + str(prev) + "\n"
		msg += "(G - D) * P(" + cur + ") = (1 - 0) * " + str(count[cur]).pad_decimals(2) + " = " + str(count[cur]).pad_decimals(2) + "\n"
		var new : float = prev + count[cur]
		msg += str(prev).pad_decimals(2) + " + " + str(count[cur]).pad_decimals(2) + " = " + str(new).pad_decimals(2)
		prev = new
		
		arithmetic_notebook.clear_buttons()
		arithmetic_notebook.display_text(
			msg,
			2.0
		)
		await arithmetic_notebook.displayed_text
		await arithmetic_notebook.add_button("Dalje").pressed
	
	arithmeticCodingVisualizer.beggin_compression(input_text)
	input_pos = 0

func next_code_step(number_line : ArithmeticNumberLine):
	inputDisplay.highlight_char(input_pos)
	arithmetic_notebook.clear_text()
	arithmetic_notebook.clear_buttons()
	
	if input_pos == input_text.length()-1:
		arithmetic_notebook.display_text(
			"5) Došli smo do poslednjeg simbola u nizu a to je " + input_text[input_pos] + ". " +
			"Potrebno je da izaberemo bilo koji broj iz njegovog podintervala i taj broj će " +
			"jednoznačno predstavljati ulazni niz. Ovde se, radi ilustracije, bira se sredina intervala.",
			3.0
		)
		await arithmetic_notebook.displayed_text
		
		await arithmetic_notebook.add_button("Odredi sredinu").pressed
		arithmeticCodingVisualizer.next_step()
		return
	
	if input_pos == 0:
		arithmetic_notebook.display_text(
			"4) Za svaki simbol bira se njegov podinterval, koji postaje novi trenutni interval " +
			"i ponovo se deli prema verovatnoćama simbola. Tako se interval postepeno sužava.",
			1.0
		)
		await arithmetic_notebook.displayed_text
		await arithmetic_notebook.add_button("Dalje").pressed
		arithmetic_notebook.clear_buttons()
	
	arithmetic_notebook.clear_text()
	
	var curr : String = input_text[input_pos]
	
	var subinterval : Array[float] = number_line.get_symbol_numeric_interval(curr)
	arithmetic_notebook.display_text(
		"Sada obrađujemo simbol " + curr + " i ulazimo u njegov podinterval. " +
		"Podintervali se određuju po istom principu samo je sada " + 
		"\nD = " + str(subinterval[0]).pad_decimals(6) + "\nG = " + str(subinterval[1]).pad_decimals(6),
		2.0
	)
	
	var button : Button = arithmetic_notebook.add_button("Udji u podinterval za simbol " + curr)
	
	await button.pressed
	arithmeticCodingVisualizer.next_step()
	input_pos += 1

func finish_coding(code : float):
	arithmetic_notebook.append_text(
		"\nKod za niz " + input_text + " je: " + str(code).pad_decimals(6),
		2.0
	)


func highlight(text_pos : int):
	inputDisplay.highlight_char(text_pos)
