extends Node

signal scene_change_started(path: String)
signal scene_change_failed(path: String)

func change_scene(path: String) -> void:
    scene_change_started.emit(path)

    get_tree().paused = false

    var error := get_tree().change_scene_to_file(path)

    if error != OK:
        push_error("Cannot load scene: " + path)
        scene_change_failed.emit(path)