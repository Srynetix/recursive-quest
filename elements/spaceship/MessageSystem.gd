extends Node

# Message system

enum State { NONE, SHOWING, HIDING }

var state = State.NONE

var label = null
var current_message = ""
var current_character_idx = 0

var message_show_elapsed_time = 0
var message_show_delay = 0.025

var message_hide_elapsed_time = 0
var message_hide_delay = 2

func initialize(label_element):
    label = label_element

func show_message(msg):
    current_message = msg
    current_character_idx = 0
    message_show_elapsed_time = 0
    message_hide_elapsed_time = 0

    label.modulate = Color(1, 1, 1, 0)

    _set_state(State.SHOWING)

func _set_state(value):
    state = value

func _update_message(delta):
    if state == State.SHOWING:
        if label.modulate.a < 1:
            label.modulate.a = min(label.modulate.a + delta * 2, 1)

        var should_update = false
        message_show_elapsed_time += delta
        if message_show_elapsed_time > message_show_delay:
            should_update = true
            message_show_elapsed_time = 0

        if should_update:
            if current_character_idx > current_message.length():
                current_message = ""
                current_character_idx = 0
                message_hide_elapsed_time = 0
                _set_state(State.HIDING)
            else:
                var txt = current_message.substr(0, current_character_idx)
                label.text = txt
                current_character_idx += 1

    elif state == State.HIDING:
        var should_hide = false
        message_hide_elapsed_time += delta

        if message_hide_elapsed_time > message_hide_delay * 0.65:
            if label.modulate.a > 0:
                label.modulate.a = max(label.modulate.a - delta * 2, 0)

        if message_hide_elapsed_time > message_hide_delay:
            should_hide = true
            message_hide_elapsed_time = 0

        if should_hide:
            label.text = ""
            _set_state(State.NONE)

func _process(delta):
    if state != State.NONE:
        _update_message(delta)
