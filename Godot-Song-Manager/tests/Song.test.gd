extends WAT.Test

# Doc : https://wat.readthedocs.io/en/latest/index.html

##### VARIABLES #####
var song : Song
var main_tracks : MainTracks
var audio1 : AudioStreamPlayer
var audio2 : AudioStreamPlayer
var audio3 : AudioStreamPlayer

##### PROCESSING #####
func pre():
	song = Song.new()
	main_tracks = MainTracks.new()
	audio1 = AudioStreamPlayer.new()
	audio1.set_stream(load("res://tests/Resources/Song1/Arpeggio.wav"))
	audio1.name = "audio1"
	audio2 = AudioStreamPlayer.new()
	audio2.set_stream(load("res://tests/Resources/Song1/Bass.wav"))
	audio2.name = "audio2"
	audio3 = AudioStreamPlayer.new()
	audio3.set_stream(load("res://tests/Resources/Song1/Chords.wav"))
	audio3.name = "audio3"
	add_child(song)
	song.add_child(main_tracks)
	main_tracks.add_child(audio1)
	main_tracks.add_child(audio2)
	main_tracks.add_child(audio3)
	main_tracks.TRACKS = [
		{
			"name":"audio1",
			"play":false,
			"references":[]
		},
		{
			"name":"audio2",
			"play":false,
			"references":[main_tracks.get_path_to(audio1)]
		},
		{
			"name":"audio3",
			"play":false,
			"references":[main_tracks.get_path_to(audio2)]
		}
	]
	song.BPM = 120
	song.BEATS_PER_BAR = 4
	song.MAIN_TRACKS = song.get_path_to(main_tracks)
	song.NAME = "test"

func post():
	main_tracks.queue_free()

func title() -> String:
	return "Test of a song node"

##### UTILS #####
# resets the main tracks node
func resetMainTracks():
	audio1.stop()
	audio2.stop()
	audio3.stop()
	audio1.bus = "Master"
	audio2.bus = "Master"
	audio3.bus = "Master"
	main_tracks.TRACKS = [
		{
			"name":"audio1",
			"play":false,
			"references":[]
		},
		{
			"name":"audio2",
			"play":false,
			"references":[main_tracks.get_path_to(audio1)]
		},
		{
			"name":"audio3",
			"play":false,
			"references":[main_tracks.get_path_to(audio2)]
		}
	]

# creates a temporary bus to handle transitionning tracks
func createTransitionBus(name : String) -> String:
	var bus_index = AudioServer.bus_count # Note : bus indexes starts at 0
	AudioServer.add_bus(bus_index)
	AudioServer.set_bus_name(bus_index,name)
	AudioServer.set_bus_send(bus_index,"Master")
	return name

# removes the bus with name
func removeBus(name : String) -> void:
	AudioServer.remove_bus(AudioServer.get_bus_index(name))

##### TEST FUNCTIONS #####
# test of the setPlay function
func test_setPlay_function() -> void:
	asserts.is_false(main_tracks.TRACKS[0].play, "Audio 1 not set to play")
	song.setPlay("audio1",true)
	asserts.is_true(main_tracks.TRACKS[0].play, "Audio 1 set to play")
	resetMainTracks()
	describe("Test of the setPlay function")

# test of play and stop functions
func test_play_stop_functions() -> void:
	main_tracks.TRACKS[0].play = true
	main_tracks.TRACKS[1].play = true
	song.play()
	asserts.is_true(audio1.playing,"Audio1 is playing")
	asserts.is_true(audio2.playing,"Audio2 is playing")
	asserts.is_false(audio3.playing,"Audio3 is not playing")
	song.stop()
	asserts.is_false(audio1.playing,"Audio1 is stopped")
	asserts.is_false(audio2.playing,"Audio2 is stopped")
	asserts.is_false(audio3.playing,"Audio3 is not playing")
	resetMainTracks()
	describe("Test of the play and stop functions")

# startTrackOnBus not really worth testing

# test of the setBusOnTrack function
func test_setBusOnTrack_function() -> void:
	asserts.is_equal(audio1.bus, "Master", "Bus set to master")
	createTransitionBus("test")
	song.setBusOnTrack("audio1","test")
	asserts.is_equal(audio1.bus, "test", "Bus set to test")
	resetMainTracks()
	describe("Test of the setBusOnTrack function")

# test of the startTrack and stopTrack functions
func test_stop_start_track_functions() -> void:
	asserts.is_false(audio1.playing, "Audio1 not playing")
	song.startTrack("audio1")
	asserts.is_true(audio1.playing, "Audio1 playing")
	song.stopTrack("audio1")
	asserts.is_false(audio1.playing, "Audio1 not playing")
	resetMainTracks()
	describe("Test of the startTrack and stopTrack functions")

# test a standard beat/bar cycle (Note : starts at 1)
func test_beat_bar_process() -> void:
	watch(song,"beat")
	watch(song,"bar")
	var bar = 1
	var beat = 1
	for i in range(1,15):
		song.beatProcess()
		asserts.signal_was_emitted_with_arguments(song,"beat",[beat],"Signal beat was emitted with number " + str(beat))
		asserts.signal_was_emitted_x_times(song,"beat", i, "Signal was emitted " + str(i) + " times")
		asserts.is_equal(song.beat_num, beat, "Beat equals " + str(beat))
		if(beat >= song.BEATS_PER_BAR):
			beat = 1
			asserts.signal_was_emitted_x_times(song, "bar", bar, "Signal bar was emitted " + bar + "times")
			bar += 1
		else:
			beat += 1
	resetMainTracks()
