extends Control

######################
# Virtual input script

# Joystick moved
#   - movement: Movement
#   - pressed:  Is the movement pressed or released?
#   - force:    Movement force
signal joystick_moved(movement, pressed, force)

# Button pressed
#   - button:   Button
#   - pressed:  Is the button pressed or released?
signal button_pressed(button, pressed)

###############
# Exported vars

# Show/Hide the virtual input
export (bool) var disabled = false
# Only show the virtual input on mobile device
export (bool) var only_mobile = true
# Debug events in console
export (bool) var debug_events = false
# Debug input with on-screen lights
export (bool) var debug_lights = false
# Automatically register an input action on press/release
export (bool) var auto_actions = true

# Left action to register
export (String) var left_action = 'left'
# Right action to register
export (String) var right_action = 'right'
# Up action to register
export (String) var up_action = 'up'
# Down action to register
export (String) var down_action = 'down'
# 'A' button action to register
export (String) var a_action = 'a'
# 'B' button action to register
export (String) var b_action = 'b'
# 'C' button action to register
export (String) var c_action = 'c'

# Is the 'A' button visible
export (bool) var a_visible = true
# Is the 'B' button visible
export (bool) var b_visible = true
# Is the 'C' button visible
export (bool) var c_visible = true

##############
# Private vars

const JOYSTICK_DEADZONE = 0.30

onready var joystick = $Margin/VBox/HBox/Joystick
onready var joystick_ball = $Margin/VBox/HBox/Joystick/Container/Ball
onready var a_btn = $Margin/VBox/HBox/Buttons/A
onready var b_btn = $Margin/VBox/HBox/Buttons/B
onready var c_btn = $Margin/VBox/HBox/Buttons/C

onready var debug_ui = $Margin/VBox/DebugHBox

var touch_system = preload("res://utils/virtual_input/TouchSystem.gd").new()

var virtual_input_state = _generate_empty_input_state()
var joystick_touch_idx = -1
var a_touch_idx = -1
var b_touch_idx = -1
var c_touch_idx = -1

################
# Public methods

func get_virtual_input_state(key):
    """
    Get virtual input state for one key.

    :param key: Key
    """
    var state = virtual_input_state[key]
    if typeof(state) == TYPE_ARRAY:
        return state[0]
    else:
        return state

func is_enabled():
    """Is the input enabled?"""
    if disabled:
        return false

    if only_mobile:
        var os_name = OS.get_name()
        return os_name == "Android" or os_name == "iOS"

    return true

#################
# Private methods

func _lighten_button(button):
    var col = button.modulate
    col.a = 0.95
    button.modulate = col

func _darken_button(button):
    var col = button.modulate
    col.a = 0.25
    button.modulate = col

func _generate_empty_input_state():
    return {
        "left": [false, 0],
        "right": [false, 0],
        "up": [false, 0],
        "down": [false, 0],
        "a": false,
        "b": false,
        "c": false
    }

func _action_press(action):
    if auto_actions and action != '':
        Input.action_press(action)

func _action_release(action):
    if auto_actions and action != '':
        Input.action_release(action)

func _reset_movement_state():
    for key in ["left", "right", "up", "down"]:
        virtual_input_state[key] = [false, 0]

    _action_release(left_action)
    _action_release(right_action)
    _action_release(up_action)
    _action_release(down_action)

func _update_debug_ui():
    for key in ["left", "right", "up", "down"]:
        var state_info = virtual_input_state[key]
        var state_val = state_info[0]
        var debug_key = key.capitalize()

        if state_val:
            debug_ui.get_node(debug_key).color = Color("#00ff00")
        else:
            debug_ui.get_node(debug_key).color = Color("#ffffff")

    for key in ["a", "b", "c"]:
        var state_val = virtual_input_state[key]
        var debug_key = key.capitalize()

        if state_val:
            debug_ui.get_node(debug_key).color = Color("#00ff00")
        else:
            debug_ui.get_node(debug_key).color = Color("#ffffff")

###################
# Lifecycle methods

