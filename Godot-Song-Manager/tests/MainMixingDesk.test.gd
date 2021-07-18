extends WAT.Test

# Doc : https://wat.readthedocs.io/en/latest/index.html

##### VARIABLES #####
var song1_path = "res://tests/Songs/Song1/Song1.tscn"
var song2_path = "res://tests/Songs/Song2/Song2.tscn"

##### PROCESSING #####
func title() -> String:
	return "Test of the Main mixing desk"

##### UTILS #####
# reset a song to default values
func resetSong(song : Song) -> void:
	for track in song.get_node(song.MAIN_TRACKS).TRACKS:
		track.play = false

##### TEST FUNCTIONS #####
# Pretty much tests everything in MainMixingDesk at once
func test_all_function() -> void:
	var song1 : Song = load(song1_path).instance()
	var song2 : Song = load(song2_path).instance()
	var mixing_desk = MainMixingDesk.new()
	add_child(mixing_desk)
	song1.setPlay("Arpeggio",true)
	song1.setPlay("Chords",true)
	mixing_desk.play(song1)
	asserts.is_false(song1.isStoppedAll(), "Song 1 playing at least a track")
	asserts.is_true(song1.isPlaying("Chords"), "Chords are playing")
	asserts.is_true(song1.isPlaying("Arpeggio"), "Arpeggio are playing")
	asserts.is_false(song1.isPlaying("Bass"), "Bass are not playing")
	asserts.is_equal(mixing_desk.get_node(mixing_desk.current_song).NAME, song1.NAME, "Current song set to song 1")
	song2.setPlay("Chords",true)
	mixing_desk.play(song2)
	yield(until_signal(song2,"tree_exited",0.1),YIELD)
	asserts.is_equal(mixing_desk.getCurrent(),1,"One song in mixing desk (old one should be freed)")
	asserts.is_true(song2.isPlaying("Chords"),"Chords of song 2 playing")
	asserts.is_false(song2.isPlaying("Bass"),"Bass of song 2 not playing")
	asserts.is_equal(mixing_desk.getCurrent(), song2.NAME, "Current song set to song 2")
	mixing_desk.startTrack("Bass")
	asserts.is_true(song2.isPlaying("Chords"), "Chords of song 2 playing")
	asserts.is_true(song2.isPlaying("Bass"), "Bass of song 2 playing")
	mixing_desk.stopTrack("Chords")
	asserts.is_false(song2.isPlaying("Chords"), "Chords of song 2 not playing")
	asserts.is_true(song2.isPlaying("Bass"), "Bass of song 2 playing")
	mixing_desk.stopCurrent()
	asserts.is_false(song2.isPlaying("Chords"), "Chords of song 2 not playing")
	asserts.is_false(song2.isPlaying("Bass"), "Bass of song 2 not playing")
	mixing_desk.queue_free()
	resetSong(song1)
	resetSong(song2)
	describe("Test of the play function")


