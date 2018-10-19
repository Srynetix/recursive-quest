extends Control

####################
# Boot screen script

###################
# Lifecycle methods

func _ready():
    yield($AnimationPlayer, "animation_finished")
    GameState.load_screen(GameState.Screens.INTRO)
