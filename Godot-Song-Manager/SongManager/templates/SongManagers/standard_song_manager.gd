extends SongManager
class_name StandardSongManager
# A basic song manager that should fit a lot of cases (contrary to a Song or a Transition)

# Note : en cas d'update song et de cancel de tween, que fait-on ? Prendre un exemple

##### SIGNALS #####
signal effect_done  # when an effect is done

#==== PRIVATE ====
var _current_effects = []  # current effects playing, to cancel these if necessary


# Called every frame. 'delta' is the elapsed time since the previous frame. Remove the "_" to use it.
func _process(_delta):
	if _queue.size() > 0:  # queue not empty
		_queue_management()


##### PUBLIC METHODS #####
# adds a song to the queue of the song manager
func add_to_queue(song: Song, effect: EffectManager) -> void:
	_queue.append({"song": song, "effect": effect})  # just adds to the queue, the queue management is done in process (to keep things kind of in sync)


# stops the current song entirely
func stop_current(effect: EffectManager) -> void:
	var effect_data := _current_song.stop()
	if effect != null:
		effect.init_tween(effect_data)
		_cancel_current_effects(effect)
		add_child(effect.tween)
		var _err = effect.tween.start()
		_current_effects.append(effect)
		yield(effect.tween, "tween_all_completed")
		_current_effects.erase(effect)
		effect.tween.queue_free()
	_current_song.queue_free()
	emit_signal("effect_done")


# applies an auto transition to the current song
func apply_effect(effect: EffectManager, params = {}) -> void:
	var effect_data := _current_song.get_neutral_effect_data(params)
	if effect != null:
		effect.init_tween(effect_data)
		_cancel_current_effects(effect)
		add_child(effect.tween)
		var _err = effect.tween.start()
		_current_effects.append(effect)
		yield(effect.tween, "tween_all_completed")
		_current_effects.erase(effect)
		effect.tween.queue_free()
	emit_signal("effect_done")


# returns the current song playing (to maybe bind some values, idk)
func get_current() -> Song:
	return _current_song


##### PROTECTED METHODS #####
# management of the queue
func _queue_management():
	if _queue.size() > 1:  # just keeps the last instruction
		for _idx in range(0, _queue.size() - 2):
			_queue.remove(0)
	var el = _queue.pop_back()  # song to transition to
	if is_instance_valid(_current_song):  # something already playing
		if el.song.name == _current_song.name:  # same song
			_update_current(el.song, el.effect)
		else:
			_switch_song(el.song, el.effect)
	else:  # nothing currently playing
		_play_song(el.song, el.effect)


# plays the song immediately with some effects at the start (if needed)
func _play_song(song: Song, effect: EffectManager):
	add_child(song)
	var effect_data := song.play()
	_current_song = song
	if effect != null:
		effect.init_tween(effect_data)
		add_child(effect.tween)
		var _err = effect.tween.start()
		_current_effects.append(effect)  # Note : should not be any other effect manager (because nothing was playing before)
		yield(effect.tween, "tween_all_completed")
		_current_effects.erase(effect)
		effect.tween.queue_free()
	emit_signal("effect_done")


# updates the current song with the new one in parameters
func _update_current(song: Song, effect: EffectManager):
	var effect_data := _current_song.update(song)
	if effect != null:
		effect.init_tween(effect_data)
		_cancel_current_effects(effect)
		add_child(effect.tween)
		var _err = effect.tween.start()
		_current_effects.append(effect)
		yield(effect.tween, "tween_all_completed")
		_current_effects.erase(effect)
		effect.tween.queue_free()
	emit_signal("effect_done")


# switches the current song to a new one with an effect
func _switch_song(song: Song, effect: EffectManager):
	var effect_data := _current_song.stop()
	if effect != null:
		effect.init_tween(effect_data)
		_cancel_current_effects(effect)
		add_child(effect.tween)
		var _err = effect.tween.start()
		_current_effects.append(effect)
		yield(effect.tween, "tween_all_completed")
		_current_effects.erase(effect)
		effect.tween.queue_free()
	emit_signal("effect_done")
	_current_song.queue_free()
	_play_song(song, effect)


# cancels an effect if it is already playing
func _cancel_current_effects(effect_manager: EffectManager):
	for cur_effect in _current_effects:
		cur_effect.cancel_same_effects(effect_manager)

##### SIGNAL MANAGEMENT #####
# Functions that should be triggered when a specific signal is received
