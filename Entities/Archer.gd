extends "res://entity.gd"

enum archer_types {NORMAL, SPRAYER, SNIPER}
export (archer_types) onready var archtype = archer_types.NORMAL

onready var target = mru.get_node("PlayerObj")
onready var arrow_cache = mru.get_node("Level/ProxCache")
onready var mode_ticker = 0
onready var shot_ticker = 0

onready var circle_size = 500
onready var is_clockwise = (randf() < 0.5)

enum modes {IDLE, CIRCLE, GOTO}
onready var mode = modes.IDLE
onready var shooting = false

onready var goal = target.position
onready var fire_rate = 50

const ProjectileScene = preload("res://Entities/Projectile.tscn")

func _ready():
	enemy_type = enemy_archetypes.RANGER
	coll_type = ss.STOP
	if randf() < 0.5:
		position = Vector2(rand_range(-500, 500), rand_range(-800, -300))
	else:
		position = Vector2(rand_range(-500, 500), rand_range(300, 800))

func animate_change(state):
	if state:
		match archtype:
			archer_types.NORMAL:
				$AnimatedSprite.play("archer_fire")
			archer_types.SNIPER:
				$AnimatedSprite.play("sniper_fire")
			archer_types.SPRAYER:
				$AnimatedSprite.play("crazy_fire")
	else:
		match archtype:
			archer_types.NORMAL:
				$AnimatedSprite.play("archer")
			archer_types.SNIPER:
				$AnimatedSprite.play("sniper")
			archer_types.SPRAYER:
				$AnimatedSprite.play("spray")

func ai_state_change(delta):
	match mode:
		modes.IDLE:
			velocity = Vector2.ZERO
			if fmod(mode_ticker, 2) > 1.97:
				mode = modes.CIRCLE
				mode_ticker = 0
				goal = target.position
		modes.CIRCLE:
			if fmod(mode_ticker, 0.5) < delta * 2 and randf() < 0.05:
				mode_ticker = 0
				if randf() < 0.64:
					mode = modes.IDLE
				else:
					mode = modes.GOTO
					goal = target.position
		modes.GOTO:
			if fmod(mode_ticker, 200) < delta * 2:
				mode_ticker = 0
				if randf() < 0.64:
					mode = modes.CIRCLE
					goal = target.position
				else:
					mode = modes.IDLE
		_:
			mode = modes.IDLE
			
	#toggle shooting randomly
	if shooting:
		if randf() < 0.07:
			shooting = false
			shot_ticker = 0
			animate_change(false)
	else:
		if randf() < 0.1:
			shooting = true
			print("*%")
			animate_change(true)
	
func circle_target(delta):
	var trace = target.position - position
	var ang = trace.angle()
	
	var r_ang
	if is_clockwise:
		r_ang = ang - PI / 2
	else:
		r_ang = ang + PI / 2
		
	var dist = trace.length()
	
	velocity.x = (400 / max(dist, 40)) * cos(r_ang) * 100
	velocity.y = (400 / max(dist, 40)) * sin(r_ang) * 100
	
	#if dist > 1200:
	#	goal = target.position + Vector2(rand_range(-400, 400), rand_range(-400, 400))
	#	mode = modes.GOTO
	
func make_arrow(dx, dy, is_bullet=false):
	var prox = ProjectileScene.instance()
	prox.is_bullet = is_bullet
	prox.velocity = Vector2(dx, dy)
	prox.origin = self
	prox.position = position
	
	arrow_cache.fire_arrow(prox)
	
func shoot(delta):
	
	if shooting:
		if fmod(shot_ticker, fire_rate) < 0.15 and randf() < 0.3:
			if archtype == archer_types.SNIPER:
				if randf() < 0.2:
					var ang = atan2(target.position.y - position.y + target.velocity.y / 2,
									target.position.x - position.x + target.velocity.x / 2)
									
					make_arrow(1400 * cos(ang), 1400 * sin(ang), true)
			else:
				var ang = (target.position - position).angle()
				
				if archtype == archer_types.SPRAYER:
					ang = rad2deg(ang) + rand_range(-0.1, 0.1)
				
				make_arrow(500 * cos(ang), 500 * sin(ang))
				make_arrow(500 * cos(ang - PI / 7), 500 * sin(ang - PI / 7))
				make_arrow(500 * cos(ang + PI / 7), 500 * sin(ang + PI / 7))
	
func ai_update(delta):
	mode_ticker += delta
	shot_ticker += delta
	
	if mode == modes.CIRCLE:
		circle_target(delta)
	elif mode == modes.GOTO:
		var trace = (goal - position)
		if mode_ticker == 0:
			var ang = trace.angle()
			ang += randf() * 2 - 1
			var mult = rand_range(100, 200)
			
			goal = position + Vector2(mult * cos(ang), mult * sin(ang))
			
		velocity = trace / 120
		
	shoot(delta)
	
	if archtype == archer_types.SPRAYER:
		if randf() < 0.006 and mode != modes.GOTO:
			mode = modes.GOTO
			goal = target.position
			mode_ticker = 0
		if randf() < 0.2 and shooting:
			shot_ticker -= delta
			
		facing = 90 + rad2deg(position.angle_to(target.position))
	else:
		facing = (target.position - position).angle() + PI / 2
			
	
func _manage_collide(coll, delta):
	mode = modes.GOTO
	goal = target.position + Vector2.UP.rotated(randf() * PI * 2) * rand_range(350, 1100)
	mode_ticker = 0
	
func hurt_player(dmg=10):
	mode = modes.IDLE
	mode_ticker = 0
	target.take_damage(dmg)
	

	
