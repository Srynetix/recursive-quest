extends Control

func _ready():
    yield($AnimationPlayer, "animation_finished")
    GameState.load_title_screen()