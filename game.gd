extends Node2D

enum {
	CHASER, TELEPORTER, LANCER,
	ARCHER, VORTAL, SPRAYER, SNIPER,
	TRAPPER, LASERIST, GHOST}

onready var level_layouts = {
	"aquaduct" : preload("res://Levels/aquaduct.tscn"),
	"cavern" : preload("res://Levels/cavern.tscn"),
	"islands" : preload("res://Levels/islands.tscn"),
	"puddles" : preload("res://Levels/puddles.tscn"),
	"rivers" : preload("res://Levels/rivers.tscn"),
	"tutorial" : preload("res://Levels/tutorial.tscn"),
}

onready var levels = {
	0 : {"name": "Tutorial", "time": 10, "enemies":[], "transition" : false, "layout" : "tutorial"},
	1 : {"name": "Chased", "time": 30, "enemies":[CHASER], "transition" : false, "layout" : "puddles"},
	2 : {"name": "Make It Double", "time": 30, "enemies":[CHASER, TELEPORTER], "transition" : false, "layout" : "cavern"},
	3 : {"name": "Arrows", "time": 30, "enemies":[ARCHER], "transition" : false, "layout" : "islands"},
	4 : {"name": "Melee and Ranged", "time": 30, "enemies":[ARCHER, CHASER], "transition" : false, "layout" : "puddles"},
	5 : {"name": "Constraints", "time": 40, "enemies":[CHASER], "transition" : false, "layout" : "islands"},
	6 : {"name": "A Different Axis", "time": 30, "enemies":[SPRAYER, CHASER], "transition" : false, "layout" : "puddles"},
	7 : {"name": "Archer Team", "time": 45, "enemies":[SPRAYER, ARCHER, ARCHER], "transition" : false, "layout" : "puddles"},
	8 : {"name": "Four Man Army", "time": 30, "enemies":[SPRAYER, ARCHER, ARCHER], "transition" : false, "layout" : "puddles"},
	9 : {"name": "Sniper", "time": 30, "enemies":[SNIPER, CHASER], "transition" : false, "layout" : "rivers"},
	10 : {"name": "Containment", "time": 30, "enemies":[SPRAYER, ARCHER], "transition" : false, "layout" : "islands"},
	11 : {"name": "Arrowmancy", "time": 20, "enemies":[SPRAYER, ARCHER, SPRAYER, VORTAL], "transition" : false, "layout" : "rivers"},
	12 : {"name": "Sunday", "time": 20, "enemies":[SNIPER, TELEPORTER, SNIPER], "transition" : false, "layout" : "rivers"},
	13 : {"name": "Barrage", "time": 50, "enemies":[ARCHER, ARCHER, ARCHER, ARCHER, ARCHER], "transition" : false, "layout" : "rivers"},
	14 : {"name": "Most Sniped", "time": 40, "enemies":[SNIPER, SNIPER, SNIPER, SNIPER], "transition" : false, "layout" : "rivers"},
	15 : {"name": "Marching On", "time": 50, "enemies":[CHASER, TELEPORTER, TELEPORTER, TELEPORTER], "transition" : false, "layout" : "rivers"},
	16 : {"name": "Everyone is Here", "time": 60, "enemies":[SPRAYER, ARCHER, CHASER, TELEPORTER, TELEPORTER, SNIPER, VORTAL], "transition" : false, "layout" : "puddles"},
}

onready var num_levels = levels.size()

onready var timer = $Timer
onready var transtimer = 4

onready var HUD = $CanvasLayer
onready var LevelCounter = $CanvasLayer/LevelLabel
onready var TimeWatcher = $CanvasLayer/TimerLabel

export (int) onready var starting_level = 0
onready var current_level = starting_level

enum gm {START, PLAY, PAUSE, TRANS, WIN, LOSE, HELP}
onready var mode = gm.START

const ChaserEnemy = preload("res://Entities/Chaser.tscn")
const ArcherEnemy = preload("res://Entities/Archer.tscn")
const VortalEnemy = preload("res://Entities/Vortal.tscn")

const Bush = preload("res://bush.tscn")

onready var high_score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

# Place into effect the initial state of the game.
func new_game():
	print("Starting game.")
	mode = gm.START
	$StartScreen.open_start()

func reset_game():
	scrub_data()
	$PlayerObj.health = $PlayerObj.max_health
	current_level = starting_level
	new_game()
	randomize()
	
func scrub_data():
	for o in $Obstacles.get_children():
		$Obstacles.remove_child(o)
		o.queue_free()
		
	for p in $Level/ProxCache.get_children():
		$Level/ProxCache.remove_child(p)
		p.queue_free()
		
	for e in $Level/Enemies.get_children():
		$Level/Enemies.remove_child(e)
		e.queue_free()
	
