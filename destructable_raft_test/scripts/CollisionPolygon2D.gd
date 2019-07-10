extends CollisionPolygon2D 
export (PackedScene) var splashparticle
var array2
var storedpt
var globalwl = 450
var intersection_vector = Vector2()
var underwater_coords = PoolVector2Array()
var x
var a
var stored_offset = Vector2()
var stored_force = Vector2()
var velocity_vector = Vector2(0,0)
func _ready():
	set_process(true)
	set_process_input(true)
	
func _process(delta):
	array2 = get_polygon()
	var array = []
	for k in array2:
		array.append(to_global(k))
	array.append(array[0])
	underwater_coords = []
	storedpt = Vector2(0,0)
	x = 0
	for i in array:
		if x > 0:
			if (storedpt.y < globalwl and i.y > globalwl) or (storedpt.y > globalwl and i.y < globalwl):
				intersection_vector.x = storedpt.x - (((storedpt.y-globalwl)*(storedpt.x - i.x))/(storedpt.y - i.y))
				intersection_vector.y = globalwl
				underwater_coords.append(intersection_vector)
				if(velocity_vector.y > 30):
					createParticle(intersection_vector)
			if i.y > globalwl:
				underwater_coords.append(i)
		storedpt = i
		x = x + 1
	#print(calculate_area(underwater_coords))
	if calculate_area(underwater_coords) > 0:
		addFriction()
	else:
		get_parent().add_force(Vector2(0,0),velocity_vector*.65)
		velocity_vector = Vector2(0,0)
	if len(underwater_coords) >= 3:
		get_parent().add_force(stored_offset,-stored_force)
		stored_force = Vector2(0,-calculate_area(underwater_coords)/13)
		stored_offset = Vector2(forceoffset(underwater_coords),0)
		get_parent().add_force(stored_offset,stored_force)
	#print(underwater_coords)

func calculate_area(coords):
	a = 0
	var finalanswer = 0
	while a < len(coords):
		if a == len(coords)-1:
			finalanswer = finalanswer + coords[a].x*coords[0].y-coords[0].x*coords[a].y
		else:
			finalanswer = finalanswer + coords[a].x*coords[a+1].y-coords[a+1].x*coords[a].y
		a = a + 1
	return(abs(finalanswer/2))

func forceoffset(coords):
	var total = 0
	for l in coords:
		total = total + l.x
	return(float(total/len(coords))-global_position.x)
	
func addFriction():
	get_parent().add_force(Vector2(0,0),velocity_vector*.65)
	velocity_vector = get_parent().get_linear_velocity()
	get_parent().add_force(Vector2(0,0),-velocity_vector*.65)
	
func createParticle(point):
	var particle = splashparticle.instance()
	var rand = randi()%20
	if rand == 0:
		add_child(particle)
		particle.set_global_position(point)


	