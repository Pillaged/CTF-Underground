extends StaticBody2D
var tile_size = 64
var flag_picked_up = false

export var team = "blue"

# Called when the node enters the scene tree for the first time.
func _ready():
	position = (position - Vector2.ONE * tile_size/2).snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	$AnimatedSprite.play(team)

func _process(delta):
	pass

func interact(player):
	if not flag_picked_up and player.can_pickup_flag():
		flag_picked_up = true
		player.set_held_flag(team, self)
	
func return_flag():
	flag_picked_up = false
	$AnimatedSprite.play(team)
