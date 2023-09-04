extends CharacterBody3D

var speed
const WALK = 5.0
const SPRINT = 9.0
const BOOST = 20.0
const JUMP_VELOCITY = 4.5
const MOUSESPEED = 0.003

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

const WALK_FOV = 75.0
const FOVMULTI = 1.5

var bullet = load("res://Scenes/bullet.tscn")
var bullet2 = load("res://Scenes/bullet_2.tscn")
var energyattack = load("res://Scenes/energyattack.tscn")
var inst

@onready var head := $Head # connects to the node which is a child to characterbody3d
@onready var camera := $Head/Camera3D
@onready var gun_anim := $"Head/Camera3D/Steampunk Rifle/AnimationPlayer"
@onready var gun2_anim :=$"Head/Camera3D/Steampunk Rifle2/AnimationPlayer"
# @onready var melee_anim := $"Head/Camera3D/Buffy Scythe/AnimationPlayer"
@onready var gun_muzzle := $"Head/Camera3D/Steampunk Rifle/RayCast3D"
@onready var gun2_muzzle := $"Head/Camera3D/Steampunk Rifle2/RayCast3D"
@onready var raygun_anim := $"Head/Camera3D/Ray Gun/RootNode/AnimationPlayer"
@onready var raygun_muzzle := $"Head/Camera3D/Ray Gun/RootNode/RayCast3D"


func _ready():    # gets rid of cursor to allow camera to move via mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSESPEED) # moving left to right rotates around the y axis vice versa 
		camera.rotate_x(-event.relative.y * MOUSESPEED)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60)) # limits rotation of camera
		
func lightshot():  # right handed gun
	if Input.is_action_pressed("lightshot"):
		if !gun_anim.is_playing():
			gun_anim.play("recoil")
			inst = bullet.instantiate()
			inst.position = gun_muzzle.global_position
			inst.transform.basis = gun_muzzle.global_transform.basis
			get_parent().add_child(inst)
		if !gun2_anim.is_playing():
			gun2_anim.play("recoil")
			inst = bullet2.instantiate()
			inst.position = gun2_muzzle.global_position
			inst.transform.basis = gun2_muzzle.global_transform.basis
			get_parent().add_child(inst)

func powershot():  # left handed gun
	if Input.is_action_pressed("powershot"):
		if !raygun_anim.is_playing():
			raygun_anim.play("bigrecoil")
			inst = bullet.instantiate()
			inst.position = raygun_muzzle.global_position
			inst.transform.basis = raygun_muzzle.global_transform.basis
			get_parent().add_child(inst)
		
	
func _physics_process(delta):
	
	powershot()
	lightshot()

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("sprint"): # pressing shift will make the player sprint
		speed = SPRINT
	else:
		speed = WALK
		
	if Input.is_action_just_pressed("quit"):  # added a quit button
		get_tree().quit()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() # direction moves relative to camera
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0) # limits control in mid air
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 2.0) # limits control in mid air
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 2.0)

	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT * 2)  # moves camera back when sprinting
	var fov = WALK_FOV + FOVMULTI * velocity_clamped
	camera.fov = lerp(camera.fov, fov, delta * 8.0)
		
	move_and_slide()
