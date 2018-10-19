extends CanvasLayer

###################
# Transition system

################
# Public methods

func fade_to_scene(scene_path, transition_speed=1):
    """
    Fade screen to another scene.

    :param scene_path:          Scene path
    :param transition_speed:    Transition speed
    """
    var scene = load(scene_path)

    $AnimationPlayer.playback_speed = transition_speed
    $AnimationPlayer.play("fadeout")
    yield($AnimationPlayer, "animation_finished")

    get_tree().change_scene_to(scene)
    $AnimationPlayer.play("fadein")
