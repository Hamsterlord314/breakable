extends StaticBody2D
var tip_time = float(0)
export (PackedScene) var particle_scn
func _ready():
	for x in range(700):
		var particle = particle_scn.instance()
		add_child(particle)
		particle.set_global_position(Vector2(randi()%1000,440))
		particle.set_linear_velocity(Vector2(0,5))
		
func _process(delta):
	tip_time = tip_time + delta
	set_rotation(sin(tip_time*2)/200)
	