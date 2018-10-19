extends Node2D

########################
# End game screen script

###################
# Lifecycle methods

func _ready():
    $AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")
    VisualServer.set_default_clear_color(Color.black)

    var success = GameState.all_treasures_unlocked()
    if success:
        $AnimationPlayer.play("good")
    else:
        $AnimationPlayer.play("bad")

    yield(get_tree().create_timer(1), "timeout")
    $Spaceship.message_system.show_message("That's it!\nI'm at the end.")
    yield(get_tree().create_timer(3), "timeout")
    $Spaceship.message_system.show_message("What is happening?")
    if success:
        yield(get_tree().create_timer(3), "timeout")
        $Spaceship.message_system.show_message("This is the last treasure!")
        yield(get_tree().create_timer(2), "timeout")
        $Spaceship.message_system.show_message("Yes! I'll take that and return home!")
    else:
        yield(get_tree().create_timer(3), "timeout")
        $Spaceship.message_system.show_message("That's not a good sign...")


func _process(delta):
    $Spaceship.message_system._process(delta)

#################
# Event callbacks

func _on_animation_finished(anim_name):
    if anim_name == "bad":
        GameState.load_screen(GameState.Screens.GAME_OVER)
    elif anim_name == "good":
        GameState.load_screen(GameState.Screens.END_GAME_SUCCESS)