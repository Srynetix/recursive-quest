extends Node

# GameState

var score = 0
var lives = 3
var current_level = 0

func _change_scene(path, speed=1):
    Transition.fade_to(path, speed)

func load_title_screen():
    score = 0
    lives = 3
    current_level = 0
    _change_scene("res://screens/title_screen/TitleScreen.tscn")

func load_instructions_screen():
    _change_scene("res://screens/instructions_screen/InstructionsScreen.tscn")

func load_game_over_screen():
    _change_scene("res://screens/game_over_screen/GameOverScreen.tscn")

func load_level(level_id, speed=1):
    current_level = level_id
    _change_scene("res://levels/Level" + str(level_id) + ".tscn", speed)

func load_next_level():
    load_level(current_level + 1)

func reload_current_level():
    load_level(current_level, 2)

# Update methods

func add_score(value):
    score += value

func remove_life():
    lives = max(lives - 1, 0)

func update_hud(hud):
    hud.update_score(score)
    hud.update_lives(lives)