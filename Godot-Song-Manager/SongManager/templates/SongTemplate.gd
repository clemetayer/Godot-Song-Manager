extends Node
class_name SongTemplate

export(int) var BPM
export(int) var BEATS_PER_BAR # or time signature (4,3,2 are the most common)
export(NodePath) var MAIN_TRACKS # path to the main song to play
export(String) var NAME # name of the song

signal beat(number)
signal bar()

var timer : Timer
var beat_num : int

# sets the beat timer
func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 60.0/BPM
	var _err = timer.connect("timeout",self,"beatProcess")
	beat_num = 1

# plays the song with parameters in MAIN_LOOPS
func play() -> void:
	get_node(MAIN_TRACKS).start()
	timer.start()

# stops the song (entirely)
func stop() -> void:
	get_node(MAIN_TRACKS).stopAll()
	timer.stop()

# sets the "play" value on track
func setPlay(track : String, value : bool) -> void:
	get_node(MAIN_TRACKS).setPlay(track,value)

# starts the specified track on the specified bus
func startTrackOnBus(track:String,bus:String) -> void:
	get_node(MAIN_TRACKS).startTrackOnBus(track,bus)

# sets the specified track on the specified bus
func setBusOnTrack(track:String,bus:String) -> void:
	get_node(MAIN_TRACKS).setBusOnTrack(track,bus)

# stops the specified track
func stopTrack(track:String) -> void:
	get_node(MAIN_TRACKS).stopTrack(track)
	if(get_node(MAIN_TRACKS).isStopped()):
		timer.stop()
		beat_num = 1

# starts the specified track
func startTrack(track:String) -> void:
	get_node(MAIN_TRACKS).startTrack(track)

# compares the play values of self, compared to a similar Default Song. Returns an array of tracks that have different play values (as strings)
func compareSongsPlayValues(song : SongTemplate) -> Array:
	var diff_array = []
	for index in range(get_node(MAIN_TRACKS).TRACKS.size()):
		if(get_node(MAIN_TRACKS).TRACKS[index].play != song.get_node(song.MAIN_TRACKS).TRACKS[index].play):
			diff_array.append(get_node(MAIN_TRACKS).TRACKS[index].name)
	return diff_array

func getTrackList() -> Array:
	return get_node(MAIN_TRACKS).get_children()

# true if the specified track is playing
func isPlaying(track:String) -> bool:
	return get_node(MAIN_TRACKS).isPlaying(track)

# true if all tracks are stopped
func isStoppedAll() -> bool:
	return get_node(MAIN_TRACKS).isStopped()

# triggered on each beat
func beatProcess():
	if(beat_num == BEATS_PER_BAR):
		beat_num = 1
		barProcess()
	else:
		beat_num += 1
	emit_signal("beat",beat_num)

# triggered on each bar
func barProcess():
	emit_signal("bar")
