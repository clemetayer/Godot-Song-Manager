extends WAT.Test

# Doc : https://github.com/AlexDarigan/WAT

##### VARIABLES #####
var song_manager: SongManager


##### PROCESSING #####
func pre():
	song_manager = SongManager.new()
	add_child(song_manager)


func post():
	song_manager.queue_free()


func title() -> String:
	return "Test of the song manager"


##### TEST FUNCTIONS #####
# test of the add_to_queue method
func test_add_to_queue() -> void:
	asserts.is_true(true, "Useless standard test")
	describe("Test add_to_queue")


# test of the stop_current method
func test_stop_current_method() -> void:
	asserts.is_true(true, "Useless standard test")
	describe("Test stop_current")


# test of the apply_effect method
func test_apply_effect_method() -> void:
	asserts.is_true(true, "Useless standard test")
	describe("Test apply_effect")


# test of the get_current method
func test_get_current_method() -> void:
	asserts.is_true(true, "Useless standard test")
	describe("Test get_current")
