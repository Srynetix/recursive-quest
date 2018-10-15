extends Control

func _ready():
    $Timer.connect("timeout", self, "_on_Timer_timeout")

    $Spaceship.set_process(false)
    $Rock.set_process(false)
    $Rock.linear_velocity = Vector2(0, 0)
    $Camera2D.current = true

func _process(delta):
    if Input.is_action_just_pressed("shoot"):
        set_process(false)
        GameState.load_level(1)

func _on_Timer_timeout():
    $AnimationPlayer.play("anim")