extends Area2D

@export var speed: float = 600.0  # Bullet speed

var velocity: Vector2

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	position += velocity * delta
	if not get_viewport_rect().has_point(position):
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	# If the bullet hits a mob, remove both the mob and the bullet
	if body.is_in_group("mobs"):
		body.queue_free()  # Destroy the mob
		queue_free()       # Destroy the bullet
		update_score(1)

func update_score(score: int) -> void:
	var main_scene = get_tree().root.get_node("Main")  # Adjust this path if needed
	if main_scene:
		main_scene.increase_score(score)
