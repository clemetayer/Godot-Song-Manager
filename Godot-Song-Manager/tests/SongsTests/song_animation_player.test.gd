extends WAT.Test
# Doc : https://github.com/AlexDarigan/WAT

##### VARIABLES #####
var song_animation_player: SongAnimationPlayer
var song_manager : SongManager
var song_anim_player_path = "res://Example/Songs/Scenes/Song1/Song1.tscn"


##### PROCESSING #####
func pre():
	song_manager = StandardSongManager.new()
	add_child(song_manager)
	song_animation_player = load(song_anim_player_path).instance()
	song_manager.add_child(song_animation_player)
	

func post():
	song_manager.queue_free()


func title() -> String:
	return "Test of the song animation player"


##### UTILS #####
# resets the song to the standard parameters
func reset_song() -> void:
	for child in song_animation_player.get_children():
		if child is AudioStreamPlayer or child is AnimationPlayer:
			child.stop()
	song_animation_player._stop_queue = []


##### TEST FUNCTIONS #####
# Test of the init functions (tracks and buses)
func test_init() -> void:
	# Initialization
	song_animation_player._ready()
	# -- global song parameters
	asserts.is_true(
		song_animation_player._tracks.has(song_animation_player.name), "_tracks has root song"
	)
	asserts.is_not_equal(
		-1,
		AudioServer.get_bus_index(song_animation_player._tracks[song_animation_player.name].bus),
		"root song bus set correctly"
	)
	asserts.is_equal(
		1,
		AudioServer.get_bus_effect_count(
			AudioServer.get_bus_index(
				song_animation_player._tracks[song_animation_player.name].bus
			)
		),
		"root song bus has 1 effect"
	)
	asserts.is_equal(
		0.0,
		song_animation_player._tracks[song_animation_player.name].volume,
		"root song volume set to 0.0"
	)
	# -- tracks parameters
	for child in song_animation_player.get_children():
		if child is AudioStreamPlayer:
			asserts.is_true(
				song_animation_player._tracks.has(child.name), "_tracks has %s" % child.name
			)
			asserts.is_not_equal(
				-1,
				AudioServer.get_bus_index(song_animation_player._tracks[child.name].bus),
				"%s bus set correctly" % child.name
			)
			asserts.is_equal(
				1,
				AudioServer.get_bus_effect_count(
					AudioServer.get_bus_index(song_animation_player._tracks[child.name].bus)
				),
				"%s bus has 1 effect" % child.name
			)
			asserts.is_equal(
				0.0,
				song_animation_player._tracks[child.name].volume,
				"%s volume set to 0.0" % child.name
			)
			asserts.is_equal(
				song_animation_player.get_path_to(child),
				song_animation_player._tracks[child.name].path,
				"%s path set correctly" % child.name
			)
			for anim_name in song_animation_player._tracks[child.name].playing_in_animation:
				var anim: Animation = song_animation_player.get_node(song_animation_player.ANIMATION_PLAYER).get_animation(
					anim_name
				)
				asserts.is_not_equal(
					-1,
					anim.find_track(song_animation_player.get_path_to(child)),
					"%s is in animation %s" % [child.name, anim_name]
				)
	describe("Test of the track init")


# test of the play function
func test_play() -> void:
	# Initialization
	song_animation_player._ready()
	# Test of play All
	song_animation_player.ANIMATION = "All"
	var effect_array = song_animation_player.play()
	asserts.is_equal(
		effect_array,
		[
			{
				"object": song_animation_player,
				"interpolate_value": "%s:%s:%s" % ["_tracks", song_animation_player.name, "volume"],
				"interpolate_type": "property",
				"type": "volume",
				"fade_in": true
			},
			{
				"object": song_animation_player,
				"interpolate_value": "update_volumes",
				"interpolate_type": "method",
				"type": "volume",
				"fade_in": true
			},
			{
				"object":
				AudioServer.get_bus_effect(
					AudioServer.get_bus_index(
						song_animation_player._tracks[song_animation_player.name].bus
					),
					song_animation_player.bus_effects.filter
				),
				"interpolate_value": "cutoff_hz",
				"interpolate_type": "property",
				"type": "filter",
				"fade_in": true
			}
		],
		"effects sets correctly"
	)
	asserts.is_true(
		song_animation_player.get_node(song_animation_player.ANIMATION_PLAYER).is_playing(),
		"Animation player is playing"
	)
	asserts.is_equal(
		song_animation_player.get_node(song_animation_player.ANIMATION_PLAYER).current_animation,
		"All",
		"Animation All is currently playing"
	)
	for child in song_animation_player.get_children():
		if child is AudioStreamPlayer:
			asserts.is_true(child.playing, "%s is playing" % child.name)
	describe("Test of the play function")


