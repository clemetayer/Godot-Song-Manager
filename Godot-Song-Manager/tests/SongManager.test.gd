extends WAT.Test

# Doc : https://wat.readthedocs.io/en/latest/index.html

##### VARIABLES #####
var song_manager_path = "res://tests/SongManager.tscn"
var song1_path = "res://tests/Songs/Song1/Song1.tscn"
var song2_path = "res://tests/Songs/Song2/Song2.tscn"

##### PROCESSING #####
#func pre():
#    pass

#func post():
#    pass

func title() -> String:
	return "Test of the (general) SongManager"

##### UTILS #####
# Removes a bus
func removeBus(name : String) -> void:
	AudioServer.remove_bus(AudioServer.get_bus_index(name))

##### TEST FUNCTIONS #####
# Test of the createTransitionBus function
func test_createTransitionBus_function() -> void:
	var song_manager = load(song_manager_path).instance()
	add_child(song_manager)
	song_manager.createTransitionBus("test","Master")
	asserts.is_not_equal(AudioServer.get_bus_index("test"),-1,"Bus test created")
	song_manager.createTransitionBus("test2","test")
	asserts.is_not_equal(AudioServer.get_bus_index("test2"),-1,"Bus test2 created")
	asserts.is_equal(AudioServer.get_bus_send(AudioServer.get_bus_index("test2")),"test","test2 sending to test")
	asserts.is_class_instance(AudioServer.get_bus_effect(AudioServer.get_bus_index("test2"), song_manager.effects.amplifier), AudioEffectAmplify, "Effect " + str(song_manager.effects.amplifier) + " is amplifier")
	asserts.is_class_instance(AudioServer.get_bus_effect(AudioServer.get_bus_index("test2"), song_manager.effects.filter), AudioEffectFilter, "Effect " + str(song_manager.effects.filter) + " is filter")
	removeBus("test")
	removeBus("test2")
	song_manager.queue_free()
	describe("Test description")

# Test of a song addition with an instant transition and no song playing
func test_addSong() -> void:
	var song_manager = load(song_manager_path).instance()
	var song : Song = load(song1_path).instance()
	song.setPlay("Arpeggio",true)
	var transition : Transition = Transition.new()
	add_child(song_manager)
	song_manager.addSongToQueue(song,transition)
	asserts.is_false(song.isStoppedAll(), "Song is playing")
	describe("Test of a simple song add (simple case)")

# Test of a song update (and remove) in a simple case
# Note : even though a new instance of song is set as a parameter, the old one is kept (since they have the same origin)
func test_updateSong() -> void:
	var song_manager = load(song_manager_path).instance()
	var song : Song = load(song1_path).instance()
	song.setPlay("Arpeggio",true)
	var transition : Transition = Transition.new()
	add_child(song_manager)
	song_manager.addSongToQueue(song,transition)
	yield(until_signal(song,"tree_entered",0.1),YIELD)
	asserts.is_true(song.isPlaying("Arpeggio"),"Arpeggio playing")
	asserts.is_false(song.isPlaying("Bass"),"Bass not playing")
	asserts.is_false(song.isStoppedAll(), "Song is generally playing")
	asserts.is_equal(song_manager.get_node("MainMixingDesk").get_child_count(),1,"Song was added as a MainMixingDeskChild")
	var song_bis : Song = load(song1_path).instance()
	song_bis.setPlay("Bass",true)
	song_manager.addSongToQueue(song_bis,transition)
	yield(until_timeout(0.1),YIELD) # wait processing
	asserts.is_true(song.isPlaying("Bass"),"Bass playing")
	asserts.is_false(song.isPlaying("Arpeggio"),"Arpeggio not playing")
	asserts.is_false(song.isStoppedAll(), "Song is generally playing")
	asserts.is_equal(song_manager.get_node(song_manager.MIXING_DESK).get_child_count(),1,"Song was not freed")
	var song_rm : Song = load(song1_path).instance()
	song_manager.addSongToQueue(song_rm,transition)
	yield(until_timeout(0.1),YIELD) # wait processing
	asserts.is_equal(song_manager.get_node(song_manager.MIXING_DESK).get_child_count(),0,"Song was freed (no track set to play)")
	song_manager.queue_free()
	describe("Test of a song update (simple case)")

# Test of a song switch in a simple case
func test_switchSong() -> void:
	var song_manager = load(song_manager_path).instance()
	var song : Song = load(song1_path).instance()
	song.setPlay("Arpeggio",true)
	var transition : Transition = Transition.new()
	add_child(song_manager)
	song_manager.addSongToQueue(song,transition)
	yield(until_signal(song,"tree_entered",0.1),YIELD)
	asserts.is_false(song.isStoppedAll(), "Song is generally playing")
	asserts.is_equal(song_manager.get_node("MainMixingDesk").get_child_count(),1,"Song was added as a MainMixingDeskChild")
	var song2 : Song = load(song2_path).instance()
	song2.setPlay("Chords",true)
	yield(until_signal(song2,"tree_entered",0.1),YIELD)
	asserts.is_true(song2.isPlaying("Chords"),"Chords playing")
	asserts.is_false(song2.isPlaying("Bass"),"Bass not playing")
	asserts.is_false(song2.isPlaying("Drums"),"Drums not playing")
	asserts.is_false(song2.isStoppedAll(), "Song2 (woohoo) is generally playing")
	asserts.is_equal(song_manager.get_node("MainMixingDesk").get_child_count(),1,"Song2 (woohoo) was added as a MainMixingDeskChild (and previous one was removed)")
	song_manager.queue_free()
	describe("Test of a song switch (simple case)")
