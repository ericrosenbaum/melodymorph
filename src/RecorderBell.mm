/*
 *  RecorderBell.cpp
 *  iPhoneAdvancedEventsExample
 *
 *  Created by England on 12/8/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "Bell.mm"
#include "RecorderBellMaker.h"

class RecorderBell : public Bell {

	public:
	
	ofxOpenALSoundPlayer *allVoices[3];
	int *currentChannel;
	bool playing;
	int noteCounter;
	int myChannels[3];
	float startTime;
	RecorderBellMaker *maker;
	
	RecorderBell(int _canvasX, int _canvasY, vector<Note*> _notes, ofImage recBellImage, RecorderBellMaker *_maker) { // PGMidi	*_midi
		canvasX = _canvasX;
		canvasY = _canvasY;
		
		notes = _notes;
		
//		allVoices[0] = _voices[0];
//		allVoices[1] = _voices[1];
//		allVoices[2] = _voices[2];
//		
//		currentChannel = _currentChannel;

		currentRadius = RECBELLRADIUS;
		targetRadius = RECBELLRADIUS;
		
		img = recBellImage;
		img.setAnchorPercent(0.5, 0.5);
		
		maker = _maker;
		
		playing = false;
		noteCounter = 0;
		startTime = 0;
		dragging = false;
		down = false;
		dragID = -1;
		downID = -1;
		
		touchMovedFlag = false;
        
        //midi = _midi;
	};
	
	void draw(float screenPosX, float screenPosY, float _zoom, float force, float _bend, bool showNoteNames) {
		touchMovedFlag = true;

		zoom = _zoom;
		
		screenX = (canvasX - screenPosX) * zoom;
		screenY = (canvasY - screenPosY) * zoom;
				
		int rgb[3];
		setColorHSV(0, 0, 1, rgb);
		if (dragging) {
			ofSetColor(rgb[0], rgb[1], rgb[2], 200);
		}
		
		if (currentRadius != targetRadius) {
			currentRadius += (targetRadius - currentRadius) / 10;
		}

		img.draw(screenX, screenY, currentRadius * 2 * zoom, currentRadius * 2 * zoom);
		
		drawNotation();
		
		// play the sequence
		if (playing) {
			playNextNote();
		}		
		
	}
	
	void drawNotation() {
		float notesDuration = notes[notes.size() - 1]->time;
		if (notesDuration < 0.5) {
			notesDuration = 1;
		}
		float notationHeight = (currentRadius * 2 * zoom) / 3.0f;
		float notationWidth = (currentRadius * 2 * zoom) - (2 * (currentRadius * zoom / 4.0f));
		float noteHeight = notationHeight / 36.0f;
		float xOffset = (currentRadius * zoom * -1) +  (currentRadius * zoom / 4.0f);
		float yOffset = notationHeight / 2.0f;
		int n = notes.size();
		if (playing) {
			n = noteCounter;
		}
		for (int i=0; i<n; i++) {
			float x = screenX + xOffset + ((notes[i]->time / notesDuration) * notationWidth);
			float y = screenY + yOffset - (((notes[i]->note + 1) + (12 * (notes[i]->octave))) * noteHeight);
			float hue = notes[i]->note / 13.0;
			int rgb[3];
			setColorHSV(hue, 1, 1, rgb);
			float r = 2 * zoom;
			ofCircle(x, y, r);
		}		
	}
	
	void playNote() {
		// this actually triggers the playing of our whole sequence
		playing = !playing;
		if (playing) {
			noteCounter = 0;
			startTime = ofGetElapsedTimef();
		}
	}
	void playNextNote() {
		Note *n = notes[noteCounter];
		float t = ofGetElapsedTimef() - startTime;
		if (t > n->time) {
			noteCounter++;
			if (noteCounter == notes.size()) {
				playing = false;
			}
            
            // openAL
//			int inst = n->instrument;
//			currentChannel[inst] += 1;
//			currentChannel[inst] %= NUMVOICES;
//			int myChannel = currentChannel[inst];
//			allVoices[inst][myChannel].setPitch(getRatio(n->note, n->octave));
//			allVoices[inst][myChannel].setVolume(n->velocity);
//			allVoices[inst][myChannel].play();
			
            // MIDI
//            int noteNum = n->note + ((n->octave + 3) * 12);
//            midiNoteOn(noteNum, n->instrument, n->velocity);
            
			currentRadius = RECBELLRADIUS + 25;
			
			[maker recordRecordedNote:n];
		}		
	}
	bool isRecorderBell() {
		return true;
	}
	vector<Note *> getNotes() {
		return notes;
	}
};