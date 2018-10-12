extends Node2D

# Spaceship script.

signal shoot(bullet, pos, dir)

enum { IDLE, SHOOT, DRILL, STUN }

export (int) var move_speed = 200
export (float) var damping = 0.95
export (float) var shoot_cooldown = 0.25
export (float) var drill_cooldown = 0.75
export (float) var drill_time = 1
export (float) var invulnerability_time = 2

export (PackedScene) var Bullet

var velocity = Vector2(0, 0)
var state = IDLE

var can_shoot = true
var can_drill = true

func _prepare_timers():
    $ShootCooldown.wait_time = shoot_cooldown
    $DrillCooldown.wait_time = drill_cooldown
    $DrillTimer.wait_time = drill_time
    $InvulnerabilityTimer.wait_time = invulnerability_time

func _connect_signals():
    $ShootCooldown.connect("timeout", self, "_on_ShootCooldown_timeout")
    $DrillCooldown.connect("timeout", self, "_on_DrillCooldown_timeout")
    $DrillTimer.connect("timeout", self, "_on_DrillTimer_timeout")
    $InvulnerabilityTimer.connect("timeout", self, "_on_InvulnerabilityTimer_timeout")

func _idle():
    $AnimationPlayer.play("idle")

func _shoot():
    can_shoot = false

    var pos = $Muzzle.global_position
    var dir = rotation

    emit_signal("shoot", Bullet, pos, dir)
    $ShootCooldown.start()

    set_state(IDLE)

func _drill():
    can_drill = false

    $AnimationPlayer.play("drill")
    $DrillTimer.start()

func _hit():
    $InvulnerabilityTimer.start()

func set_state(new_state):
    if state == new_state:
        return

    state = new_state
    match state:
        IDLE:
            _idle()
        SHOOT:
            _shoot()
        DRILL:
            _drill()
        STUN:
            _hit()

func _handle_input():
    ###########
    # Movement

    var movement = Vector2(0, 0)
    if Input.is_action_pressed("move_up"):
        movement.y -= 1
    if Input.is_action_pressed("move_left"):
        movement.x -= 1
    if Input.is_action_pressed("move_right"):
        movement.x += 1
    if Input.is_action_pressed("move_down"):
        movement.y += 1

    if movement == Vector2(0, 0):
        velocity *= damping
    else:
        velocity = movement * move_speed

    ##########
    # Attacks

    if Input.is_action_pressed("shoot") and state == IDLE and can_shoot:
        set_state(SHOOT)

    elif Input.is_action_pressed("drill") and state == IDLE and can_drill:
        set_state(DRILL)

func _ready():
    _prepare_timers()
    _connect_signals()

    state = IDLE
    can_shoot = true
    can_drill = true

func _process(delta):
    _handle_input()

    position += velocity * delta

##################
# Event callbacks

func _on_ShootCooldown_timeout():
    can_shoot = true

func _on_DrillCooldown_timeout():
    can_drill = true

func _on_DrillTimer_timeout():
    $DrillCooldown.start()
    set_state(IDLE)

func _on_InvulnerabilityTimer_timeout():
    set_state(IDLE)