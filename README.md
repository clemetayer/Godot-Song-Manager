# Godot-Song-Manager
A somewhat flexible song manager for Godot. 

Inspired on some parts from Godot Mixing Desk by kyzfrintin : https://github.com/kyzfrintin/Godot-Mixing-Desk (Does not provides the same features though).

This manager allows songs and transitions to be in separated, flexible scenes. 

# Disclaimer
This tool was intended for a personnal use, but maybe this might be useful for someone else. 

As a consequence, I will mostly maintain it for myself, however, I tried to make it as comprehensible as possible and fairly customizable.

# Unit testing
Unit tests were made using WAT 5.0.1 Plugin : https://github.com/AlexDarigan/WAT

# Example
Since the logic behind this tool can be hard to understand, an example is provided to show how this tool can be used. This is probably way better to figure out how it works than the following explanation.

The tracks were made with LMMS. Since this is just for an example, the tracks are not very elaborate, please be kind if you think the music sucks :(

# Usage
To install the song manager, copy the "SongManager" folder somewhere in your project.

Then, you can instance the song manager as a child scene in any scene of your project. 

You can create a "Song" node, and a "Transition" node to setup a specific song and transition that can dynamically be added in the song manager (details on these below).

# Nodes setup
## Song manager
This node handles the tracks of a song and transitions between songs. 

There are some important functions and variables here: 
- addSongToQueue(song, transition) : which adds the song "song" in the queue, to transition in with transition "transition". the queue is handled at each frame by the song manager.
- createTransitionBus(name, send_to) : which creates a bus with name "name", that sends to "send_to" bus. This is a customizable function that is useful to add effects on it, for the transitions. By default, an amplifier (for volume transitions) and a filter (for filter transitions) are added on the bus. this is paired with the "effects" enum, which is used to find an effect index in the bus with it's name.
- enum effects : enumeration to easily find effect indexes for buses.

## Song 
This node handles the tracks playing.
To create a new song node, you should create a new scene (type : Node), add a script to the root that extends "SongTemplate", then add a "MainTracks" child (type : Node), with a script that extends MainTracksTemplate and has the keyword "tool". 
The "MainTracks" node should contain tracks as AudioStreamPlayer.

In the root, you have to set in the inspector : 
- The tempo (or BPM) of the song
- The number of beats per bar (usually 2,3 or 4)
- The path of the "MainTracks" node
- The name of the song

In the MainTracks song, you have to set in the inspector, for each track :
- the name of the track
- the play value (true => should play). This is particularly useful to do in scripts.
- the "reference" tracks, in order, to synchronize the time with, on play.

It sends a "beat" and "bar" signal at each beat/bar.

Note : Unlike the Godot Mixing Desk, this tool does not use its own loop system. Therefore, if you want a track to loop, you should import it as a loop, and set the loop in AudioStreamPlayers in MainTracks.

If you want to use your own loop method for the song, you can still do it, since the song is customizable.

## Transition
This node should compute the transition time and initialize the transition tween that should modify the effect in the bus of the track(s).

To create a transition, create a new scene with root of type "Node", with a script that extends "TransitionTemplate".

In the root, you have to set in the inspector : 
- The time unit for transition (seconds, beats or bars)
- Wait next beat/bar value : if it should wait the next beat or bar before starting the transition
- Fade in/out time : the fade in/out time of the transition.

By default, this is an instant transition

# Node details
## Song manager
This node has a song queue, which contains the songs that should be played after, with a specific transition. 
This queue is handled at each frame, which can result in 3 scenarios :
- No song is playing : The song should start to play immediately with transition.
- A song is already playing, and the one in the queue is different : The song should be switched (current song should be removed with transition, then the next song should be played with transition)
- A song is already playing, and it is the same one in the queue : the different tracks in the song should be updated with transition.

Each track of the song has it's own dedicated bus, that can be found in "bus_array".

## Song
The root is mostly an interface for different tracks play "types" (here, it's for the main tracks, but who knows, maybe there will be other play types in the future, idk).

The MainTracks handles how the children AudioStreamPlayer should play, especially, if you want it to loop, to play once, add some conditions, etc. 

## Transition
Not much to say here. However, it's still important to notice that the transition should not start the tween (the song manager does), but only initialize the properties in it.

## Note : 
Since songs and transitions are only extending scripts, you can customize these fairly easily.