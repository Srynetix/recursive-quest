extends Control

#####################
# Title screen script

#################
# Private methods

func _load_next():
    $ConfirmSound.play()
    set_process(false)
    set_process_input(false)
    GameState.load_screen(GameState.Screens.INSTRUCTIONS)

###################
# Lifecycle methods

func _ready():
    $Spaceship/Camera2D.current = false
    $Spaceship.set_process(false)
    $Camera2D.current = true

    $CanvasLayer/HighScore.text = "High score: " + str(GameState.high_score)
    $Treasures.visible = GameState.game_already_finished

    if Utils.is_system_mobile():
        $CanvasLayer/Instructions.text = "Touch screen to start"
    else:
        $CanvasLayer/Instructions.text = "Press 'X' to start"

func _process(delta):
    if Input.is_action_just_pressed("shoot"):
        _load_next()

func _input(event):
    if event is InputEventScreenTouch:
        _load_next()
