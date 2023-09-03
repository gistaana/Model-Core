extends Node3D

const bullet_speed = 40.5
@onready var mesh = $MeshInstance3D
@onready var ray_cast = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0, 0, -bullet_speed) * delta
