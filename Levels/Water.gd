extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for bod in get_overlapping_bodies():
		if bod.get_name() == "PlayerObj":
			bod.energy -= 10 * delta
			if bod.dashing:
				bod.dash_timer -= delta
				bod.energy -= 10 * delta
				
