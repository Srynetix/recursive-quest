extends Control

# HUD script

onready var ScoreValue = $MarginContainer/HBoxContainer/VBoxContainer/ScoreValue
onready var TimeLeftValue = $MarginContainer/HBoxContainer/VBoxContainer2/TimeLeftValue
onready var LivesValue = $MarginContainer/HBoxContainer/VBoxContainer3/LivesValue
onready var Main = $Main

func update_score(score):
    ScoreValue.text = str(score)

func update_time_left(value):
    TimeLeftValue.text = str(value)

func update_lives(lives):
    LivesValue.text = str(lives)

func show_main_message(msg):
    Main.modulate = Color(1, 1, 1, 0)
    Main.text = msg

    $AnimationPlayer.play("show_main")
    yield($AnimationPlayer, "animation_finished")
    $AnimationPlayer.play("hide_main")
    yield($AnimationPlayer, "animation_finished")
    Main.text = ""