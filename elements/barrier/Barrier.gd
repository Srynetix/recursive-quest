extends StaticBody2D

signal exploded

################
# Barrier script

################
# Public methods

func explode():
    """Explode barrier."""
    $ExplodeSound.play()
    $AnimationPlayer.play("explode")
    emit_signal("exploded")
    yield($AnimationPlayer, "animation_finished")
    queue_free()
