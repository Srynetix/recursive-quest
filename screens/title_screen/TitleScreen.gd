extends Control

func _ready():
    $Spaceship/Camera2D.current = false
    $Spaceship.set_process(false)
    $Camera2D.current = true

func _process(delta):
    if Input.is_action_just_pressed("shoot"):
        GameState.load_instructions_screen()