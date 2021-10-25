extends Node
class_name SongManager
# Interface for the song manager, every method here can (and should) be overrided 

#==== PRIVATE ====
var _queue = []  # song queue
var _current_song: Song  # current song


##### PUBLIC METHODS #####
# adds a song to the queue of the song manager
func add_to_queue(_song: Song, _effect: EffectManager) -> void:
	pass


# stops the current song entirely with an effect
func stop_current(_effect: EffectManager) -> void:
	pass


# applies a "neutral" effect on the song
func apply_effect(_effect: EffectManager) -> void:
	pass


# returns the current song playing (to maybe bind some values, idk)
func get_current() -> Song:
	return _current_song