# test of the update function
func test_update() -> void:
	# Initialization
	song_animation_player._ready()
	# plays a song with animation "ChordsBass"
	song_animation_player.ANIMATION = "ChordsBass"
	song_animation_player.play()
	# updates the current song with animation "ArpeggioChords"
	var new_song := SongAnimationPlayer.new()
	new_song.ANIMATION = "ArpeggioChords"
	new_song._ready()
	var effect_array = song_animation_player.update(new_song)
	asserts.is_equal(
		effect_array,
		[
			{
				"object": song_animation_player,
				"interpolate_value": "%s:%s:%s" % ["_tracks", "Arpeggio", "volume"],
				"interpolate_type": "property",
				"type": "volume",
				"fade_in": true
			},
			{
				"object": song_animation_player,
				"interpolate_value": "update_volumes",
				"interpolate_type": "method",
				"type": "volume",
				"fade_in": true
			},
			{
				"object":
				AudioServer.get_bus_effect(
					AudioServer.get_bus_index(song_animation_player._tracks["Arpeggio"].bus),
					song_animation_player.bus_effects.filter
				),
				"interpolate_value": "cutoff_hz",
				"interpolate_type": "property",
				"type": "filter",
				"fade_in": true
			},
			{
				"object": song_animation_player,
				"interpolate_value": "%s:%s:%s" % ["_tracks", "Bass", "volume"],
				"interpolate_type": "property",
				"type": "volume",
				"fade_in": false
			},
			{
				"object": song_animation_player,
				"interpolate_value": "update_volumes",
				"interpolate_type": "method",
				"type": "volume",
				"fade_in": false
			},
			{
				"object":
				AudioServer.get_bus_effect(
					AudioServer.get_bus_index(song_animation_player._tracks["Bass"].bus),
					song_animation_player.bus_effects.filter
				),
				"interpolate_value": "cutoff_hz",
				"interpolate_type": "property",
				"type": "filter",
				"fade_in": false
			}
		],
		"effects sets correctly"
	)
	asserts.is_equal(
		song_animation_player.get_node(song_animation_player.ANIMATION_PLAYER).current_animation,
		"ArpeggioChords",
		"Animation ArpeggioChords is currently playing"
	)
	asserts.is_true(song_animation_player.get_node("Arpeggio").playing, "%s is playing" % "Arpeggio")
	asserts.is_false(song_animation_player.get_node("Bass").playing, "%s is not playing" % "Bass")
	describe("Test of the update function")

# test of the stop function
func test_stop_song() -> void:
	# Initialization
	song_animation_player._ready()
	# plays a song with animation "ChordsBass"
	song_animation_player.ANIMATION = "All"
	song_animation_player.play()
	var effect_array = song_animation_player.stop()
	asserts.is_equal(
		effect_array,
		[
			{
				"object": song_animation_player,
				"interpolate_value": "%s:%s:%s" % ["_tracks", song_animation_player.name, "volume"],
				"interpolate_type": "property",
				"type": "volume",
				"fade_in": false
			},
			{
				"object": song_animation_player,
				"interpolate_value": "update_volumes",
				"interpolate_type": "method",
				"type": "volume",
				"fade_in": false
			},
			{
				"object":
				AudioServer.get_bus_effect(
					AudioServer.get_bus_index(
						song_animation_player._tracks[song_animation_player.name].bus
					),
					song_animation_player.bus_effects.filter
				),
				"interpolate_value": "cutoff_hz",
				"interpolate_type": "property",
				"type": "filter",
				"fade_in": false
			}
		],
		"effects sets correctly"
	)
	asserts.is_equal(song_animation_player._stop_queue[0], [song_animation_player.name], "Stop array set correctly")
	describe("Test of the stop function")
