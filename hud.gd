extends CanvasLayer


# Notifies `Main` node that the button has been pressed
signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Get Ready Boss!"
	$AbilityCooldown.text = ""
	$AbilityCooldown.hide()
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(score):
	$ScoreLabel.text = str(score)
	
func update_ability_timer(time):
	if time <= 0.0:
		$AbilityCooldown.text = "Ability Ready"
	else:
		$AbilityCooldown.text = "Ability CD: %.1f s" % time

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	$StartButton.hide()
	$AbilityCooldown.show()
	start_game.emit()


func _on_message_timer_timeout() -> void:
	$Message.hide()
