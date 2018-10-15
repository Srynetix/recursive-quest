extends Area2D

# Spaceship script.

signal shoot(bullet, pos, dir)
signal exploded
signal dead
signal win

enum State { IDLE, SHOOT, DRILL, DEAD, STUN, SHRUNK, WIN }
enum Turret { LEFT, RIGHT }

export (Vector2) var move_speed = Vector2(50, 200)
export (float) var damping = 0.85
export (float) var shoot_cooldown = 0.1
export (float) var drill_cooldown = 0.75
export (float) var drill_time = 0.75
export (float) var breaks_coef = 0.7
export (float) var rotation_speed = 1.5
export (Vector2) var max_velocity = Vector2(500, 300)
export (Vector2) var initial_velocity = Vector2(400, 0)

export (PackedScene) var Bullet

var velocity = Vector2(0, 0)
var state = State.IDLE

var can_shoot = true
var can_drill = true
var current_turret = Turret.LEFT

var is_rotating = false
var rotation_zone = null
var rotation_target = 0
var rotation_step = 0

var message_system = load("res://elements/spaceship/MessageSystem.gd").new()

func kill():
    _set_state(State.DEAD)

func _prepare_timers():
    $ShootCooldown.wait_time = shoot_cooldown
    $DrillCooldown.wait_time = drill_cooldown
    $DrillTimer.wait_time = drill_time

func _connect_signals():
    $ShootCooldown.connect("timeout", self, "_on_ShootCooldown_timeout")
    $DrillCooldown.connect("timeout", self, "_on_DrillCooldown_timeout")
    $DrillTimer.connect("timeout", self, "_on_DrillTimer_timeout")
    connect("body_entered", self, "_on_body_entered")
    connect("area_entered", self, "_on_area_entered")

func _idle():
    $AnimationPlayer.play("idle")

func _change_turret():
    if current_turret == Turret.LEFT:
        current_turret = Turret.RIGHT
    else:
        current_turret = Turret.LEFT

func _get_current_turret_position():
    if current_turret == Turret.LEFT:
        return $Turrets/LeftMuzzle.global_position
    else:
        return $Turrets/RightMuzzle.global_position

func _shoot():
    can_shoot = false

    var pos = _get_current_turret_position()
    var dir = rotation

    emit_signal("shoot", Bullet, pos, dir)
    $ShootCooldown.start()
    $LaserSound.play()
    _change_turret()

    _set_state(State.IDLE)

func _start_rotation(zone):
    if is_rotating and rotation_zone != zone:
        # Finish prev rotation
        rotation = rotation_target
        is_rotating = false

    if !is_rotating:
        is_rotating = true
        rotation_zone = zone

        var rotation_deg = rad2deg(rotation)
        var rotation_target_deg = int(zone.rotation_value)
        var deg_diff = rotation_target_deg - rotation_deg

        # Get shortest rotation
        if deg_diff > 180:
            rotation_deg += 360
        elif deg_diff < -180:
            rotation_target_deg += 360
        deg_diff = rotation_target_deg - rotation_deg

        rotation = deg2rad(rotation_deg)
        rotation_target = deg2rad(rotation_target_deg)
        rotation_step = deg2rad(deg_diff)

func _update_rotation(delta):
    if rotation_step > 0:
        rotation = min(rotation + (rotation_step * delta * rotation_speed), rotation_target)
    else:
        rotation = max(rotation + (rotation_step * delta * rotation_speed), rotation_target)

    if Utils.float_eq(rotation, rotation_target):
        is_rotating = false
        rotation = deg2rad(int(rad2deg(rotation)) % 360)
        rotation_target = deg2rad(int(rad2deg(rotation_target)) % 360)

func _level_exit():
    emit_signal("win")

func _drill():
    can_drill = false

    $DrillSound.play()
    $AnimationPlayer.play("drill")
    $Particles/Drill.emitting = true
    $DrillTimer.start()

func _hit():
    $InvulnerabilityTimer.start()

func _set_state(new_state):
    if state == new_state:
        return

    state = new_state
    match state:
        State.IDLE:
            _idle()
        State.SHOOT:
            _shoot()
        State.DRILL:
            _drill()
        State.STUN:
            _hit()
        State.DEAD:
            _explode()
        State.WIN:
            _level_exit()

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

    if movement.x == 0:
        velocity.x *= damping
    else:
        velocity.x += movement.x * move_speed.x

    if movement.y == 0:
        velocity.y *= damping
    else:
        velocity.y += movement.y * move_speed.y

    velocity.x = clamp(velocity.x, -initial_velocity.x * breaks_coef, max_velocity.x)
    velocity.y = clamp(velocity.y, -max_velocity.y, max_velocity.y)

    ##########
    # Attacks

    if state == State.SHRUNK:
        return

    if Input.is_action_pressed("shoot") and state == State.IDLE and can_shoot:
        _set_state(State.SHOOT)

    elif Input.is_action_pressed("drill") and state == State.IDLE and can_drill:
        _set_state(State.DRILL)

func _ready():
    message_system.initialize($Label)

    _prepare_timers()
    _connect_signals()

    state = State.IDLE
    can_shoot = true
    can_drill = true

    $Particles/Engine.emitting = true

func _process(delta):
    message_system._process(delta)

    if state == State.DEAD or state == State.WIN:
        return

    _handle_input()

    var final_velocity = (initial_velocity + velocity).rotated(rotation)
    if is_rotating:
        _update_rotation(delta)
        final_velocity /= 2

    position += final_velocity * delta

func _explode():
    message_system.show_message("Oops...")
    $CrashSound.play()

    $Particles/Drill.emitting = false
    $Particles/Engine.emitting = false
    $Particles/Explosion.emitting = true

    $AnimationPlayer.play("explosion")
    emit_signal("exploded")

    yield($AnimationPlayer, "animation_finished")
    emit_signal("dead")

    queue_free()

##################
# Event callbacks

func _on_ShootCooldown_timeout():
    can_shoot = true

func _on_DrillCooldown_timeout():
    can_drill = true

func _on_DrillTimer_timeout():
    $DrillCooldown.start()
    $Particles/Drill.emitting = false

    if !state in [State.DEAD, State.WIN]:
        _set_state(State.IDLE)

func _on_body_entered(body):
    if body.is_in_group("walls"):
        _set_state(State.DEAD)
    elif body.is_in_group("rocks"):
        if state == State.DRILL:
            body.explode()
        else:
            _set_state(State.DEAD)
    elif body.is_in_group("barriers"):
        if state == State.DRILL:
            body.explode()
        else:
            _set_state(State.DEAD)

func _on_area_entered(area):
    if area.is_in_group("rotation_zone"):
        $ZoneSound.play()
        _start_rotation(area)
    elif area.is_in_group("shrink_zone"):
        $AnimationPlayer.play("shrink")
        $Particles/Explosion.emitting = true
        max_velocity /= 4
        move_speed /= 4
        initial_velocity /= 4
        _set_state(State.SHRUNK)
    elif area.is_in_group("pyramid"):
        _set_state(State.WIN)
    elif area.is_in_group("text_zone"):
        message_system.show_message(area.text)
        area.queue_free()
