tool
extends Node
class_name MainTracks


var playing = false
var ref_track = null

export(Array,Dictionary) var TRACKS setget set_tracks # info for each loop

func set_tracks(track):
	for i in track.size():
		if track[i].size() == 0:
			# default value for new items in the dialogs array
			track[i] = {
				"name": String(), # name of the track
				"play":false, # if the track should be playing or not
				"references":[ # reference tracks. track should start at the same playback position of the first reference that is not null and playing. Ordered.
					NodePath()
				] 
			}
		else:
			for j in track[i].references.size():
				if(track[i].references[j] == null):
					track[i].references[j] = NodePath()
	TRACKS = track

# starts streams specified in LOOPS
func start() -> void:
	for track in TRACKS:
		if track.play:
			startTrack(track.name)

# starts the specified track
func startTrack(track_name : String) -> void:
	var time = 0.0
	for track in TRACKS:
		if track.name == track_name:
			for reference in track.references: # check every reference of the track (to setup the start time)
				var node = get_node_or_null(reference) # gets the reference track if it exists
				if(node != null and node is AudioStreamPlayer and node.playing):
					time = node.get_playback_position()
					break
	get_node(track_name).play(time)
	setPlay(track_name,true)

# sets the bus on track
func setBusOnTrack(track_name : String, bus_name : String) -> void:
	get_node(track_name).bus = bus_name

# sets all the tracks on a special bus
func setBusAll(bus_name : String) -> void:
	for track in TRACKS:
		setBusOnTrack(track.name,bus_name)

# stops all the tracks
func stopAll() -> void:
	for track in TRACKS:
		stopTrack(track.name)

# stops the specified track
func stopTrack(track_name : String) -> void:
	setPlay(track_name,false)
	get_node(track_name).stop()

# sets the play value in a track
func setPlay(track_name : String, value : bool) -> void:
	for track in TRACKS:
		if(track.name == track_name):
			track.play = value

# returns the bus of the specified track as a string (or null if does not exist)
func getBus(track_name : String):
	for track in TRACKS:
		if(track.name == track_name):
			return track.busName
	return null

# true if the specified track is playing
func isPlaying(track_name : String) -> bool:
	for track in TRACKS:
		if(track.name == track_name):
			return track.play
	return false

# true if no track is playing
func isStopped() -> bool:
	for track in TRACKS:
		if(track.play):
			return false
	return true
