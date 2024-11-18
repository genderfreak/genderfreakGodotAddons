extends Control

## Provides an interface for an InkStory to take place in an overlay above another game.
## This script should work for any interface with a similar pattern,
## simply by changing the node paths to whatever controls they would otherwise be.
## Requires GodotInk plugin
## Bind "dialogue_option_1"... whatever number for shortcuts (1-9)
## Bind "dialogue_advance" for a continue shortcut (spacebar)

@export var story: InkStory

# should be a label or RTL
@export var label_scene: PackedScene = preload("res://addons/feld_playback_for_godot_ink/dialogue_label.tscn")
# should be a button
@export var choice_scene: PackedScene = preload("res://addons/feld_playback_for_godot_ink/dialogue_choice.tscn")

@export var text_container_path: NodePath = "TextFrame/MarginContainer/ScrollContainer/TextContainer"
@export var portrait_path: NodePath = "PortraitFrame/MarginContainer/Portrait"
@export var continue_path: NodePath = "TextFrame/MarginContainer/ScrollContainer/TextContainer/Continue"
@export var end_spacer_path: NodePath = "TextFrame/MarginContainer/ScrollContainer/TextContainer/EndSpacer"
@export var scroll_container_path: NodePath = "TextFrame/MarginContainer/ScrollContainer"

@onready var text_container = get_node(text_container_path)
@onready var portrait = get_node(portrait_path)
@onready var continue_button = get_node(continue_path)
@onready var end_spacer = get_node(end_spacer_path)
@onready var scroll_container = get_node(scroll_container_path)

var last_choices: Array

func _ready() -> void:
	continue_button.pressed.connect(continue_dialogue)
	continue_dialogue()

func _process(delta: float) -> void:
	pass

func _unhandled_input(event):
	if event.is_action_pressed("dialogue_advance"):
		continue_dialogue()

func continue_dialogue():
	if story.GetCanContinue():
		var new_label = label_scene.instantiate()
		new_label.text=story.Continue()
		text_container.add_child(new_label)
		# put the endy bits at the end
		text_container.move_child(continue_button,-1)
		text_container.move_child(end_spacer,-1)
		scroll_down()
		# if can't continue: show choices
		if not story.GetCanContinue():
			show_choices()
			continue_button.visible=false
		else: # show the continue button if can continue
			continue_button.visible=true

func show_choices():
	var choices = story.GetCurrentChoices()
	var count=1
	for choice in choices:
		var text=("%s. %s" % [count,choice.GetText()])
		var new_choice = choice_scene.instantiate()
		new_choice.text=text
		new_choice.pressed.connect(choose_choice.bind(count-1))
		new_choice.shortcut = make_choice_shortcut(count)
		text_container.add_child(new_choice)
		last_choices.append(new_choice)
		count+=1
	# put the endy bits at the end
	text_container.move_child(continue_button,-1)
	text_container.move_child(end_spacer,-1)
	scroll_down()

func choose_choice(option):
	story.ChooseChoiceIndex(option)
	for choice in last_choices:
		#choice.pressed.disconnect(choose_choice)
		choice.queue_free()
	last_choices=[]
	continue_dialogue()
	continue_dialogue()

func make_choice_shortcut(option):
	var shortcut = Shortcut.new()
	var event = InputEventAction.new()
	event.action = "dialogue_option_%s" % option
	shortcut.events.append(event)
	return shortcut

func scroll_down():
	await get_tree().process_frame
	var scrollbar = scroll_container.get_v_scroll_bar()
	scroll_container.scroll_vertical = scrollbar.max_value
