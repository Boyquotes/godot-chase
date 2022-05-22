extends ColorRect


export (float) onready var ratio = 1.0
export (Dictionary) onready var cutoffs # = {"low": 0, "med": 0.33, "high": 0.67}
export (Dictionary) onready var colors # = {"low": Color(255, 0, 0), "med": Color(255, 255, 0),  "high": Color(0, 255, 0)}

onready var sldr = $ColorRect
export onready var max_size = sldr.get_rect().size

# Called when the node enters the scene tree for the first time.
func _ready():
	update_bar(ratio)
	
func update_bar(new_ratio):
	ratio = new_ratio
	
	if ratio > cutoffs["high"]:
		sldr.color = colors["high"]
	elif ratio > cutoffs["med"]:
		sldr.color = colors["med"]
	elif ratio > cutoffs["low"]:
		sldr.color = colors["low"]
		
	sldr.set_size(Vector2(max_size.x * ratio, max_size.y))
