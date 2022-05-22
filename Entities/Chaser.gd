extends "res://entity.gd"

enum chaser_types {NORMAL, TELEPORTER, LANCER}
export (chaser_types) onready var chstype = chaser_types.TELEPORTER

onready var target = mru.get_node("PlayerObj")
onready var ticker = 0

enum modes {IDLE, CHASE, CHARGE}
onready var mode = modes.CHASE

onready var switch_readiness = 1
onready var chase_period = rand_range(0.95, 1.05)
onready var charge_intensity = rand_range(0.95, 1.2) * 1.5

onready var teleport_readiness = 0.8
onready var teleport_position = Vector2.ZERO

func _ready():
	enemy_type = enemy_archetypes.MELEE
	coll_type = ss.STOP
	if randf() < 0.5:
		position = Vector2(rand_range(-500, 500), rand_range(-500, -100))
	else:
		position = Vector2(rand_range(-500, 500), rand_range(100, 500))

func animate():
	match chstype:
		chaser_types.NORMAL:
			if mode == modes.CHARGE:
				$AnimatedSprite.play("chaser_charge")
			elif switch_readiness > 0.05:
				$AnimatedSprite.play("chaser_charging")
			else:
				$AnimatedSprite.play("chaser")
		chaser_types.TELEPORTER:
			if teleport_readiness > 0.05:
				$AnimatedSprite.play("teleporter_blink")
			elif mode == modes.CHARGE:
				$AnimatedSprite.play("teleporter_charging")
			elif switch_readiness > 0.05:
				$AnimatedSprite.play("teleporter_charge")
			else:
				$AnimatedSprite.play("teleporter")
		chaser_types.LANCER:
			pass

# Called when the node enters the scene tree for the first time.
func ai_state_change(delta):
	match mode:
		modes.CHASE:
			if ticker >= 3 * chase_period:
				mode = modes.CHARGE
				ticker = 0
			elif abs(ticker - 2.5 * chase_period) < delta:
				switch_readiness = 0.5
		modes.CHARGE:
			if ticker >= 4 * chase_period and randf() < 0.1:
				mode = modes.CHASE
				ticker = 0
			elif (position - target.position).length() > 600 * chase_period:
				if true: #velocity.angle_to(target.position) - PI / 2 < PI:
					mode = modes.CHASE
					ticker = 0
		modes.IDLE: # Stay still for a short while after the player is hit.
			if ticker >= 2 * chase_period:
				mode = modes.CHASE
				ticker = 0
			elif velocity != Vector2.ZERO:
				velocity = Vector2.ZERO
		_:
			mode = modes.CHASE

func start_charge():
	var pos = position	
	var goal = (target.position - position)
	goal.x += target.velocity.x * 2
	goal.y += target.velocity.y * 2
	
	var d = pos.distance_to(goal)
	var ang = goal.angle()
	
	velocity.x = (100 * goal.x * max(d / 70, 1) + (goal.x - pos.x) * charge_intensity / 4)
	velocity.y = (100 * goal.y * max(d / 70, 1) + (goal.y - pos.y) * charge_intensity / 4)
	
func teleport(inclusive=false, is_random=false, reset=true):
	if is_random:
		teleport_position = target.position + Vector2.UP.rotated(rand_range(0, 2 * PI)) * rand_range(300, 1500)
	else:
		var avg_pos = Vector2.ZERO
		var chaser_count = 0
		
		for ene in get_parent().get_children():
			if ene.get_class() == "Chaser" or inclusive:
				chaser_count += 1
				avg_pos += ene.position
			
		avg_pos /= chaser_count
		var angle = (avg_pos - target.position).angle() + PI
		
		teleport_position = target.position + (target.position - avg_pos).normalized() * rand_range(250, 800)
		
	teleport_position += Vector2(rand_range(-100, 100), rand_range(-100, 100))
	if teleport_readiness <= 0 and reset:
		teleport_readiness = chase_period * 0.77

func ai_update1(delta): #Normal Chaser
	ticker += delta
	if switch_readiness > 0:
		switch_readiness -= delta
		
	if mode == modes.CHASE:
		velocity = (target.position - position) / 6
	elif mode == modes.CHARGE:
		if ticker == 0:
			start_charge()
		else:
			velocity *= 1.1
			
func ai_update2(delta): #Teleporter Chaser
	
	if teleport_readiness > 0:
		teleport_readiness -= delta
		
	ai_update1(delta)
	
	if mode != modes.CHASE and teleport_readiness > 0.1: teleport_readiness = 0.7
	
	if position.x < -1700 or position.x > 1700 or position.y < -1700 or position.y > 1700:
		teleport(false, true)
		position = teleport_position
	elif teleport_readiness > -0.4 and teleport_readiness < delta:
		position = teleport_position
		teleport_readiness = -2
	elif randf() < 0.001 and teleport_readiness < 0 and ticker > 1.2 * chase_period:
		if randf() < 0.8:
			teleport(false, true) 
		else:
			teleport(true)
	
func _manage_collide(coll, delta):
	match chstype:
		chaser_types.TELEPORTER:
			teleport(true)
		_: 
			pass
	
func hurt_player():
	mode = modes.IDLE
	ticker = 0
	target.take_damage(35)
	
	if chstype == chaser_types.TELEPORTER:
		teleport(true)
	
func ai_update(delta):
	match chstype:
		chaser_types.NORMAL: 
			ai_update1(delta)
		chaser_types.TELEPORTER: 
			ai_update2(delta)
		_: pass
		
	facing = PI / 2 + velocity.angle()
	animate()
