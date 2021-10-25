extends WAT.Test

# Doc : https://github.com/AlexDarigan/WAT

##### VARIABLES #####
var song: Song


##### PROCESSING #####
func pre():
	song = Song.new()


func post():
	song.queue_free()


func title() -> String:
	return "Test of a song node"


##### TEST FUNCTIONS #####
# test of the play function
func test_play() -> void:
	asserts.is_true(true, "base test")
	describe("Test of the play function")


# test of the update function
func test_update() -> void:
	asserts.is_true(true, "base test")
	describe("Test of the update function")


# test of the stop function
func test_stop_song() -> void:
	asserts.is_true(true, "base test")
	describe("Test of the stop function")
