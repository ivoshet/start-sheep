# HUD
extends CanvasLayer

signal start_game
var lives_number:int = 3

onready var lives_counter = [
	$MarginContainer/HBoxContainer/LiveCounter/L1,
	$MarginContainer/HBoxContainer/LiveCounter/L2,
	$MarginContainer/HBoxContainer/LiveCounter/L3
]

func show_message(message):
	$MessageLabel.text = message
	$MessageLabel.show()
	$MessageTimer.start()

func update_score(value):
	$MarginContainer/HBoxContainer/ScoreLabel.text = str(value)
	
func update_lives(value):
	for item in range(lives_number):
		lives_counter[item].visible = value > item
		
func game_over():
	show_message("Game Over")
	yield($MessageTimer, "timeout")
	$StartButton.show()
		
func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("start_game")
	
func _on_MessageTimer_timeout():
	$MessageLabel.hide()
	$MessageLabel.text = ''
