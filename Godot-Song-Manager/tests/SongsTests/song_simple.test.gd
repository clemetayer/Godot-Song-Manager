extends WAT.Test
# Doc : https://github.com/AlexDarigan/WAT

# Note : should be set in debug mode, because without it, it fails to load the song_anim_player for some reason in normal mode

##### VARIABLES #####
var song_simple: SongSimple
var song_manager: SongManager
var song_simple_path = "res://Example/Songs/Scenes/Song2/Song2.tscn"


##### PROCESSING #####
func pre():
	song_manager = StandardSongManager.new()
	add_child(song_manager)
	song_simple = load(song_simple_path).instance()
	song_manager.add_child(song_simple)


func post():
	song_manager.queue_free()


func title() -> String:
	return "Test of the simple song implementation"


##### UTILS #####


##### TEST FUNCTIONS #####
# Test of the init functions (tracks and buses)
func test_init() -> void:
	# Initialization
	song_simple.init()
	# -- global song parameters
	asserts.is_true(song_simple._tracks.has(song_simple.name), "_tracks has root song")
	asserts.is_not_equal(
		-1,
		AudioServer.get_bus_index(song_simple._tracks[song_simple.name].bus),
		"root song bus set correctly"
	)
	asserts.is_equal(
		1,
		AudioServer.get_bus_effect_count(
			AudioServer.get_bus_index(song_simple._tracks[song_simple.name].bus)
		),
		"root song bus has 1 effect"
	)
	asserts.is_equal(
		0.0, song_simple._tracks[song_simple.name].volume, "root song volume set to 0.0"
	)
	asserts.is_false(
		song_simple._tracks[song_simple.name].play_all, "play_all set correclty on root song"
	)
	# -- tracks parameters
	for child in song_simple.get_children():
		if child is AudioStreamPlayer:
			asserts.is_true(song_simple._tracks.has(child.name), "_tracks has %s" % child.name)
			asserts.is_not_equal(
				-1,
				AudioServer.get_bus_index(song_simple._tracks[child.name].bus),
				"%s bus set correctly" % child.name
			)
			asserts.is_equal(
				1,
				AudioServer.get_bus_effect_count(
					AudioServer.get_bus_index(song_simple._tracks[child.name].bus)
				),
				"%s bus has 1 effect" % child.name
			)
			asserts.is_equal(
				0.0, song_simple._tracks[child.name].volume, "%s volume set to 0.0" % child.name
			)
			asserts.is_equal(
				song_simple.get_path_to(child),
				song_simple._tracks[child.name].path,
				"%s path set correctly" % child.name
			)
			asserts.is_false(
				song_simple._tracks[child.name].play, "%s play set to false" % child.name
			)
	describe("Test of the track init")


# test of the play function
func test_play() -> void:
	# Initialization
	song_simple.init()
	# Test to play all the tracks
	song_simple._tracks[song_simple.name].play_all = true
	var effect_array = song_simple.play()
	var compare_effect_array = [
		{
			"object": song_simple,
			"interpolate_value": "%s:%s:%s" % ["_tracks", song_simple.name, "volume"],
			"interpolate_type": "property",
			"type": "volume",
			"fade_in": true
		},
		{
			"object": song_simple,
			"interpolate_value": "update_volumes",
			"interpolate_type": "method",
			"type": "volume",
			"fade_in": true
		},
		{
			"object":
			AudioServer.get_bus_effect(
				AudioServer.get_bus_index(song_simple._tracks[song_simple.name].bus),
				song_simple.bus_effects.filter
			),
			"interpolate_value": "cutoff_hz",
			"interpolate_type": "property",
			"type": "filter",
			"fade_in": true
		}
	]
	asserts.is_equal(
		effect_array.size(),
		compare_effect_array.size(),
		"effect array has the same number of elements"
	)
	if effect_array.size() == compare_effect_array.size():
		var same_effects := true
		for i in range(effect_array.size()):
			asserts.is_true(
				effect_array[i].hash() == compare_effect_array[i].hash(),
				"item %s is set correctly" % effect_array[i]
			)
	yield(until_timeout(0.25), YIELD)  # Waits for the play value to be actually set
	for child in song_simple.get_children():
		if child is AudioStreamPlayer:
			asserts.is_true(child.playing, "%s is playing" % child.name)
			asserts.is_true(
				song_simple._tracks[child.name].play, "%s set to play in parameters" % child.name
			)
	describe("Test of the play function")


