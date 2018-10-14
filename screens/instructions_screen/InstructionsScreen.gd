extends Control

func _ready():
    $Spaceship.set_process(false)
    $Rock.set_process(false)
    $Rock.linear_velocity = Vector2(0, 0)
    $Camera2D.current = true

    yield(get_tree().create_timer(2), "timeout")
    $AnimationPlayer.play("anim")

func _process(delta):
    if Input.is_action_just_pressed("shoot"):
        GameState.load_level(1)