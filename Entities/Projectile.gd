extends Area2D


var velocity = Vector2.ZERO
var is_infected = false
var is_bullet = false
var origin = null
onready var parens = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	name = "Projectile"

func update_arrow(delta):
	position += velocity * delta
	
	if is_bullet:
		velocity *= 1.01
	
func infect():
	modulate = Color(255, 0, 0)
	is_infected = true
	scale *= 2

func uninfect():
	modulate = Color(255, 255, 255)
	is_infected = false
	scale /= 2

func store_arrow():
	parens.remove_child(self)
	return self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):

	update_arrow(delta)
	var ob = get_overlapping_bodies()

	if origin != null:
		if origin.target in ob:
			var dmg
			if is_bullet:
				dmg = 22
			else:
				dmg = 11
				
			if is_infected:
				dmg += 4
				
			origin.hurt_player(dmg)
				
			parens.destroy_arrow(self)
			
	for o in ob:
		if o.get_class() != origin.get_class():
			parens.destroy_arrow(self)
			
	var oa = get_overlapping_areas()
		
	for o in oa:
		if o.name == "Obstacle":
			parens.destroy_arrow(self)
			o.health -= 5
		
