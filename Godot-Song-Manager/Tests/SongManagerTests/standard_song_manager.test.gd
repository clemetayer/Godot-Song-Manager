extends WAT.Test

# Doc : https://github.com/AlexDarigan/WAT

##### VARIABLES #####
var song_manager: StandardSongManager


##### PROCESSING #####
func pre():
	song_manager = StandardSongManager.new()
	add_child(song_manager)


func post():
	song_manager.queue_free()


func title() -> String:
	return "Test of the song manager"


##### TEST FUNCTIONS #####
# test of the add_to_queue method
func test_add_to_queue() -> void:
	var song := MockSong.new()
	var effect := MockEffectManager.new()
	song.name = "TestSong"
	watch(song_manager, "effect_done")
	watch(effect, "effect_done")
	song_manager.add_to_queue(song, effect)
	song_manager._process(0.1)
	asserts.is_true(song.playing, "Song is playing")
	asserts.is_false(song.updated, "Song did not update")
	asserts.is_false(song.neutral_effect_done, "Neutral effec not triggered")
	asserts.is_true(
		song_manager.get_node_or_null(song.name) != null,
		"Song added as a child of the song manager"
	)
	asserts.is_true(effect.properties_initiated, "Effect properties initiated")
	asserts.is_true(effect.effect_started, "Effect started")
	yield(until_signal(effect, "effect_done", 0.5), YIELD)
	yield(until_signal(song_manager, "effect_done", 0.5), YIELD)
	asserts.signal_was_emitted(song_manager, "effect_done")
	describe("Test add_to_queue")

# test of a song update
func test_song_update() -> void:
	var song := MockSong.new()
	var effect := MockEffectManager.new()
	song.name = "TestSong"
	watch(song_manager, "effect_done")
	song_manager.add_to_queue(song, effect)
	song_manager._process(0.1)
	yield(until_signal(song_manager, "effect_done", 0.5), YIELD)
	song_manager.add_to_queue(song, effect)
	song_manager._process(0.1)
	asserts.is_true(effect.properties_initiated, "Effect properties initiated")
	asserts.is_true(effect.effect_started, "Effect started")
	asserts.is_true(song.playing, "Song is playing")
	asserts.is_true(song.updated, "Song did update")
	asserts.is_false(song.neutral_effect_done, "Neutral effect triggered")
	yield(until_signal(song_manager, "effect_done", 0.5), YIELD)
	asserts.signal_was_emitted(song_manager, "effect_done")
	describe("Test song update")

# test of a song switch doesn't work so well, even in debug... Probably an issue with yield :/

# test of the stop_current method
func test_stop_current_method() -> void:
	var song := MockSong.new()
	var effect := MockEffectManager.new()
	song.name = "TestSong"
	watch(song_manager, "effect_done")
	song_manager.add_to_queue(song, effect)
	song_manager._process(0.1)
	yield(until_signal(song_manager, "effect_done", 0.5), YIELD)
	song_manager.stop_current(effect)
	song_manager._process(0.1)
	asserts.is_true(effect.properties_initiated, "Effect properties initiated")
	asserts.is_true(effect.effect_started, "Effect started")
	asserts.is_false(song.playing, "Song is not playing")
	asserts.is_false(song.updated, "Song did not update")
	asserts.is_false(song.neutral_effect_done, "Neutral effec not triggered")
	yield(until_signal(song_manager, "effect_done", 0.5), YIELD)
	asserts.signal_was_emitted(song_manager, "effect_done")
	describe("Test stop_current")


# test of the apply_effect method
func test_apply_effect_method() -> void:
	var song := MockSong.new()
	var effect := MockEffectManager.new()
	song.name = "TestSong"
	watch(song_manager, "effect_done")
	song_manager.add_to_queue(song, effect)
	song_manager._process(0.1)
	yield(until_signal(song_manager, "effect_done", 0.5), YIELD)
	song_manager.apply_effect(effect)
	song_manager._process(0.1)
	asserts.is_true(effect.properties_initiated, "Effect properties initiated")
	asserts.is_true(effect.effect_started, "Effect started")
	asserts.is_true(song.playing, "Song is playing")
	asserts.is_false(song.updated, "Song did not update")
	asserts.is_true(song.neutral_effect_done, "Neutral effect triggered")
	yield(until_signal(song_manager, "effect_done", 0.5), YIELD)
	asserts.signal_was_emitted(song_manager, "effect_done")
	describe("Test apply_effect")


# test of the get_current method
func test_get_current_method() -> void:
	var song := MockSong.new()
	var effect := MockEffectManager.new()
	song.name = "TestSong"
	song_manager.add_to_queue(song, effect)
	song_manager._process(0.1)
	var ret_song = song_manager.get_current()
	asserts.is_true(ret_song == song, "get current song returning the current song")
	describe("Test get_current")
