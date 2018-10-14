extends StaticBody2D

func explode():
    $AnimationPlayer.play("explode")
    yield($AnimationPlayer, "animation_finished")
    queue_free()