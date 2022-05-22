extends "res://entity.gd"

enum modes {IDLE, GRAVITY, SEIZE, ANTIGRAVITY, SPRAY}
onready var mode = modes.IDLE

onready var mode_ticker = 0
onready var mode_ticker2 = 0
onready var gravity = randf() < 0.5
onready var angle_tilt = randf() * PI * 2
onready var fire_rate = 0.3

onready var target = mru.get_node("PlayerObj")
onready var arrow_cache = mru.get_node("Level/ProxCache")

onready var num_arrows = 0
onready var stored_arrows = []

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_type = enemy_archetypes.RANGER
	coll_type = ss.STOP
	if randf() < 0.5:
		position = Vector2(rand_range(-1000, 1000), rand_range(-1000, -300))
	else:
		position = Vector2(rand_range(-1000, 1000), rand_range(300, 1000))


func ai_state_change(delta):
	match mode:
		modes.IDLE:
			if fmod(mode_ticker, 4) < delta or randf() < fmod(mode_ticker, 10) / 400:
				if num_arrows == 0:
					mode = modes.SEIZE
				else:
					mode = [modes.GRAVITY, modes.ANTIGRAVITY][randi() % 2]
				mode_ticker = 0
			elif mode_ticker2 < delta:
				position = Vector2(rand_range(-1000, 1000), rand_range(-1000, 1000))
				mode_ticker2 = 5
		modes.SEIZE:
			if mode_ticker > 4 or randf() < fmod(mode_ticker, 10) / 500 or stored_arrows.size() > num_arrows * 0.64:
				mode = [modes.GRAVITY, modes.ANTIGRAVITY][randi() % 2]
				mode_ticker = 0
		modes.GRAVITY:
			if num_arrows == 0 or fmod(mode_ticker, 5) < delta:
				mode = [modes.SPRAY, modes.ANTIGRAVITY][randi() % 2]
				mode_ticker = 0
		modes.ANTIGRAVITY:
			if num_arrows == 0:
				mode = modes.SEIZE
				mode_ticker = 0
			elif fmod(mode_ticker, 4) < delta:
				mode = [modes.IDLE, modes.GRAVITY][randi() % 2]
				mode_ticker = 0
		modes.SPRAY:
			if num_arrows == 0 or fmod(mode_ticker, 3.1) < 3:
				mode = modes.SEIZE
				mode_ticker = 0
		_:
			mode = modes.IDLE
			mode_ticker = 0
	
	
func ai_update(delta):
	mode_ticker += delta
	mode_ticker2 -= delta
	angle_tilt += rand_range(-0.2, 0.2)
	print(mode)
	
	num_arrows = 0
	for a in arrow_cache.get_children():
		if a.is_infected:
			num_arrows += 1
			if mode != modes.SPRAY and position.distance_to(a.position) < 120:
				stored_arrows.append(a.store_arrow())
	
	match mode:
		modes.SEIZE:
			if fmod(mode_ticker, 3) > delta:
				if arrow_cache.get_child_count() > 0:
					var i = randi() % arrow_cache.get_child_count()
					arrow_cache.get_child(i).infect()
		modes.GRAVITY:
			if mode_ticker < delta:
				for a in arrow_cache.get_children():
					if a.is_infected:
						var ang = position - a.position
						a.velocity = Vector2(3 * cos(ang), 3 * sin(ang))
		modes.ANTIGRAVITY:
			if mode_ticker < delta:
				for a in arrow_cache.get_children():
					if a.is_infected:
						var ang = a.position - position
						a.velocity = Vector2(3 * cos(ang), 3 * sin(ang))
		modes.SPRAY:
			if fmod(mode_ticker, fire_rate) < 0.05:
				var shots = (randi() + 2) % int(stored_arrows.size() / 3 + 1)
				var shot_ones = []
							
				for j in range(shots):
					var a = stored_arrows.pop_back()
					shot_ones.append(a)
					
				for i in range(shots):
					shot_ones[i].velocity.x = 5 * cos(angle_tilt + i * PI / 8)
					shot_ones[i].velocity.y = 5 * sin(angle_tilt + i * PI / 8)
					arrow_cache.fire_arrow(shot_ones[i])
					
			
			if stored_arrows.size() < 2:
				mode = modes.SEIZE
		_:
			pass
			
	if stored_arrows.size() > 10:
		mode = modes.SPRAY


func hurt_player():
	pass
	
func _manage_collide(coll, delta):
	if num_arrows > 2:
		mode = modes.GRAVITY
		mode_ticker = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
