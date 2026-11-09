extends Node

enum GameState {
    MAIN_MENU,
    PLAYING,
    PAUSED,
    GAME_OVER
}

signal state_changed(new_state: GameState)

var current_state: GameState = GameState.MAIN_MENU

func set_state(new_state: GameState) -> void:
    if current_state == new_state:
        return

    current_state = new_state
    get_tree().paused = (
        new_state == GameState.PAUSED
    )
    state_changed.emit(new_state)
