extends Node3D
class_name interactableComponent

## Interactable object component to be added to a 3D body node.
## Takes a visual mesh and a collision object. When clicked, activates interact function
## Requires all three exports to work properly.
## For an actual usage case, extend this script and override interact().

@export var mesh: VisualInstance3D
@export var collision_object: CollisionObject3D
@export var hover_overlay: ShaderMaterial

var hovering: bool = false

func _ready() -> void:
	assert(mesh, "No mesh attached to interactable object %s" % self)
	assert(collision_object, "No collision object attached to interactable object %s" % self)
	assert(hover_overlay, "No overlay material attached to interactable object %s" % self)
	collision_object.mouse_entered.connect(_on_collider_mouse_entered)
	collision_object.mouse_exited.connect(_on_collider_mouse_exited)

func _input(event):
	if not hovering:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_viewport().set_input_as_handled()
			interact()

func _on_collider_mouse_entered():
	mesh.material_overlay=hover_overlay
	hovering=true

func _on_collider_mouse_exited():
	mesh.material_overlay=null
	hovering=false

func interact():
	print("interacted!")
