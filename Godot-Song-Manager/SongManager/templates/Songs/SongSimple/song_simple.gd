extends Song
class_name SongSimple
# Simple song implementation (just with play/stop values)
# Really may not be ideal, but it's just to show that you can use different song types

"""
---- NOTES ----
- Evil ugly way to modify the volume of tracks/songs. By first interpolating the tracks you want, then calling a function that updates ALL tracks
	- Because Tween.interpolate_method only takes ONE parameter that can't be an array. Probably a better way will be available with Godot 4.0
- Remember that if you want a track to loop, set a loop value correctly
"""

##### SIGNALS #####
# Node signals

##### ENUMS #####
enum bus_effects { filter }  # effect indexes in a bus

##### VARIABLES #####
#---- CONSTANTS -----

#---- EXPORTS -----
export (String) var SONG_SEND_TO = "Master"  # where the song bus should send

#---- STANDARD -----
#==== PUBLIC ====

#==== PRIVATE ====
var _tracks: Dictionary = {}  # track infos
var _stop_queue := []

#==== ONREADY ====

##### PUBLIC METHODS #####
# initializes the song
func init():
	_init_tracks()
	_init_buses()

# plays the song, returns an array to give to the EffectManager as a parameter
func play() -> Array:
	for track in _tracks.keys():
		if track != name and _tracks[track].play:
			get_node(_tracks[track].path).play()
	return _get_track_effect_array(name, true)	

# stops the song, returns an array to give to  the EffectManager as a parameter
func stop() -> Array:
	if not get_parent().is_connected("effect_done",self,"_handle_queue_stop"):
		var _err = get_parent().connect("effect_done", self, "_handle_queue_stop")
	_stop_queue.push_back([name]) # name just means to stop all tracks, setups the stop of the song
	return _get_track_effect_array(name, false)

# updates the song to match the one specified in parameters, returns an array to give to  the EffectManager as a parameter
func update(song: Song) -> Array:
	var effect_array = []
	# sets play on all the tracks
	if song._tracks[name].play_all: 
		for track in song._tracks.keys():
			song._tracks[name].play = true
	var max_play_time := _get_tracks_max_play_time()
	var stop_array := []
	for track in _tracks.keys():
		if track != name:
			if song._tracks[track].play and not _tracks[track].play: # plays the track
				effect_array.append_array(_get_track_effect_array(track, true))
				get_node(_tracks[track].path).play(fmod(max_play_time, get_node(_tracks[track].path).stream.get_length()))
				_tracks[track].play = true
			elif not song._tracks[track].play and _tracks[track].play: # stops the track
				effect_array.append_array(_get_track_effect_array(track, false))
				stop_array.append(track)
				_remove_track_from_stop_queue(track)
				_tracks[track].play = false
	if not get_parent().is_connected("effect_done",self,"_handle_queue_stop"):
		var _err = get_parent().connect("effect_done", self, "_handle_queue_stop")
	_stop_queue.push_back(stop_array)
	_check_play_all_value()
	return effect_array


# links to the effects that can be triggered in "neutral" position (for example, same song, but lower the volume slowly on pause), depending on whatever is specified in parameters, returns an array to give to the EffectManager as a parameter
# parameters a dictionary of tracks you want to apply an effect (might also include root song, by just leaving the name of the song), with fade in/out
# dictionary should look like this : {track1 : {fade_in : bool}, track2 : {fade_in : bool}}
func get_neutral_effect_data(params : Dictionary) -> Array:
	var effect_array = []
	for param in params.keys():
		if _tracks.has(param):
			effect_array.append_array(_get_track_effect_array(param,params[param].fade_in))
	return effect_array


# updates the volume of all the buses, according to their values in _tracks
# percents is the tween completion percentage, both to make the tween recognize this, and for debug purposes
func update_volumes(_percents : float):
	for track in _tracks.keys():
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(_tracks[track].bus), _tracks[track].volume)

##### PROTECTED METHODS #####
# inits the tracks infos
func _init_tracks():
	for child in get_children():
		if child is AudioStreamPlayer:
			if not _tracks.has(child.name):
				_tracks[child.name] = {"bus": "", "path": get_path_to(child), "volume": 0.0, "play" : false}
	# special case of the song itself
	if not _tracks.has(name):
		_tracks[name] = {"bus": "", "volume": 0.0, "play_all": false}


