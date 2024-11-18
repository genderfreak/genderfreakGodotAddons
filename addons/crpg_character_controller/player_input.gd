extends CharacterBody3D

## Connects with a navigation agent to allow a player to click/double click to
## move a character body around
## Requires a camera and a nav agent

@export var walk_speed: float = 1.5
@export var run_speed: float = 2

@export var navigation_agent: NavigationAgent3D
@onready var camera_root = $OrbitCamera

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index==MOUSE_BUTTON_LEFT and event.pressed:
			var target = camera_root.get_cursor_world_position()
			navigation_agent.set_movement_target(target)
			if event.double_click:
				navigation_agent.movement_speed=run_speed
			else:
				navigation_agent.movement_speed=walk_speed
