extends CanvasLayer

onready var player = get_parent().get_node("PlayerObj")

var blink_health = 0
var blink = 0

func update_bars():
	$HealthBar.update_bar(player.health / player.max_health)
	$EnergyBar.update_bar(player.energy / player.max_energy)

func _process(delta):
	update_bars()
	
	if blink_health > 0:
		blink_health -= delta
		if blink % 6 > 3:
			$HealthBar.sldr.color = Color(255, 255, 255)
			
	if player.dashing:
		$EnergyBar.sldr.color = Color(255, 255, 255)
		
	blink += 6 * delta


func _on_PlayerObj_player_damaged():
	blink_health = 1.5
