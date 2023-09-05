extends CharacterBody3D

var speed
const WALK = 5.0
const SPRINT = 9.0
const BOOST = 18.0
const JUMP_VELOCITY = 4.5
const MOUSESPEED = 0.003
var BOOST_DURATION = 2.0
var isBOOSTING = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

const WALK_FOV = 75.0
const FOVMULTI = 1.5

var bullet = load("res://Scenes/bullet.tscn")
var bullet2 = load("res://Scenes/bullet_2.tscn")
var energyattack = load("res://Scenes/energyattack.tscn")
var energyball = load("res://Scenes/energyball.tscn")
var inst

@onready var head := $Head # connects to the node which is a child to characterbody3d
@onready var camera := $Head/Camera3D
@onready var gun_anim := $"Head/Camera3D/Steampunk Rifle/AnimationPlayer"
@onready var gun2_anim :=$"Head/Camera3D/Steampunk Rifle2/AnimationPlayer"
@onready var gun3_anim :=$"Head/Camera3D/Steampunk Rifle3/AnimationPlayer"
# @onready var melee_anim := $"Head/Camera3D/Buffy Scythe/AnimationPlayer"
@onready var gun_muzzle := $"Head/Camera3D/Steampunk Rifle/RayCast3D"
@onready var gun2_muzzle := $"Head/Camera3D/Steampunk Rifle2/RayCast3D"
@onready var gun3_muzzle := $"Head/Camera3D/Steampunk Rifle3/RayCast3D"

@onready var BoostTimer := $"Head/Timer"


func _ready():    # gets rid of cursor to allow camera to move via mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	BoostTimer.start()
	
func _on_BoostTimer_timeout():
	speed = SPRINT # Stop the timer after 1 second

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
		
func powershot():
	if Input.is_action_pressed("powershot"):
		if !gun3_anim.is_playing():
			gun3_anim.play("fastrecoil")
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
		speed = BOOST
	else:
		lightshot()
		powershot()
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