# initialises the buses for the song
func _init_buses():
	# Inits the root bus
	_create_bus(name, SONG_SEND_TO)
	_tracks[name].bus = name
	# inits the track buses
	for track_name in _tracks.keys():
		if track_name != name:  # not root of the song
			_create_bus("%s:%s" % [name, track_name], name)
			_tracks[track_name].bus = "%s:%s" % [name, track_name]
			get_node(_tracks[track_name].path).bus = "%s:%s" % [name, track_name]


# Creates a bus with a specific name 
# WARNING : If the bus already exists
func _create_bus(name: String, send_to: String):
	# removes the bus if it already exists
	if AudioServer.get_bus_index(name) != -1:
		AudioServer.remove_bus(AudioServer.get_bus_index(name))
	# initializes the bus
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, name)
	AudioServer.set_bus_send(AudioServer.get_bus_index(name), send_to)
	# initializes the filter 
	var filter = AudioEffectFilter.new()
	filter.cutoff_hz = 20000
	AudioServer.add_bus_effect(AudioServer.get_bus_index(name), filter, bus_effects.filter)

# returns an array of effects that can be applied to a track
func _get_track_effect_array(track_name : String, fade_in : bool):
	return [
		# Volume
		{
			"object":self,
			"interpolate_value":"%s:%s:%s" % ["_tracks",track_name,"volume"],
			"interpolate_type":"property",
			"type":"volume",
			"fade_in":fade_in
		},
		{
			"object":self,
			"interpolate_value":"update_volumes",
			"interpolate_type":"method",
			"type":"volume",
			"fade_in":fade_in
		},
		# Filter
		{
			"object":AudioServer.get_bus_effect(AudioServer.get_bus_index(_tracks[track_name].bus),bus_effects.filter),
			"interpolate_value":"cutoff_hz",
			"interpolate_type":"property",
			"type":"filter",
			"fade_in":fade_in
		}
	]

# returns the max play time from a track (that is playing)
func _get_tracks_max_play_time() -> float:
	var max_play_time := 0.0
	for child in get_children():
		if child.playing:
			if child.get_playback_position() > max_play_time:
				max_play_time = child.get_playback_position()
	return max_play_time


# removes a track from the stop queue 
# Note : even if an element is empty, it should stay in the queue.
func _remove_track_from_stop_queue(track : String):
	for stop_idx in range(_stop_queue.size()):
		if _stop_queue[stop_idx].has(name): # cancels the stop of the entire song
			for track in _tracks.keys():
				if track == name: # just save a line execution (i know, that's useless)
					_stop_queue[stop_idx].erase(name)
				else:
					_stop_queue[stop_idx].append(track)
			_stop_queue[stop_idx].erase(name)
		elif _stop_queue[stop_idx].has(track):
			_stop_queue[stop_idx].erase(track)

# sets the play_all value on the general song
func _check_play_all_value():
	for track in _tracks.keys():
		if track != name and not _tracks[track].play:
			_tracks[name].play_all = false
			return
	_tracks[name].play_all = true

##### SIGNAL MANAGEMENT #####
# handles the stop queue
func _handle_queue_stop():
	if _stop_queue.size() > 0:
		var to_stop : Array = _stop_queue.pop_front()
		if to_stop.has(name): # stop all the tracks
			for track in _tracks.keys():
				if track != name:
					get_node(_tracks[track].path).stop()
		else :
			for track in to_stop:
				get_node(_tracks[track].path).stop()


##### DEBUG #####
# prints the current
func _print_buses():
	for bus_idx in AudioServer.bus_count:
		var bus_effects = []
		for effect_idx in AudioServer.get_bus_effect_count(bus_idx):
			bus_effects.append(AudioServer.get_bus_effect(bus_idx, effect_idx))
		print(
			(
				"bus N°%d : %s, has effects : %s and sends to %s"
				% [
					bus_idx,
					AudioServer.get_bus_name(bus_idx),
					bus_effects,
					AudioServer.get_bus_send(bus_idx)
				]
			)
		)


# prints the track infos
func _print_track_infos():
	print(_tracks)
