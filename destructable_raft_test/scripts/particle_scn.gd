extends RigidBody2D
var time_elapsed = 0
var change_force_time = float(.5)
var a = 50
var b = 0
func _ready():
	set_process(true)
	set_process_input(true)
	add_force(Vector2(0,0),Vector2(a,b))

func _process(delta):
	time_elapsed = time_elapsed + delta
	if time_elapsed > change_force_time:
		a = a*(-1)
		add_force(Vector2(0,0),Vector2(2*a,b))
		time_elapsed = 0
	
	
