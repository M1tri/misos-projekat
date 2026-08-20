class_name LZWStepTable
extends VBoxContainer

var steps : Array[RichTextLabel] = []

func add_normal_step(p : String, c : String):
	var label : RichTextLabel = RichTextLabel.new()
	
	label.fit_content = true
	label.bbcode_enabled = true
	
	var text : String = str(steps.size()+1) + ") "
	text += "P = " + "[color=red]" + p + "[/color]" 
	text += ", C = " + "[color=blue]" + c + "[/color] | "
	text += "P + C = " + "[color=green]" + p + c + "[/color] (JESTE U REČNIKU) | "
	text += "P = " + "[color=green]" + p + c + "[/color]"
	
	label.text = text
	
	label.add_theme_font_size_override("normal_font_size", 24)
	label.add_theme_color_override("default_color", Color.BLACK)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	add_child(label)
	steps.append(label)

func add_output_step(p : String, c : String, output_code : String):
	var label : RichTextLabel = RichTextLabel.new()
	
	label.fit_content = true
	label.bbcode_enabled = true
	
	var text : String = str(steps.size()+1) + ") "
	text += "P = " + "[color=red]" + p + "[/color]" 
	text += ", C = " + "[color=blue]" + c + "[/color] | "
	text += "P + C = " + "[color=green]" + p + c + "[/color] (NIJE U REČNIKU) | "
	text += "Na izlazu kod za P: " + output_code + " | "
	text += "P = " + "[color=blue]" + c + "[/color]"
	
	label.text = text
	
	label.add_theme_font_size_override("normal_font_size", 24)
	label.add_theme_color_override("default_color", Color.BLACK)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	add_child(label)
	steps.append(label)

func reset():
	for step in steps:
		step.queue_free()
	steps.clear()