###############################################################################
	
# Change level
func start_level(lvl):
	if lvl == 0:
		$Tutorial.show()
	
	current_level = lvl
	LevelCounter.text = "Level " + String(current_level) +\
	 " - " + levels[current_level]["name"]
	
	timer.start(levels[current_level]["time"])
	
	replace_environment(levels[current_level]["layout"])
	new_data()
	$PlayerObj.position = Vector2.ZERO
	
	if lvl % 5 == 0:
		 $PlayerObj.health = $PlayerObj.max_health
		 $PlayerObj.energy = $PlayerObj.max_energy
	
func place_enemy(ene):
	var et
	match ene:
		CHASER:
			et = ChaserEnemy.instance()
			$Level/Enemies.add_child(et)
			et.chstype = et.chaser_types.NORMAL
		TELEPORTER:
			et = ChaserEnemy.instance()
			$Level/Enemies.add_child(et)
		ARCHER:
			et = ArcherEnemy.instance()
			$Level/Enemies.add_child(et)
			et.archtype = et.archer_types.NORMAL
		SPRAYER:
			et = ArcherEnemy.instance()
			$Level/Enemies.add_child(et)
			et.archtype = et.archer_types.SPRAYER
		SNIPER:
			et = ArcherEnemy.instance()
			$Level/Enemies.add_child(et)
			et.archtype = et.archer_types.SNIPER
		VORTAL:
			et = VortalEnemy.instance()
			$Level/Enemies.add_child(et)
		_:
			et = ChaserEnemy.instance()
			$Level/Enemies.add_child(et)
			et.chstype = et.chaser_types.NORMAL
	
func replace_environment(env_type):
	print(env_type)
	#if env_type in level_layouts.keys():
	var newenv = level_layouts[env_type].instance()
	newenv.name = "Environment"
	var currenv = $Level/Environment
	$Level.remove_child(currenv)
	currenv.queue_free()
	
	$Level.add_child(newenv)
	$Level.move_child(newenv, 0)
	
		
func new_data():
	scrub_data()
	
	place_enemies()
	place_obstacles()
	
func place_obstacles():
	for i in range(randi() % 40):
		var bush = Bush.instance()
		$Obstacles.add_child(bush)
		bush.position = Vector2(rand_range(-1500, 1500), rand_range(-1500, 1500))
	
func place_enemies():
	for ene in levels[current_level]["enemies"]:
		place_enemy(ene)
		
###############################################################################

func start_game():
	start_level(0)
	
func timer_change():
	TimeWatcher.text = "Time: " + String(round(timer.time_left))
	
func next_level():
	if current_level == 0:
		$Tutorial.hide()
	
	if current_level < num_levels - 1:
		start_level(current_level + 1)
		transition()
	else:
		game_won()
	
func breakthrough():
	pass

func transition():
	mode = gm.TRANS
	timer.stop()
	$StartScreen/Transition/Label.text = "Next Level - " +\
	 String(levels[current_level]["name"])
	$StartScreen.open_trans()

func end_transition():
	mode = gm.PLAY
	$StartScreen.hide2()
	timer.start(levels[current_level]["time"])

func game_won():
	print("Victory!")
	mode = gm.WIN
	$StartScreen.open_win()

func game_lost():
	print("You died.")
	mode = gm.LOSE
	$StartScreen.open_loss()
	
	if current_level > high_score:
		high_score = current_level

###############################################################################

func _process(delta):
	match mode:
		gm.START:
			if Input.is_action_just_released("ui_accept"):
				mode = gm.PLAY
				start_game()
				$StartScreen.hide()
			elif Input.is_action_just_released("enter_help"):
				mode = gm.HELP
				$StartScreen.open_help()
		gm.PAUSE:
			if Input.is_action_just_released("ui_cancel"):
				timer.start()
				mode = gm.PLAY
				$StartScreen.hide3()
		gm.PLAY:
			if Input.is_action_just_released("ui_cancel"):
				timer.stop()
				mode = gm.PAUSE
				$StartScreen.open_pause()
		gm.TRANS:
			if Input.is_action_just_released("ui_accept"):
				end_transition()
		gm.WIN:
			if Input.is_action_just_released("ui_accept"):
				reset_game()
		gm.LOSE:
			if Input.is_action_just_released("ui_accept"):
				reset_game()
		gm.HELP:
			if Input.is_action_just_released("ui_cancel"):
				mode = gm.START
				$StartScreen.open_start()
		_:
			pass
	
	timer_change()

func _on_Timer_timeout():
	scrub_data()
	next_level()
	

func _on_PlayerObj_player_killed():
	game_lost()
