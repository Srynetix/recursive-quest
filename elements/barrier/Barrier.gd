extends StaticBody2D

func explode():
    $ExplodeSound.play()
    $AnimationPlayer.play("explode")
    yield($AnimationPlayer, "animation_finished")
    queue_free()