extends Particles2D
var elapsedtime = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_emitting(true)
	set_one_shot(true)
	set_rotation(-3.14159/2)
	pass # Replace with function body.
	
func _process(delta):
	elapsedtime = elapsedtime + delta
	if elapsedtime > 3:
		free()