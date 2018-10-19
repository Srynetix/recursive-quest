extends Control

#########################
# Game over screen script

#################
# Private methods

func _classic_game_over():
    $SubLabel.visible = false
    $Treasures.visible = false

    yield(get_tree().create_timer(3), "timeout")
    GameState.load_screen(GameState.Screens.TITLE)

func _bad_end_game_over():
    $SubLabel.visible = true

    for treasure in GameState.treasures:
        for node in $Treasures.get_children():
            if treasure == node.name:
                node.visible = false

    $Treasures.visible = true

    yield(get_tree().create_timer(5), "timeout")
    GameState.load_screen(GameState.Screens.TITLE)

###################
# Lifecycle methods

func _ready():
    GameState.save_game_over()

    if GameState.lives <= 0:
        _classic_game_over()
    else:
        _bad_end_game_over()

