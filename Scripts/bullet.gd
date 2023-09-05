extends Node3D

const bullet_speed = 60.0
var num = 0
@onready var mesh = $MeshInstance3D
@onready var ray_cast = $RayCast3D
@onready var particles = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += transform.basis * Vector3(0, 0, -bullet_speed) * delta
	if ray_cast.is_colliding():
		mesh.visible = false
		particles.emitting = true
		if ray_cast.get_collider().is_in_group("enemy"):
			print("bullet hit")
			await get_tree().create_timer(1.0).timeout
			queue_free()
		

func _on_timer_timeout():
	queue_free() # Replace with function body.
