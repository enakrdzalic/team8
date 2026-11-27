extends Node

enum GameState {
    MAIN_MENU,
    PLAYING,
    PAUSED,
    GAME_OVER
}

const KILL_REWARD := 10
const DRAG_REWARD := 50

signal state_changed(new_state: GameState)

var current_state: GameState = GameState.MAIN_MENU
var fade_from_black := false

# Run stats. The night counters reset every night, the total carries over.
var night := 1
var monsters_killed := 0
var monsters_dragged := 0
var total_money := 0

func new_game() -> void:
    night = 1
    monsters_killed = 0
    monsters_dragged = 0
    total_money = 0

func record_kill() -> void:
    monsters_killed += 1

func record_drag() -> void:
    monsters_dragged += 1

func kill_earnings() -> int:
    return monsters_killed * KILL_REWARD

func drag_earnings() -> int:
    return monsters_dragged * DRAG_REWARD

# Banks this night's earnings. Call once, when the night ends.
func finish_night() -> void:
    total_money += kill_earnings() + drag_earnings()

func start_next_night() -> void:
    night += 1
    monsters_killed = 0
    monsters_dragged = 0

func set_state(new_state: GameState) -> void:
    if current_state == new_state:
        return

    current_state = new_state
    get_tree().paused = (
        new_state == GameState.PAUSED
    )
    state_changed.emit(new_state)
