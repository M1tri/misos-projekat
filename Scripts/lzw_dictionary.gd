class_name LZWDictionary
extends VBoxContainer

var alphabet : String = "abcdefghijklmnopqrstuvwxyz"
var dict : Dictionary[String, int] = {}
var next_code : int

var symbol_labels : Array[Label] = []

func _ready() -> void:
	init_dict()

func init_dict():
	var start_ascii : int = 65
	for letter in alphabet:
		dict[letter] = start_ascii
		start_ascii += 1
	next_code = 256

func reset():
	dict.clear()
	init_dict()
	
	for label in symbol_labels:
		label.queue_free()
	symbol_labels.clear()

func contains(symbol : String) -> bool:
	return symbol in dict

func get_code(symbol : String) -> int:
	if symbol not in dict:
		return -1
	return dict[symbol]

func containts_code(code : int) -> bool:
	for symbol in dict:
		if dict[symbol] == code:
			return true
	return false

func get_symbol(code : int) -> String:
	for symbol in dict:
		if dict[symbol] == code:
			return symbol
			
	return ""

func add_symbol(symbol : String):
	dict[symbol] = next_code
	next_code += 1

func add_row(columns : Array[String]):
	var row : LZWTabelRow = LZWTabelRow.new(columns)
	add_child(row)
