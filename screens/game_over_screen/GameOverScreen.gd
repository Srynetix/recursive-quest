extends Control

func _ready():
    yield(get_tree().create_timer(3), "timeout")
    GameState.load_title_screen()