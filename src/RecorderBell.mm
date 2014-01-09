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
	
    vector<MultiSampledSoundPlayer *> instrumentSoundPlayers;
	int *currentChannel;
	bool playing;
	int noteCounter;
	int myChannels[3];
	float startTime;
	RecorderBellMaker *maker;
	
	RecorderBell(int _canvasX, int _canvasY, vector<Note*> _notes, ofImage *recBellImage, RecorderBellMaker *_maker) { // PGMidi	*_midi
		canvasX = _canvasX;
		canvasY = _canvasY;
		
		notes = _notes;
		
		currentRadius = RECBELLRADIUS;
		targetRadius = RECBELLRADIUS;
		
		img = recBellImage;
		img->setAnchorPercent(0.5, 0.5);
		
		maker = _maker;
		
		playing = false;
        isSelected = false;
		noteCounter = 0;
		startTime = 0;
		dragging = false;
		down = false;
		dragID = -1;
		downID = -1;
		
		touchMovedFlag = false;
    };
    
    void setPlayers(vector<MultiSampledSoundPlayer *> _p) {
        instrumentSoundPlayers = _p;
    }
	
	void draw(float screenPosX, float screenPosY, float _zoom, float force, float _bend, bool showNoteNames) {
		touchMovedFlag = true;

		zoom = _zoom;
		
		screenX = (canvasX - screenPosX) * zoom;
		screenY = (canvasY - screenPosY) * zoom;
        
        // play the sequence
        // this must come before we check if we are offscreen, so we keep playing while offscreen
		if (playing) {
			playNextNote();
		}

        // no need to draw image if we are off screen
        if (!isOnScreen()) {
			return;
		}

        ofColor gray;
        gray.setHsb(0,0,255);
        if(!playing) {
            gray.setBrightness(150);
        }
        int alpha = 255;
        if (dragging) {
            alpha = 200;
        }
        if (isSelected) {
            float brightness = ofMap(sin(ofGetElapsedTimef()*18),-1,1,0.5,1);
            gray.setBrightness(brightness * 255);
        }
        
        ofSetColor(gray, alpha);

		if (currentRadius != targetRadius) {
			currentRadius += (targetRadius - currentRadius) / 10;
		}

		img->draw(screenX, screenY, currentRadius * 2 * zoom, currentRadius * 2 * zoom);
		
		drawNotation();
		
		
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
        ofSetCircleResolution(4);
		for (int i=0; i<n; i++) {
			float x = screenX + xOffset + ((notes[i]->time / notesDuration) * notationWidth);
			float y = screenY + yOffset - (((notes[i]->note + 1) + (12 * (notes[i]->octave))) * noteHeight);
			float hue = notes[i]->note / 13.0;
			int rgb[3];
			setColorHSV(hue, 1, 0.75, rgb);
			float r = 3 * zoom;
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
            
            int inst = n->instrument;
//            int playerNum = instrumentSoundPlayers[inst]->playNote(n->note, n->octave);
//            instrumentSoundPlayers[inst]->setVolume(playerNum, n->velocity);
            
            instrumentSoundPlayers[inst]->playNote(n->note, n->octave);
            
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