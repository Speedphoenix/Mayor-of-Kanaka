class_name TaxiCabIterator
extends Reference

var curr_distance: int
var max_distance: int
var start_distance: int
var stage: int
var x: int
var y: int

enum Stages {RIGHT_TO_TOP = 0, TOP_TO_LEFT = 1, LEFT_TO_BOTTOM = 2, BOTTOM_TO_RIGHT = 3}

static func get_adjacent_coords(where: Vector2, dims: Vector2, include_corners := false) -> Array:
	var rep := []
	for i in range(where.x, where.x + dims.x):
		rep.append(Vector2(i, where.y - 1))
		rep.append(Vector2(i, where.y + dims.y))
	for j in range(where.y, where.y + dims.y):
		rep.append(Vector2(where.x - 1, j))
		rep.append(Vector2(where.x + dims.x, j))
	if include_corners:
		rep.append(Vector2(where.x - 1, where.y - 1))
		rep.append(Vector2(where.x - 1, where.y + dims.y))
		rep.append(Vector2(where.x + dims.x, where.y - 1))
		rep.append(Vector2(where.x + dims.x, where.y + dims.y))
	return rep

# Use -1 to not set any maximum distance
# max_distance is included in the iteration
func _init(max_dist := -1, start_dist := 0):
	self.max_distance = max_dist
	self.start_distance = start_dist

func should_continue() -> bool:
	return max_distance == -1 || curr_distance <= max_distance

func _distance_init(dist: int):
	curr_distance = dist
	if dist == 0:
		x = 0
		y = 0
		# The last stage, so the next iteration will increase distance
		stage = Stages.BOTTOM_TO_RIGHT
	else:
		x = dist
		y = 0
		# The first stage
		stage = Stages.RIGHT_TO_TOP

func _iter_init(_arg) -> bool:
	_distance_init(start_distance)
	return should_continue()

func _iter_next(_arg) -> bool:
	# Can only happen on first iteration if start_distance = 0
	if (x == 0 && y == 0):
		_distance_init(curr_distance + 1)
		return should_continue()
	match stage:
		Stages.RIGHT_TO_TOP:
			x -= 1
			y += 1
		Stages.TOP_TO_LEFT:
			x -= 1
			y -= 1
		Stages.LEFT_TO_BOTTOM:
			x += 1
			y -= 1
		Stages.BOTTOM_TO_RIGHT:
			x += 1
			y += 1
	if (x == 0 && (stage % 2 == 0)) || (y == 0 && (stage % 2 == 1)):
		stage += 1
	if stage >= 4:
		_distance_init(curr_distance + 1)
	return should_continue()

func _iter_get(_arg) -> Vector2:
	return Vector2(x, y)
