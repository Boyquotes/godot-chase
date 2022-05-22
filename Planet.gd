extends StaticBody2D


onready var center = Vector2(350, 350)
export (float) onready var angle = position.angle_to(center)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	angle += PI * delta
	position.x = cos(angle) * 250 + center.x
	position.y = sin(angle) * 250 + center.y