# test of the update function
func test_update() -> void:
	# Initialization
	song_simple.init()
	# plays the tracks "Chords" and "Bass"
	song_simple._tracks["Chords"].play = true
	song_simple._tracks["Bass"].play = true
	song_simple.play()
	# updates the current song with animation "ArpeggioChords"
	var new_song = load(song_simple_path).instance()
	new_song.init()
	new_song._tracks["Chords"].play = true
	new_song._tracks["Drums"].play = true
	var effect_array = song_simple.update(new_song)
	var compare_effect_array = [
		{
			"object": song_simple,
			"interpolate_value": "%s:%s:%s" % ["_tracks", "Drums", "volume"],
			"interpolate_type": "property",
			"type": "volume",
			"fade_in": true
		},
		{
			"object": song_simple,
			"interpolate_value": "update_volumes",
			"interpolate_type": "method",
			"type": "volume",
			"fade_in": true
		},
		{
			"object":
			AudioServer.get_bus_effect(
				AudioServer.get_bus_index(song_simple._tracks["Drums"].bus),
				song_simple.bus_effects.filter
			),
			"interpolate_value": "cutoff_hz",
			"interpolate_type": "property",
			"type": "filter",
			"fade_in": true
		},
		{
			"object": song_simple,
			"interpolate_value": "%s:%s:%s" % ["_tracks", "Bass", "volume"],
			"interpolate_type": "property",
			"type": "volume",
			"fade_in": false
		},
		{
			"object": song_simple,
			"interpolate_value": "update_volumes",
			"interpolate_type": "method",
			"type": "volume",
			"fade_in": false
		},
		{
			"object":
			AudioServer.get_bus_effect(
				AudioServer.get_bus_index(song_simple._tracks["Bass"].bus),
				song_simple.bus_effects.filter
			),
			"interpolate_value": "cutoff_hz",
			"interpolate_type": "property",
			"type": "filter",
			"fade_in": false
		}
	]
	asserts.is_equal(
		effect_array.size(),
		compare_effect_array.size(),
		"effect array has the same number of elements"
	)
	if effect_array.size() == compare_effect_array.size():
		var same_effects := true
		for i in range(effect_array.size()):
			asserts.is_true(
				effect_array[i].hash() == compare_effect_array[i].hash(),
				"item %s is set correctly" % effect_array[i]
			)
	song_manager.emit_signal("effect_done")
	asserts.is_true(song_simple.get_node("Chords").playing, "%s is playing" % "Chords")
	asserts.is_true(song_simple.get_node("Drums").playing, "%s is playing" % "Drums")
	asserts.is_false(song_simple.get_node("Bass").playing, "%s is not playing" % "Bass")
	describe("Test of the update function")


# test of the stop function
func test_stop_song() -> void:
	# Initialization
	song_simple.init()
	# Test to play all the tracks
	song_simple._tracks[song_simple.name].play_all = true
	song_simple.play()
	var effect_array = song_simple.stop()
	var compare_effect_array = [
		{
			"object": song_simple,
			"interpolate_value": "%s:%s:%s" % ["_tracks", song_simple.name, "volume"],
			"interpolate_type": "property",
			"type": "volume",
			"fade_in": false
		},
		{
			"object": song_simple,
			"interpolate_value": "update_volumes",
			"interpolate_type": "method",
			"type": "volume",
			"fade_in": false
		},
		{
			"object":
			AudioServer.get_bus_effect(
				AudioServer.get_bus_index(song_simple._tracks[song_simple.name].bus),
				song_simple.bus_effects.filter
			),
			"interpolate_value": "cutoff_hz",
			"interpolate_type": "property",
			"type": "filter",
			"fade_in": false
		}
	]
	asserts.is_equal(
		effect_array.size(),
		compare_effect_array.size(),
		"effect array has the same number of elements"
	)
	if effect_array.size() == compare_effect_array.size():
		var same_effects := true
		for i in range(effect_array.size()):
			asserts.is_true(
				effect_array[i].hash() == compare_effect_array[i].hash(),
				"item %s is set correctly" % effect_array[i]
			)
	asserts.is_equal(song_simple._stop_queue[0], [song_simple.name], "Stop array set correctly")
	song_manager.emit_signal("effect_done")
	for child in song_simple.get_children():
		if child is AudioStreamPlayer:
			asserts.is_false(child.playing, "%s is stopped" % child.name)
	for track in song_simple._tracks.keys():
		asserts.is_equal(
			-1,
			AudioServer.get_bus_index(song_simple._tracks[track].bus),
			"%s bus was removed" % song_simple._tracks[track].bus
		)
	describe("Test of the stop function")
