extends Control

############################
# Instructions screen script

#################
# Private methods

func _load_next():
    set_process(false)
    set_process_input(false)
    GameState.load_level(1)

###################
# Lifecycle methods

func _ready():
    $Timer.connect("timeout", self, "_on_Timer_timeout")

    $Elements/Spaceship.set_process(false)
    $Elements/Rock.set_process(false)
    $Elements/Rock.linear_velocity = Vector2(0, 0)
    $Camera2D.current = true

    if Utils.is_system_mobile():
        $CanvasLayer/HUD/MarginContainer/VBoxContainer3/HBoxContainer/Label7.text = "Touch screen to start"
    else:
        $CanvasLayer/HUD/MarginContainer/VBoxContainer3/HBoxContainer/Label7.text = "Press 'X' to start"

func _process(delta):
    if Input.is_action_just_pressed("shoot"):
        _load_next()

func _input(event):
    if event is InputEventScreenTouch:
        _load_next()

#################
# Event callbacks

func _on_Timer_timeout():
    $AnimationPlayer.play("anim")
