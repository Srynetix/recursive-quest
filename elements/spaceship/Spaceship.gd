extends Area2D

####################
# Spaceship script.

#########
# Signals

# Shoot signal
#   - bullet:   Bullet to spawn
#   - pos:      Bullet position
#   - dir:      Bullet direction
signal shoot(bullet, pos, dir)
# Treasure unlocked
#   - treasure_name:    Treasure name
signal treasure_unlocked(treasure_name)
signal shrunk
signal exploded
signal dead
signal win

# State enum
enum State {
    IDLE,   # Moving
    DRILL,  # Drilling
    DEAD,   # Dead
    AUTO,   # Autopilot
    WIN     # Win!
}

# Shooting state enum
enum ShootState {
    IDLE,   # No shooting
    SHOOT   # Shooting
}

# Turret enum
enum Turret { LEFT, RIGHT }

###############
# Exported vars

# Is disabled
export (bool) var disabled = false

# Move speed
export (Vector2) var move_speed = Vector2(50, 200)
# Autopilot speed
export (Vector2) var autopilot_speed = Vector2(200, 200)
# Damping
export (float) var damping = 0.85
# Breaks force
export (float) var breaks_force = 0.7
# Rotation speed
export (float) var rotation_speed = 1.5
# Max velocity
export (Vector2) var max_velocity = Vector2(400, 300)
# Initial velocity
export (Vector2) var initial_velocity = Vector2(400, 0)

# Shoot cooldown
export (float) var shoot_cooldown = 0.1
# Drill cooldown
export (float) var drill_cooldown = 0.75
# Drill time
export (float) var drill_time = 0.75

# Bullet scene
export (PackedScene) var Bullet

##############
# Private vars

var velocity = Vector2(0, 0)
var movement = Vector2(0, 0)
var state = State.IDLE
var shoot_state = ShootState.IDLE

var can_shoot = true
var can_drill = true
var current_turret = Turret.LEFT

var is_rotating = false
var rotation_zone = null
var rotation_target = 0
var rotation_step = 0

var autopilot_target = null

var message_system = load("res://elements/spaceship/MessageSystem.gd").new()

################
# Public methods

func kill():
    """Kill spaceship."""
    _set_state(State.DEAD)

func set_autopilot(target):
    """
    Set autopilot.

    :param target:  Target position
    """
    autopilot_target = target
    _set_state(State.AUTO)

#################
# Private methods

func _swap_turret():
    if current_turret == Turret.LEFT:
        current_turret = Turret.RIGHT
    else:
        current_turret = Turret.LEFT

func _get_current_turret_position():
    if current_turret == Turret.LEFT:
        return $Turrets/LeftMuzzle.global_position
    else:
        return $Turrets/RightMuzzle.global_position

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
    connect("area_exited", self, "_on_area_exited")

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
        if deg_diff >= 180:
            rotation_deg += 360
        elif deg_diff <= -180:
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

func _set_state(new_state):
    if state == new_state:
        return

    state = new_state
    match state:
        State.IDLE:
            _state_idle()
        State.DRILL:
            _state_drill()
        State.DEAD:
            _state_explode()
        State.WIN:
            _state_win()

func _set_shoot_state(new_state):
    if shoot_state == new_state:
        return

    shoot_state = new_state
    match shoot_state:
        ShootState.SHOOT:
            _shoot_state_shoot()

func _handle_input():
    movement = Vector2(0, 0)

    if Input.is_action_pressed("move_up"):
        movement.y -= 1
    if Input.is_action_pressed("move_left"):
        movement.x -= 1
    if Input.is_action_pressed("move_right"):
        movement.x += 1
    if Input.is_action_pressed("move_down"):
        movement.y += 1

func _handle_movement():
    if movement.x == 0:
        velocity.x *= damping
    else:
        velocity.x += movement.x * move_speed.x

    if movement.y == 0:
        velocity.y *= damping
    else:
        velocity.y += movement.y * move_speed.y

    velocity.x = clamp(velocity.x, -initial_velocity.x * breaks_force, max_velocity.x)
    velocity.y = clamp(velocity.y, -max_velocity.y, max_velocity.y)

func _handle_attacks():
    if state in [State.AUTO, State.DEAD, State.WIN]:
        return

    if Input.is_action_pressed("shoot") and shoot_state == ShootState.IDLE and can_shoot:
        _set_shoot_state(ShootState.SHOOT)

    elif Input.is_action_pressed("drill") and state == State.IDLE and can_drill:
        _set_state(State.DRILL)

###################
# Lifecycle methods

func _ready():
    if disabled:
        set_process(false)

    message_system.initialize($Label)

    _prepare_timers()
    _connect_signals()

    state = State.IDLE
    can_shoot = true
    can_drill = true

    $Particles/Engine.emitting = true

func _process(delta):
    message_system._process(delta)

    if state in [State.DEAD, State.WIN]:
        return

    _handle_input()
    _handle_movement()
    _handle_attacks()

    # Velocity
    var final_velocity = (initial_velocity + velocity).rotated(rotation)
    if is_rotating:
        _update_rotation(delta)
        final_velocity /= 2

    if state == State.AUTO:
        var dir = (autopilot_target - global_position).normalized()
        position += dir * autopilot_speed * Vector2(delta, delta)
    else:
        position += final_velocity * delta

###############
# State methods

func _state_idle():
    $AnimationPlayer.play("idle")

func _shoot_state_shoot():
    can_shoot = false

    var pos = _get_current_turret_position()
    var dir = rotation
    emit_signal("shoot", Bullet, pos, dir)
    $ShootCooldown.start()
    $LaserSound.play()
    _swap_turret()

    _set_shoot_state(ShootState.IDLE)

func _state_win():
    $AnimationPlayer.play("win")
    yield($AnimationPlayer, "animation_finished")
    emit_signal("win")

func _state_drill():
    can_drill = false

    $DrillSound.play()
    $AnimationPlayer.play("drill")
    $Particles/Drill.emitting = true
    $DrillTimer.start()

func _state_explode():
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

#################
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
        if int(rad2deg(rotation)) != area.rotation_value:
            $ZoneSound.play()
            _start_rotation(area)

    elif area.is_in_group("shrink_zone"):
        $AnimationPlayer.play("shrink")
        $Particles/Explosion.emitting = true
        max_velocity /= 4
        move_speed /= 4
        initial_velocity /= 4
        emit_signal("shrunk")

    elif area.is_in_group("pyramid"):
        if !area.disabled:
            _set_state(State.WIN)

    elif area.is_in_group("text_zone"):
        message_system.show_message(area.get_text(), area.text_speed)
        area.queue_free()

    elif area.is_in_group("treasures"):
        area.shrink()
        emit_signal("treasure_unlocked", area.treasure_name)

    elif area.is_in_group("surprise"):
        $AnimationPlayer.play("surprise")

func _on_area_exited(area):
    if area.is_in_group("game_zone"):
        _set_state(State.DEAD)
