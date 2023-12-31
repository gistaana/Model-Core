extends CharacterBody3D

var speed = 0
var SPRINT = 6.0
var BOOST = 20.0
var JUMP_VELOCITY = 4.5
const MOUSESPEED = 0.004
var modelNum = 1
var flightNum = 1
var can_boost = true

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

@onready var gun1 = $"Head/Camera3D/Steampunk Rifle1"  # weapons
@onready var gun2 = $"Head/Camera3D/Steampunk Rifle2"
@onready var gun3 = $"Head/Camera3D/Steampunk Rifle3"
@onready var gun4 = $"Head/Camera3D/Steampunk Rifle"
@onready var sb1 = $"Head/Camera3D/standby1"
@onready var sb2 = $"Head/Camera3D/standby2"


@onready var crosshair = $"UI/Crosshair"   # UI components
@onready var stamina = $"UI/StaminaBar"
@onready var health =$"UI/HealthBar"
@onready var EN = $"UI/EN"
@onready var model = $"UI/Model"
@onready var mode = $"UI/flightMode"

@onready var gun1_anim := $"Head/Camera3D/Steampunk Rifle1/AnimationPlayer"  # Weapon anim
@onready var gun2_anim :=$"Head/Camera3D/Steampunk Rifle2/AnimationPlayer"
@onready var gun3_anim :=$"Head/Camera3D/Steampunk Rifle3/AnimationPlayer"
@onready var gun4_anim :=$"Head/Camera3D/Steampunk Rifle/AnimationPlayer"
@onready var arm_anim = $"Head/Camera3D/Robot Arm/AnimationPlayer"

@onready var gun1_muzzle := $"Head/Camera3D/Steampunk Rifle1/RayCast3D"   # Weapon projectiles
@onready var gun2_muzzle := $"Head/Camera3D/Steampunk Rifle2/RayCast3D"
@onready var gun3_muzzle := $"Head/Camera3D/Steampunk Rifle3/RayCast3D"
@onready var gun4_muzzle := $"Head/Camera3D/Steampunk Rifle/RayCast3D"


func _ready():    # gets rid of cursor to allow camera to move via mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	crosshair.position.x = get_viewport().size.x / 2 - 300  # crosshair
	crosshair.position.y = get_viewport().size.y / 2 - 225
	
	stamina.position.x = get_viewport().size.x / 2 - 250  #stamina bar
	stamina.position.y = 68
	
	##health.position.x = get_viewport().size.x / 2 - 275  # health bar
	##health.position.y = 58
	
	EN.position.x = get_viewport().size.x / 2 - 86 # Energy message
	EN.position.y = 250
	
	stamina.value = stamina.max_value   

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * MOUSESPEED) # moving left to right rotates around the y axis vice versa 
		camera.rotate_x(-event.relative.y * MOUSESPEED)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60)) # limits rotation of camera
		
func model_switch():
	if Input.is_action_pressed("switch1"):
		modelNum = 1
		#SPRINT = 10.0
		BOOST = 20.0
		JUMP_VELOCITY = 4.5
	if Input.is_action_pressed("switch2"):
		modelNum = 2
		#SPRINT = 9.0
		BOOST = 15.0
		JUMP_VELOCITY = 4.5
	if Input.is_action_pressed("switch3"):
		modelNum = 3
		#SPRINT = 5.0
		BOOST = 7.0
		JUMP_VELOCITY = 1.5
	else:
		pass
	
func lightshot():  # right handed gun
	if Input.is_action_pressed("lightshot") and can_boost:
		if !gun1_anim.is_playing():
			gun1_anim.play("recoil")
			inst = bullet.instantiate()
			inst.position = gun1_muzzle.global_position
			inst.transform.basis = gun1_muzzle.global_transform.basis
			get_parent().add_child(inst)
		if !gun2_anim.is_playing():
			gun2_anim.play("recoil")
			inst = bullet.instantiate()
			inst.position = gun2_muzzle.global_position
			inst.transform.basis = gun2_muzzle.global_transform.basis
			get_parent().add_child(inst)
		
func melee():
	if Input.is_action_pressed("lightshot"):
		if !arm_anim.is_playing():
			arm_anim.play("boom")
		
func powershot():
	if Input.is_action_pressed("powershot") and can_boost:
		stamina.value -= 1.2
		if !gun3_anim.is_playing():
			gun3_anim.play("rec")
			inst = energyball.instantiate()
			inst.position = gun3_muzzle.global_position
			inst.transform.basis = gun3_muzzle.global_transform.basis
			get_parent().add_child(inst)
			
func ultshot():
	if Input.is_action_pressed("powershot") and can_boost:
		stamina.value -= 1.5
		if !gun3_anim.is_playing():
			gun3_anim.play("rec")
			inst = energyball.instantiate()
			inst.position = gun3_muzzle.global_position
			inst.transform.basis = gun3_muzzle.global_transform.basis
			get_parent().add_child(inst)
		if !gun4_anim.is_playing():
			gun4_anim.play("newrecoil")
			inst = energyball.instantiate()
			inst.position = gun4_muzzle.global_position
			inst.transform.basis = gun4_muzzle.global_transform.basis
			get_parent().add_child(inst)
			
func flight():
	if Input.is_action_pressed("q"):
		flightNum = 2
		SPRINT = 10.0
		BOOST = 25.0
		#SPRINT = 5.0
			
	if Input.is_action_pressed("e"):
		flightNum = 1
		BOOST = 20.0
		#SPRINT = 10.0
		
		
func _physics_process(delta):	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# IMPORTANT SECTION; CONTAINS ALL RELEVANT ANIMATIONS/MECHANICS
	################################################################################################
	
	if Input.is_action_pressed("sprint") and stamina.value != 0 and can_boost: # pressing shift will make the player sprint					
		if modelNum == 1 and flightNum == 2:
			lightshot()
		else:
			if !player_anim.is_playing():
				player_anim.play("zoom")	
				
		speed = BOOST 
		stamina.value -= 1	
		
	else:
		if Input.is_action_pressed("q") and mode.visible == true:  # UI changes
			mode.text = "(ON)"
		if Input.is_action_pressed("e") and mode.visible == true:
			mode.text = "(OFF)"
			
		if Input.is_action_pressed("switch1"):
			mode.text = "(OFF)"
			mode.visible = true
			model.text = "Model 1: Jet Build"
		if Input.is_action_pressed("switch2"):
			mode.visible = false
			model.text = "Model 2: Tank Build"
			flightNum = 1
		if Input.is_action_pressed("switch3"):
			mode.visible = false
			model.text = "Model 3: Destroyer Build"
			flightNum = 1

		if stamina.value >= stamina.max_value:   # Stamina bar calculations
			EN.visible = false
			stamina.value = stamina.max_value
			can_boost = true
			gun1.visible = true
			gun2.visible = true
		elif stamina.value == 0:
			EN.visible = true
			can_boost = false
			gun1.visible = false
			gun2.visible = false
			stamina.value += 1
		else:
			stamina.value += 1
		
		player_anim.stop()
		model_switch()
		lightshot()
		
		if modelNum == 1:               # Model Switch (cannot be achieved when sprinting)
			flight()
			gun3.visible = false
			gun4.visible = false
			sb1.visible = true
			sb2.visible = true
		if modelNum == 2:
			powershot()
			gun3.visible = true
			gun4.visible = false
			sb1.visible = false
			sb2.visible = true
		if modelNum == 3:
			ultshot()
			gun3.visible = true
			gun4.visible = true
			sb1.visible = false
			sb2.visible = false
			
		speed = SPRINT
		
	################################################################################################
	
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
