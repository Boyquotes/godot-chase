extends "res://entity.gd"

export (float) onready var speed = 120 
export (float) onready var dash_strength = 17.5
export (float) onready var dash_length = 0.5

export (float) onready var max_energy = 100
onready var energy = max_energy

onready var dash_timer = 0
onready var dashing = false

onready var invincibility = 1

signal player_damaged
signal player_killed

func _ready():
	type = et.MOB

func input(delta):
	if Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_right"):
		velocity.x = 0
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	elif Input.is_action_pressed("ui_right"):
		velocity.x = speed
	else:
		velocity.x = 0
		
	if Input.is_action_pressed("ui_up") and Input.is_action_pressed("ui_down"):
		velocity.y = 0
	elif Input.is_action_pressed("ui_up"):
		velocity.y = -speed
	elif Input.is_action_pressed("ui_down"):
		velocity.y = speed
	else:
		velocity.y = 0		
		
	if Input.is_action_just_pressed("player_dash") and\
			 dash_timer <= 0 and not dashing and energy > 15:
		dash_timer = dash_length
		dashing = true
	elif Input.is_action_just_released("player_dash") or energy < 0: 
		dash_timer = 0
		dashing = false
	elif dash_timer > 0 and dashing:
		dash_timer -= 1 * delta
	
	if dash_timer > 0.05:
		velocity *= dash_strength * (dash_timer + 0.1)
	elif dashing:
		velocity *= dash_strength * 0.1		
	
func ai_update(delta):
	input(delta)
	
	if dashing:
		if dash_timer > 0.05:
			energy -= dash_timer * 1.5
		else:
			energy -= 0.1
	elif energy < max_energy:
		energy += 5 * delta
		
	if health < max_health:
		health += max(energy / max_energy, 0.3) * 3 * delta
		
	self.show()
		
	if invincibility > 0: 
		invincibility -= delta
		if int(invincibility * 100) % 5 < 3:
			self.hide()	
			
	if not dashing and energy < 10:
		velocity /= 2

func take_damage(dmg):
	if invincibility <= 0 and dash_timer < 0.1:
		health -= dmg
		emit_signal("player_damaged")
		invincibility = 1
		
	if health <= 0:
		emit_signal("player_killed")
	
