extends Control

#####################
# Intro screen script

##############
# Private vars

var message_system = load("res://elements/spaceship/MessageSystem.gd").new()

var intro_text = """
A long day deep in space...

You are in quest for precious hidden treasures,
for GLORY, and MONEY of course.

Then you see something big and shiny... That looks like...
A pyramid... ?

THERE MUST BE TREASURES IN HERE, LET'S GO !
"""

###################
# Lifecycle methods

func _ready():
    $Spaceship/Camera2D.current = false
    $Spaceship.set_process(false)
    $Camera2D.current = true

    message_system.initialize($MarginContainer/Label)
    message_system.show_message(intro_text, 0.050)

    yield($AnimationPlayer, "animation_finished")
    GameState.load_screen(GameState.Screens.TITLE)

func _process(delta):
    message_system._process(delta)

    if Input.is_action_just_pressed("shoot"):
        set_process(false)
        GameState.load_screen(GameState.Screens.TITLE)

func _input(event):
    if event is InputEventScreenTouch:
        set_process(false)
        GameState.load_screen(GameState.Screens.TITLE)
