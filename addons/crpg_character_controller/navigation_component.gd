extends NavigationAgent3D

## Controls a navigation agent with movement
## Add as a component to a character body and call set_movement_target
## Must be linked to a CharacterBody3D

@export var actor: CharacterBody3D
@export var movement_speed: float = 1.5

var movement_target_position: Vector3

func _ready():
	assert(actor,"No CharacterBody3D found for %s" % self)
	movement_target_position = actor.position
	actor_setup.call_deferred()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector3):
	set_target_position(movement_target)

func _physics_process(delta):
	if is_navigation_finished():
		return

	var current_agent_position: Vector3 = actor.global_position
	var next_path_position: Vector3 = get_next_path_position()
	
	actor.velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	actor.move_and_slide()
