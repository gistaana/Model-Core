extends Control

@onready var stamina = $TextureProgressBar
@onready var EN = $EN
@onready var model = $Model
@onready var mode = $flightMode


var can_boost 
const max_count = 100
var count = 0
var b = true
var num = .38

# Called when the node enters the scene tree for the first time.
func _ready():
	stamina.value = stamina.max_value

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	if Input.is_action_pressed("sprint") and stamina.value != 0 and b: # pressing shift will make the player sprint
		stamina.value -= num
	else:
		if Input.is_action_pressed("q") and mode.visible == true:
			mode.text = "(Flight Enabled)"
		if Input.is_action_pressed("e") and mode.visible == true:
			mode.text = "(Flight Disabled)"
		if Input.is_action_pressed("switch1"):
			mode.text = "(Flight Disabled)"
			mode.visible = true
			model.text = "Model 1: Jet Build"
		if Input.is_action_pressed("switch2"):
			mode.visible = false
			model.text = "Model 2: Tank Build"
			
			
		if stamina.value >= stamina.max_value:
			EN.text = "EN"
			stamina.value = stamina.max_value
			b = true
		elif stamina.value == 0:
			EN.text = "EN DEPLETED, RECHARGING..."
			b = false
			stamina.value += num
			print("ZERO")
		else:
			stamina.value += num
		
