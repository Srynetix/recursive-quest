extends CanvasLayer

# Transition system

func fade_to(scene_path, speed=1):
    var scene = load(scene_path)

    $AnimationPlayer.playback_speed = speed
    $AnimationPlayer.play("fadeout")
    yield($AnimationPlayer, "animation_finished")

    get_tree().change_scene_to(scene)
    $AnimationPlayer.play("fadein")