func _ready():
    if !is_enabled():
        set_process_input(false)
        set_process(false)
        visible = false
        return

    if debug_events:
        connect("joystick_moved", self, "_on_joystick_moved")
        connect("button_pressed", self, "_on_button_pressed")

    touch_system.connect("touch_released", self, "_on_touch_released")

    debug_ui.visible = debug_lights
    a_btn.visible = a_visible
    b_btn.visible = b_visible
    c_btn.visible = c_visible

func _input(event):
    touch_system.handle_input(event)

    var joystick_rect = joystick.get_global_rect()
    var a_btn_rect = a_btn.get_global_rect()
    var b_btn_rect = b_btn.get_global_rect()
    var c_btn_rect = c_btn.get_global_rect()

    # Handle touch events
    if event is InputEventScreenTouch:
        var joystick_touch_data = touch_system.detect_touch_in_rect(joystick_rect)
        if joystick_touch_data != null:
            joystick_touch_idx = joystick_touch_data.touch_idx

        var a_touch_data = touch_system.detect_touch_in_rect(a_btn_rect)
        if a_touch_data != null:
            a_touch_idx = a_touch_data.touch_idx
            virtual_input_state["a"] = true
            _action_press(a_action)
            _lighten_button(a_btn)

        var b_touch_data = touch_system.detect_touch_in_rect(b_btn_rect)
        if b_touch_data != null:
            b_touch_idx = b_touch_data.touch_idx
            virtual_input_state["b"] = true
            _action_press(b_action)
            _lighten_button(b_btn)

        var c_touch_data = touch_system.detect_touch_in_rect(c_btn_rect)
        if c_touch_data != null:
            c_touch_idx = c_touch_data.touch_idx
            virtual_input_state["c"] = true
            _action_press(c_action)
            _lighten_button(c_btn)

    # Handle drag event
    if event is InputEventScreenDrag:
        if joystick_rect.has_point(event.position):
            var joystick_position = joystick.get_global_position() + joystick.get_size() / 2
            var mouse_joystick_vec = event.position - joystick_position
            var force = mouse_joystick_vec / (joystick.get_size() / 2)

            # Move joystick ball
            joystick_ball.rect_position = (joystick.get_size() / 2 - joystick_ball.get_size() / 2) + (force * joystick.get_size() / 2)

            # Reset movement
            _reset_movement_state()

            if abs(force.x) < JOYSTICK_DEADZONE:
                pass
            else:
                if force.x < 0:
                    virtual_input_state["left"] = [true, -force.x]
                    _action_press(left_action)
                else:
                    virtual_input_state["right"] = [true, force.x]
                    _action_press(right_action)
                _lighten_button(joystick)

            if abs(force.y) < JOYSTICK_DEADZONE:
                pass
            else:
                if force.y < 0:
                    virtual_input_state["up"] = [true, -force.y]
                    _action_press(up_action)
                else:
                    virtual_input_state["down"] = [true, force.y]
                    _action_press(down_action)
                _lighten_button(joystick)

func _process(delta):
    _update_debug_ui()

#################
# Event callbacks

func _on_joystick_moved(movement, force):
    print("Joystick: {movement} ({force})".format({
        "movement": movement,
        "force": force
    }))

func _on_button_pressed(button):
    print("Button: {button}".format({
        "button": button
    }))

func _on_touch_released(idx):
    if idx == joystick_touch_idx:
        joystick_touch_idx = -1
        _reset_movement_state()
        joystick_ball.rect_position = joystick.get_size() / 2 - joystick_ball.get_size() / 2
        _darken_button(joystick)

    if idx == a_touch_idx:
        a_touch_idx = -1
        virtual_input_state["a"] = false
        _action_release(a_action)
        _darken_button(a_btn)

    if idx == b_touch_idx:
        b_touch_idx = -1
        virtual_input_state["b"] = false
        _action_release(b_action)
        _darken_button(b_btn)

    if idx == c_touch_idx:
        c_touch_idx = -1
        virtual_input_state["c"] = false
        _action_release(c_action)
        _darken_button(c_btn)
