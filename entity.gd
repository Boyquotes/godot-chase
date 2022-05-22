extends KinematicBody2D

onready var facing = 0
onready var heading = 0

onready var velocity = Vector2.ZERO

export (float) onready var max_health = 100.0
onready var health = max_health

enum et {NONE, BUSH, MOB, ITEM}

enum enemy_archetypes {NONE, MELEE, RANGER, ASSASSIN}

onready var type = et.NONE
onready var enemy_type = enemy_archetypes.NONE

onready var mru = get_tree().get_root().get_node("Main")

enum ss {SLIDE, STOP}
export (ss) onready var coll_type

func _ready():
	pass
	
func ai_state_change(delta):
	pass
	
func ai_update(delta):
	pass
	
func take_damage(dmg):
	health -= dmg
	
func _act(delta):
	ai_state_change(delta)
	ai_update(delta)

func _manage_collide(coll, delta):
	pass

func _physics_process(delta):
	if mru.mode == mru.gm.PLAY:
		_act(delta)
		
		if coll_type == ss.SLIDE:
			var velo = move_and_slide(velocity, Vector2.UP)
			
			for i in range(get_slide_count()):
				var s = get_slide_collision(i)
				_manage_collide(s, delta)
		else:
			var colo = move_and_collide(velocity * delta)
			_manage_collide(colo, delta)
			
		rotation = facing
