extends RigidBody2D
var cp2d
var polygon_coords = PoolVector2Array()
var possible_epoints = PoolVector2Array()
var firstPolygon = PoolVector2Array()
var secondPolygon = PoolVector2Array()
var entrance_position = Vector2()
var possibleexitpt = Vector2()
var indexthingy = []
var slope
var stored_point
var firstexitpoint
var secondexitpoint
var firststartandstop
var secondstartandstop
var daddy
var split = false
export var done = false
func _ready():
	cp2d = get_node("CollisionPolygon2D")
	daddy = get_parent()
	
func _integrate_forces(state):
	if split: 
		queue_free()
	elif not done:
		polygon_coords = cp2d.get_polygon()
		if state.get_contact_count() > 0:
			entrance_position = to_local(state.get_contact_local_position(state.get_contact_count()-1))
			print("rotation:", rotation)
			print("contact normal:", state.get_contact_local_normal(state.get_contact_count()-1))
			set_polygons(entrance_position, state.get_contact_local_normal(state.get_contact_count()-1).rotated(-rotation), polygon_coords)
		
func set_polygons(entrance_pos, normal, coords):
	print(normal)
	var index = 0
	if normal.x == 0:
		normal.x = 0.00001
	if normal.y == 0:
		normal.x = 0.00001
	slope = normal.y/normal.x
	stored_point = coords[len(coords)-1]
	possible_epoints = PoolVector2Array()
	for pt in coords:
		if ((!get_above(pt, entrance_pos)) and get_above(stored_point, entrance_pos)) or ((!get_above(stored_point, entrance_pos)) and get_above(pt, entrance_pos)):
			possibleexitpt.x = (-slope*entrance_pos.x+entrance_pos.y+(pt.y-stored_point.y)/(pt.x-stored_point.x)*stored_point.x-stored_point.y)/(((pt.y-stored_point.y)/(pt.x-stored_point.x))-slope)
			possibleexitpt.y = (slope*(possibleexitpt.x-entrance_pos.x)) + entrance_pos.y
			print("pt: ", pt, "stored_point:",stored_point)
			#if isaboveorbelow(normal,entrance_pos,possibleexitpt):
			possible_epoints.append(possibleexitpt)
			indexthingy.append(index)
		index = index + 1
		stored_point = pt
	print("PE", possible_epoints)
	find_index_of_the_closest_two(entrance_pos, possible_epoints, indexthingy)
	if not(firstexitpoint == null) and not(secondexitpoint == null):
		firstPolygon = set_points(firstexitpoint, secondexitpoint, polygon_coords, firststartandstop, secondstartandstop)
		secondPolygon = set_points(secondexitpoint, firstexitpoint, polygon_coords, secondstartandstop, firststartandstop)
	if len(firstPolygon) > 2 and len(secondPolygon) > 2:
		create_polygons()

func get_above(pt1, ep):
	if pt1.y > slope*(pt1.x - ep.x) + ep.y:
		return true
	else:
		return false
		
func isaboveorbelow(normal1, entrancept, pept):
	if(normal1.y < 0):
		if(pept.y < entrancept.y + .1):
			return(true)
		else:
			return(false)
	elif(normal1.y > 0):
		if(pept.y > entrancept.y - .1):
			return(true)
		else:
			return(false)
	else:
		return(true)

func find_index_of_the_closest_two(entrancePt, possibleExitPoints, indexthing):
	var firstSmallestDistance = 1000000
	var secondSmallestDistance = 1000000
	var firstSmallestDistanceIndex = 0
	var secondSmallestDistanceIndex = 0
	var ind = 0
	
	if(len(possibleExitPoints) > 0):
		for pept in possibleExitPoints:
			if (pept.distance_to(entrancePt) < firstSmallestDistance):
				secondSmallestDistanceIndex =firstSmallestDistanceIndex
				secondSmallestDistance = firstSmallestDistance
				firstSmallestDistance = pept.distance_to(entrancePt)
				firstSmallestDistanceIndex = ind
			elif(pept.distance_to(entrancePt) < secondSmallestDistance):
				secondSmallestDistance = pept.distance_to(entrancePt)
				secondSmallestDistanceIndex = ind
			ind = ind + 1
	
		firstexitpoint = possibleExitPoints[firstSmallestDistanceIndex]
		secondexitpoint = possibleExitPoints[secondSmallestDistanceIndex]
		firststartandstop = indexthing[firstSmallestDistanceIndex]
		secondstartandstop = indexthing[secondSmallestDistanceIndex]
		
func set_points(start, stop, points, fsa, ssa):
	var a = fsa
	var toreturn = PoolVector2Array()
	toreturn.append(start)
	while(true):
		if(a == ssa):
			toreturn.append(stop)
			return(toreturn)
		else:
			toreturn.append(points[a])
		if(a == len(points) - 1):
			a = 0
		else:
			a = a + 1
			
func get_center_of_mass(poly):
	var total = Vector2()
	for point in poly:
		total = total + point
	return total/len(poly)
	
func create_polygons():
	cp2d.set_polygon(PoolVector2Array())
	var clone = duplicate()
	var clone2 = duplicate()
	var previous_position = get_global_position()
	daddy.add_child(clone)
	daddy.add_child(clone2)
	clone.set_global_position(to_global(get_center_of_mass(secondPolygon)))
	clone2.set_global_position(to_global(get_center_of_mass(firstPolygon)))
	clone.get_child(0).set_polygon(offset(secondPolygon, clone.get_global_position() - previous_position))
	clone2.get_child(0).set_polygon(offset(firstPolygon, clone2.get_global_position() - previous_position))
	clone.get_child(1).set_polygon(offset(secondPolygon, clone.get_global_position() - previous_position))
	clone2.get_child(1).set_polygon(offset(firstPolygon, clone2.get_global_position() - previous_position))
	#clone2.done = true
	#clone.done = true
	split = true
	
func offset(pool, offset):
	var tooreturn = PoolVector2Array()
	for point in pool:
		tooreturn.append(point - offset.rotated(-rotation))
	return tooreturn
		
