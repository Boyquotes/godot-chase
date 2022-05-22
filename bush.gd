extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var health = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	name = "Obstacle"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		get_parent().remove_child(self)
		queue_free()
	elif health < 20:
		$AnimatedSprite.play("rock_broken")
