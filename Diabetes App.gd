extends Node2D

# Setting all variables
onready var display = "" 
onready var current = $Carbs

#This bool sets the start of the program
var start = true

var carb = 0
var ins_carb_ratio = 40 #Curent default value

var carb_insulin = 0

var bg = 0
var target = 0
var ammount_corr = 0
var corr_factor = 175 #Current default value

var corr_insulin = 0

var total = 0
var totalstr = ""
var dot_pos = 0

var first_two_dec = ""
var up_one = 0
var rounded_total = 0

var format_result = "CARB INSULIN IS  %f\nCORRECTION INSULIN IS  %f\nTOTAL INSULIN DOSE IS  %f\n\nROUNDED DOSE IS "

#Built-in function that runs every frame (60 times/second)
func _process(delta): 
	display = PoolStringArray($Container/ButtonGrid.numbers).join("")
	active_field()

	if start == true:
		$Restart.visible = false
		$Instructions.text = "ENTER CARBS"
		$Instructions.rect_position = Vector2(45,25) 

#Updates display in active field
func active_field():
	for button in $Container/ButtonGrid.get_children():
		if button is Button: 
			current.text = display

#Clears temporary storage array for button inputs
func clear_temp_var():
		$Container/ButtonGrid.numbers = []
		display = ""

#Calculates formula using data from user
func calculate_totals():
	carb_insulin = float(carb) / float(ins_carb_ratio)
	ammount_corr = float(bg) - float(target)
	#No negative values
	if ammount_corr <= 0:
		ammount_corr = 0
	corr_insulin = float(ammount_corr) / float(corr_factor)
	total = float(carb_insulin) + float(corr_insulin)
	#For debugging:
	print("the CARB INSULIN is", carb_insulin)
	print("the CORRECTION INSULIN is", corr_insulin)
	print("the TOTAL INSULIN DOSE is", total)
	
	#Convering total to a string, and extracting decimal
	totalstr = str(total)
	dot_pos = totalstr.find(".")
	
	#Extracting first two decimals
	first_two_dec = totalstr.substr((int(dot_pos)+1), (int(dot_pos)+1))
	#This is needed to fix issue where GDscript defaults .90 to .9
	if first_two_dec.length() == 1:
		first_two_dec = first_two_dec + "0" 
	
	#For debuging
	print(first_two_dec)
	
	print("\n")
	
	if int(first_two_dec) >= 75:
		up_one = int(totalstr.substr(0,dot_pos)) + 1
		rounded_total = str(up_one)
		print("rounded total is ", rounded_total, " because decimal is over .75")
	elif int(first_two_dec) >= 26:
		rounded_total = totalstr.substr(0,dot_pos)+".5"
		print("rounded total is", rounded_total, "because decimal is over .26")
	elif int(first_two_dec) <= 25:
		rounded_total = totalstr.substr(0,dot_pos)
		print("rounded total is", rounded_total, "because decimal is .25 or under")


func clear_field():
	clear_temp_var()

#This is the main function that goes through the fields
func move_to_next():

	if current == $Carbs:
		start = false    #leaves process delta      
		carb = current.text #sets carb 
		current.clear() #cleares current 
		$Carbs.text = carb
		current = $InsulineCarbRatio
		current.text = ""
		$Instructions.text = "ENTER INSULIN \nTO CARB RATIO"
		$Instructions.rect_position = Vector2(170,10)
		clear_temp_var()

	elif current == $InsulineCarbRatio:
		ins_carb_ratio = current.text
		current.clear()
		$InsulineCarbRatio.text = ins_carb_ratio
		current = $BloodSugar
		$Instructions.text = "ENTER BLOOD\nSUGAR"
		$Instructions.rect_position = Vector2(1,140) 
		clear_temp_var()

	elif current == $BloodSugar:
		bg = current.text
		current.clear()
		$BloodSugar.text = bg
		current = $Target
		$Instructions.text = "ENTER TARGET\nBLOOD SUGAR"
		$Instructions.rect_position = Vector2(110,140) 
		clear_temp_var()

	elif current == $Target:
		target = current.text
		current.clear()
		$Target.text = target
		current = $CorrectionFactor
		$Instructions.text = "ENTER\nCORRECTION\nFACTOR"
		$Instructions.rect_position = Vector2(235,120) 
		clear_temp_var()

	elif current == $CorrectionFactor:
		corr_factor = current.text
		current.clear()
		$CorrectionFactor.text = corr_factor
		calculate_totals()
		$Results.text = format_result % [carb_insulin, corr_insulin, total]
		$Dose.text = rounded_total
		$Instructions.visible = false
		$Restart.visible = true

#Built in functions that signal when buttons are pressed
func _on_Chk_button_down():
	if $Container/ButtonGrid.numbers.size() >= 1:
		move_to_next()

func _on_Del_button_down():
	if current != $CorrectionFactor:
		clear_field()

func _on_Restart_button_down():
	get_tree().reload_current_scene()
