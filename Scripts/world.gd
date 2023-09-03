extends Node3D

@onready var crosshair = $UI/TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	crosshair.position.x = get_viewport().size.x / 2 - 32
	crosshair.position.y = get_viewport().size.y / 2 - 32


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
