extends Control

###################
# Lifecycle methods

func _ready():

    GameState.save_game_success()

    $AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")

    yield(get_tree().create_timer(1), "timeout")
    $Spaceship.message_system.show_message("Woohoo!")
    yield(get_tree().create_timer(4), "timeout")
    $Spaceship.message_system.show_message("I'll be super rich!")
    yield(get_tree().create_timer(4), "timeout")
    $Spaceship.message_system.show_message("Time to go home!")


func _process(delta):
    $Spaceship.message_system._process(delta)

#################
# Event callbacks

func _on_animation_finished(anim_name):
    GameState.load_screen(GameState.Screens.TITLE)