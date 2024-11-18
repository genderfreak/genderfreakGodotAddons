# CRPG Character Controller for Godot 4
A character controller which emulates Disco Elysium's movement in Godot 4, with walking and running, and interactable objects.

## Usage
For a thorough demonstration view the demo scene (demo.tscn).
In brief, instance the player_character scene into a world with at least one NavigationRegion3D. Make sure to bake the navigation map. The player character, by default, will allow for movement and interacting with objects. The camera may be rotated, but that is disabled by the export variables. Check orbit_camera.gd for binding zoom and rotation buttons.
To make an object interactable, add a child node with the interactable_component script. The component requires a mesh, a collision body, and an overlay material. When the object is clicked on, it fires its interact() function. To add functionality, extend the interactable component script, and override interact().
One way to extend interactable objects would be to override interact() with a call to start a Dialogic timeline.
