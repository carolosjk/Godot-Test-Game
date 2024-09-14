extends Area2D
signal hit

var hud

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var bullet_scene: PackedScene  # Drag and drop your Bullet.tscn here
var screen_size # Size of the game window.
var last_direction: Vector2 = Vector2.RIGHT  # Store the last movement direction
var ability_cooldown_timer: Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()
	ability_cooldown_timer = $AbilityCooldownTimer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("use_ability") and ability_cooldown_timer.is_stopped():
		use_ability()

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		last_direction = velocity.normalized()  # Update last direction when moving
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0
		
	if not ability_cooldown_timer.is_stopped():
		var remaining_time = round_to_dec(ability_cooldown_timer.time_left,1)
		get_parent().get_node("HUD").update_ability_timer(remaining_time)
	else:
		get_parent().get_node("HUD").update_ability_timer(0)
		
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _on_body_entered(_body: Node2D) -> void:
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred("disabled",true)
	
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_shoot_timer_timeout() -> void:
	_shoot_bullet()

func _shoot_bullet() -> void:
	# Create a new bullet instance
	var bullet = bullet_scene.instantiate()

	# Set the bullet's starting position to the player's position
	bullet.position = position

	# Get the mouse position in the viewport
	var mouse_position = get_viewport().get_mouse_position()

	# Calculate the direction from the player to the mouse
	var direction = (mouse_position - position).normalized()

	# Set the bullet's velocity in the direction of the mouse
	bullet.velocity = direction * bullet.speed

	# Rotate the bullet to face the direction it is moving
	bullet.rotation = direction.angle()

	# Add the bullet to the scene (parent scene, e.g., Main or World)
	get_parent().add_child(bullet)

var ability

func use_ability() -> void:
	var num_bullets = 18
	var angle_step = 2 * PI / num_bullets
	for i in range(num_bullets):
		var bullet = bullet_scene.instantiate()
		var angle = i * angle_step
		bullet.position = position
		var direction = Vector2(cos(angle), sin(angle))
		bullet.velocity = direction * bullet.speed
		bullet.rotation = angle
		get_parent().add_child(bullet)

	# Start cooldown timer
	ability_cooldown_timer.start()
