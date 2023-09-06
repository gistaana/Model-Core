extends Control

@onready var stamina = $TextureProgressBar
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
		if stamina.value >= stamina.max_value:
			stamina.value = stamina.max_value
			b = true
		elif stamina.value == 0:
			b = false
			stamina.value += num
			print("ZERO")
		else:
			stamina.value += num
	
	#print(stamina.value)
