extends Control

############
# HUD script

##############
# Private vars

onready var ScoreValue = $MarginContainer/HBoxContainer/VBoxContainer/ScoreValue
onready var TimeLeftValue = $MarginContainer/HBoxContainer/VBoxContainer2/TimeLeftValue
onready var LivesValue = $MarginContainer/HBoxContainer/VBoxContainer3/LivesValue
onready var Treasures = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer
onready var Main = $Main

################
# Public methods

func update_score(score):
    """
    Update score display.

    :param score:   Score to display
    """
    ScoreValue.text = str(score)

func update_time_left(value):
    """
    Update remaining time display.

    :param value:   Time to display
    """
    TimeLeftValue.text = str(value)

func update_lives(lives):
    """
    Update lives display.

    :param lives:   Lives to display
    """
    LivesValue.text = str(lives)

func show_main_message(msg):
    """
    Show a message at the bottom.

    :param msg: Message to display
    """
    Main.modulate = Color(1, 1, 1, 0)
    Main.text = msg

    $AnimationPlayer.play("show_main")
    yield($AnimationPlayer, "animation_finished")
    $AnimationPlayer.play("hide_main")
    yield($AnimationPlayer, "animation_finished")
    Main.text = ""

func show_treasures(names):
    """
    Show treasures.

    :param names:    Names
    """
    for name in names:
        for treasure in Treasures.get_children():
            if treasure.name == name:
                treasure.visible = true