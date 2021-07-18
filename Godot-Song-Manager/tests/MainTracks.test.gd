extends WAT.Test

# Doc : https://wat.readthedocs.io/en/latest/index.html

##### VARIABLES #####
var main_tracks : MainTracks
var audio1 : AudioStreamPlayer
var audio2 : AudioStreamPlayer
var audio3 : AudioStreamPlayer

##### PROCESSING #####
func pre():
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
	main_tracks.add_child(audio1)
	main_tracks.add_child(audio2)
	main_tracks.add_child(audio3)
	add_child(main_tracks)
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

func post():
	main_tracks.queue_free()

func title() -> String:
	return "Test of the MainTracks node"

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
# Test of the start function
func test_start_function() -> void:
	main_tracks.TRACKS[0].play = true
	main_tracks.TRACKS[1].play = true
	main_tracks.start()
	asserts.is_true(audio1.playing, "Audio1 is playing")
	asserts.is_true(audio2.playing, "Audio2 is playing")
	asserts.is_false(audio3.playing, "Audio3 is not playing")
	resetMainTracks()
	describe("Test of the start function")

# Test of the start function
func test_startTrack_function() -> void:
	main_tracks.TRACKS[0].play = true
	main_tracks.start()
	yield(until_timeout(0.25),YIELD)
	asserts.is_false(audio2.playing, "Audio2 is not playing yet")
	main_tracks.startTrack("audio2")
	asserts.is_true(audio2.playing, "Audio2 is playing")
	asserts.is_equal_or_greater_than(audio2.get_playback_position(), 0.20, "Audio2 position >= 0.20")
	asserts.is_equal_or_less_than(audio2.get_playback_position(),0.30, "Audio2 position <= 0.30")
	resetMainTracks()
	describe("Test of the start function")

# test of the setBusOnTrack function
func test_setBusOnTrack_function() -> void:
	createTransitionBus("test")
	main_tracks.setBusOnTrack("audio1","test")
	asserts.is_equal(audio1.bus,"test","Audio bus set correctly")
	resetMainTracks()
	removeBus("test")
	describe("Test of the setBusOnTrack function")

# test of the setBusAll function
func test_setBusAll_function() -> void:
	createTransitionBus("test")
	main_tracks.setBusAll("test")
	asserts.is_equal(audio1.bus,"test","Audio1 bus set correctly")
	asserts.is_equal(audio2.bus,"test","Audio2 bus set correctly")
	asserts.is_equal(audio3.bus,"test","Audio3 bus set correctly")
	resetMainTracks()
	removeBus("test")
	describe("Test of the setBusAll function")

# test of the stopAll function
func test_stopAll_function() -> void:
	main_tracks.TRACKS[0].play = true
	main_tracks.TRACKS[1].play = true
	main_tracks.TRACKS[2].play = true
	main_tracks.start()
	asserts.is_true(audio1.playing, "Audio1 playing")
	asserts.is_true(audio2.playing, "Audio2 playing")
	asserts.is_true(audio3.playing, "Audio3 playing")
	main_tracks.stopAll()
	asserts.is_false(audio1.playing, "Audio1 stopped")
	asserts.is_false(audio2.playing, "Audio2 stopped")
	asserts.is_false(audio3.playing, "Audio3 stopped")
	resetMainTracks()
	describe("Test of the stopAll function")

# test of the stopTrackFunction
func test_stopTrack_function() -> void:
	main_tracks.TRACKS[0].play = true
	main_tracks.start()
	asserts.is_true(audio1.playing, "Audio1 playing")
	main_tracks.stopTrack("audio1")
	asserts.is_false(audio1.playing, "Audio1 stopped")
	asserts.is_false(main_tracks.TRACKS[0].play, "Variable set to play")
	resetMainTracks()
	describe("Test of the stopTrack function")

# test of the isStopped function
# Only checks the "play" value, not if the stream is playing or not
func test_isStopped_isPlaying_function() -> void:
	asserts.is_true(main_tracks.isStopped(),"Stopped")
	asserts.is_false(main_tracks.isPlaying("audio2"),"Audio2 stopped")
	main_tracks.TRACKS[1].play = true
	asserts.is_false(main_tracks.isStopped(),"Playing")
	asserts.is_true(main_tracks.isPlaying("audio2"),"Audio2 playing")
	resetMainTracks()
	describe("Test of the isStopped function")

# getBus and isPlaying not really worth testing
