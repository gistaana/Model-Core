extends CharacterBody3D

var speed = 0
const WALK = 5.0
var SPRINT = 9.0
var BOOST = 20.0
const JUMP_VELOCITY = 4.5
const MOUSESPEED = 0.004
var num = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

const WALK_FOV = 75.0
const FOVMULTI = 1.1

var bullet = load("res://Scenes/bullet.tscn")
var bullet2 = load("res://Scenes/bullet_2.tscn")
var energyball = load("res://Scenes/energyball.tscn")
var inst

@onready var head := $Head # connects to the node which is a child to characterbody3d
@onready var camera := $Head/Camera3D
@onready var player_anim := $"AnimationPlayer"

@onready var gun_anim := $"Head/Camera3D/Steampunk Rifle/AnimationPlayer"
@onready var gun2_anim :=$"Head/Camera3D/Steampunk Rifle2/AnimationPlayer"
@onready var gun3_anim :=$"Head/Camera3D/Steampunk Rifle3/AnimationPlayer"

@onready var gun_muzzle := $"Head/Camera3D/Steampunk Rifle/RayCast3D"
@onready var gun2_muzzle := $"Head/Camera3D/Steampunk Rifle2/RayCast3D"
@onready var gun3_muzzle := $"Head/Camera3D/Steampunk Rifle3/RayCast3D"

func _ready():    # gets rid of cursor to allow camera to move via mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSESPEED) # moving left to right rotates around the y axis vice versa 
		camera.rotate_x(-event.relative.y * MOUSESPEED)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60)) # limits rotation of camera
		
func energy_switch():
	if Input.is_action_pressed("switch1"):
		num = 1
		SPRINT = 9.0
		BOOST = 20.0
	if Input.is_action_pressed("switch2"):
		num = 2
		SPRINT = 5.0
		BOOST = 9.0
	else:
		pass
	print(num)
	print(BOOST)
	
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
		
func powershot():
	if Input.is_action_pressed("powershot"):
		if !gun3_anim.is_playing():
			gun3_anim.play("fastrecoil")
			inst = energyball.instantiate()
			inst.position = gun3_muzzle.global_position
			inst.transform.basis = gun3_muzzle.global_transform.basis
			get_parent().add_child(inst)
	
func flowshot():
	if Input.is_action_pressed("powershot"):
		if !gun3_anim.is_playing():
			#gun3_anim.play("fastrecoil")
			inst = energyball.instantiate()
			inst.position = gun3_muzzle.global_position
			inst.transform.basis = gun3_muzzle.global_transform.basis
			get_parent().add_child(inst)
			
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_pressed("sprint"): # pressing shift will make the player sprint
		if !player_anim.is_playing():
			player_anim.play("zoom")
			speed = BOOST
	else:
		player_anim.stop()
		energy_switch()
		if num == 1:
			powershot()
		if num == 2:
			flowshot()
		lightshot()
		speed = SPRINT
		
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
