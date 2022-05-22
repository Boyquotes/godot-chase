extends YSort

onready var arrow_cap = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func fire_arrow(arrow):
	add_child(arrow)
	
func destroy_arrow(arrow):
	remove_child(arrow)
	arrow.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_child_count() > arrow_cap:
		var arr = get_children()[0]
		destroy_arrow(arr)
