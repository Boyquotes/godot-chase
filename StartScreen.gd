extends CanvasLayer


onready var active = true

# Called when the node enters the scene tree for the first time.
func _ready():
	hide2()

func hide_all():
	$Start.hide()
	$Transition.hide()
	$Pause.hide()
	$GameOver.hide()
	$Win.hide()
	$Help.hide()

func hide():
	$Start.hide()
	$Start/Planet/Particles2D.emitting = false
	$Start/Planet2/Particles2D.emitting = false
	active = false
	
func hide2():
	$Transition.hide()
	active = false
	
func hide3():
	$Pause.hide()
	active = false
	
func open_trans():
	hide_all()
	$Transition.show()
	active = true
	
func open_start():
	hide_all()
	$Start.show()
	$Start/Planet/Particles2D.emitting = true
	$Start/Planet2/Particles2D.emitting = true
	active = true
	
func open_pause():
	hide_all()
	$Pause.show()
	active = true
	
func open_win():
	hide_all()
	$Win.show()
	active = true
	
func open_loss():
	hide_all()
	$GameOver.show()
	active = true
	
func open_help():
	hide_all()
	$Help.show()
	active = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
