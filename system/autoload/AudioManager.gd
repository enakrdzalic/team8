extends Node

signal music_state_changed(state: StringName)

var current_music_state: StringName = &"exploration"

func set_music_state(state: StringName) -> void:
    if current_music_state == state:
        return

    current_music_state = state
    music_state_changed.emit(state)

    # Later: update the FMOD music event parameter