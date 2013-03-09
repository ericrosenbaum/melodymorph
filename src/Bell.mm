#ifndef _BELL_ER
#define _BELL_ER

/*
 *  Bell.cpp
 *  iPhoneAdvancedEventsExample
 *
 *  Created by England on 11/5/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "ofMain.h"
#include "ofxOpenALSoundPlayer.h"
#include "config.h"
#include "utils.h"
#include "Note.cpp"
//#import "PGMidi.h"
#include "MultiSampledSoundPlayer.h"

class Bell {
		
public:
	
	float canvasX, canvasY;
	int noteNum;
	float velocity;
	
	float screenX, screenY;
	float ratio;
	ofImage img;
	ofxOpenALSoundPlayer *voices;
	bool dragging;
	int dragID;
	float targetRadius;
	float currentRadius;
	float hue;
	int *currentChannel;
	int myChannel;
	float dragOffsetX[MAXTOUCHES];
	float dragOffsetY[MAXTOUCHES];
	int noteFunctions[NUMNOTES];
	int octave;
	int instrument;
	float zoom;
	bool down;
	int downCount;
	int downID;
	float bend;
	float bendStart;
	vector<Note *> notes;
    bool slideFlags[MAXTOUCHES]; 
    //PGMidi	*midi;
    //int midiNoteNum;
    MultiSampledSoundPlayer player;
	
	bool touchMovedFlag;
    	
	Bell(int _canvasX, int _canvasY, int _noteNum, int _octave, int _inst, ofxOpenALSoundPlayer (&_voices)[NUMVOICES], int *_currentChannel, ofImage(&_bellImages)[3]) {
			
//		myApp = (testApp*)ofGetAppPtr();
		
		// 0 = triad, 1 = scale, 2 = out
		int j=0;
		noteFunctions[j++] = 0;
		noteFunctions[j++] = 2;
		noteFunctions[j++] = 1;
		noteFunctions[j++] = 2;
		noteFunctions[j++] = 0;
		noteFunctions[j++] = 1;
		noteFunctions[j++] = 2;
		noteFunctions[j++] = 0;
		noteFunctions[j++] = 2;
		noteFunctions[j++] = 1;
		noteFunctions[j++] = 2;
		noteFunctions[j++] = 1;
		noteFunctions[j++] = 0;
		
		noteNum = _noteNum;
		octave = _octave;
		instrument = _inst;
		velocity = 1;
		
		voices = _voices;
		currentChannel = _currentChannel;
		myChannel = 0;
		voices[myChannel].setVolume(1);
		
		canvasX = _canvasX;
		canvasY = _canvasY;
		
		currentRadius = BELLRADIUS;
		targetRadius = BELLRADIUS;
		
		ratio = getRatio(noteNum, octave);
						
		dragging = false;
		down = false;
		dragID = -1;
		downID = -1;
		
		hue = noteNum / 13.0f;
		
		bendStart = 0;
		downCount = 0;

		int function = noteFunctions[noteNum];
		img = _bellImages[function];
		img.setAnchorPercent(0.5, 0.5);
		
		touchMovedFlag = false;
        
        for (int i=0; i<MAXTOUCHES; i++) {
            slideFlags[i] = false;
        }
        
        //midiNoteNum = noteNum + ((octave + 3) * 12);
        
        player.loadSamples("piano");
	};
	
	Bell() {
	}
	
	virtual void draw(float screenPosX, float screenPosY, float _zoom, float force, float _bend, bool showNoteNames) {

		touchMovedFlag = true;
		
		zoom = _zoom;
		
		screenX = (canvasX - screenPosX) * zoom;
		screenY = (canvasY - screenPosY) * zoom;
		
		if (!isOnScreen()) {
			return;
		}
		
		bend = _bend;
		
		if (down) {
			downCount++;
			if (downCount < 10) {
				float vol = ofMap(force, 0, 0.5, 0.8, 1);
				voices[myChannel].setVolume(vol);
				velocity = vol;
                player.setVolume(vol);

                // reset MIDI pitch bend
//                const UInt8 status = 0xE0 + instrument;
//                const UInt8 pitchBend[]  = { status, 0, 0x20 }; // centered
//                [midi sendBytes:pitchBend size:sizeof(pitchBend)];
			}
            if (downCount == 10) {
                bendStart = bend;
            }
			if (downCount > 10 && ((downCount % 10) == 0) ) {
				voices[myChannel].setPitch(ratio+(bend - bendStart));
                
                // MIDI pitch bend
//                const UInt8 status = 0xE0 + instrument;
//                float bendAmt = bend - bendStart;
//                printf("bendAmt: %f\n", bendAmt);
//                int bend14bit = ofMap(bendAmt, -0.1, 0.1, -4000, 4000); // max is 16383
//                bend14bit += 8192;
//                bend14bit = ofClamp(bend14bit, 0, 16383);
//                printf("bend14bit: %d\n", bend14bit);
//                const UInt8 LSB = UInt8(bend14bit & 0xff);
//                const UInt8 MSB = UInt8((bend14bit & 0xff00) >> 8); 
//                printf("LSB: %d MSB: %d\n", LSB, MSB);
//                const UInt8 pitchBend[]  = { status, LSB, MSB };
//                [midi sendBytes:pitchBend size:sizeof(pitchBend)];
			}
		} 
		
						
		float saturation = 1;
		float brightness = 1;
		if (octave == 0) {
			brightness = LOWOCTBRIGHTNESS;
		}
		if (octave == 2) {
			saturation = HIGHOCTSATURATION;
		}
		int rgb[3];
		setColorHSV(hue, saturation, brightness, rgb);
		if (dragging) {
			ofSetColor(rgb[0], rgb[1], rgb[2], 200);
		}
		img.draw(screenX, screenY, currentRadius * 2 * zoom, currentRadius * 2 * zoom);
		
		// draw note names
		if (showNoteNames) {
			ofSetHexColor(0x000000);
			ofDrawBitmapString(noteNames(noteNum), screenX+1-3, screenY+1+3);
			ofSetHexColor(0xffffff);
			ofDrawBitmapString(noteNames(noteNum), screenX-3, screenY+3);
		}
		if (currentRadius != targetRadius) {
			currentRadius += (targetRadius - currentRadius) / 10;
			// round here?
		}
	}
	void startDrag(int id, float xOffset, float yOffset) {
		dragging = true;
		dragID = id;
		dragOffsetX[id] = xOffset;
		dragOffsetY[id] = yOffset;
	}
//    void setMidi(PGMidi *_midi) {
//        midi = _midi;
//    }
	virtual void playNote() {
        player.playNote(noteNum, octave);
        
		*currentChannel += 1;
		*currentChannel %= NUMVOICES;
		
		myChannel = *currentChannel;
				
		voices[myChannel].setPitch(ratio);
		//voices[myChannel].play();
		
		currentRadius = BELLRADIUS + 25;
        
 //       midiNoteOn(midiNoteNum, instrument, velocity);
    }
    void midiNoteOn(int num, int inst, float vel) {        
        const UInt8 note = num;
        const UInt8 status = 0x90 + inst; // status byte for noteOn is 0x90 + low nibble is channel
        const UInt8 velocity = UInt8(vel * 127);
        const UInt8 noteOn[]  = { status, note, velocity };
  //      [midi sendBytes:noteOn size:sizeof(noteOn)];
        
    }
    void midiNoteOff() {        
   //     const UInt8 note = midiNoteNum;
        const UInt8 status = 0x80 + instrument; // status byte for noteOff is 0x80 + low nibble is channel
        const UInt8 vel = UInt8(velocity * 127);
       // const UInt8 noteOff[]  = { status, note, vel };
     //   [midi sendBytes:noteOff size:sizeof(noteOff)];
        
    }
	bool touchDown(int tx, int ty, int id) {
		if (ofDist(tx, ty, screenX, screenY) < (currentRadius * zoom)) {
			playNote();
			down = true;
			downID = id;
			bendStart = bend;
			//startDrag(id, (screenX-tx), (screenY-ty));
			
			return true;
//		} else if (ofDist(tx, ty, screenX, screenY) < (currentRadius + DRAGZONE) * zoom) {
//			// this is the edge of the bell so just drag, don't play
//			startDrag(id, (screenX-tx), (screenY-ty));
//			return true;
//		} else if (ofDist(tx, ty, screenX, screenY + (currentRadius * zoom)) < DRAGZONE * zoom) {
//			startDrag(id, (screenX-tx), (screenY-ty));
//			return true;
		} else {
			return false;
		}

	}
	bool touchMoved(float tx, float ty, int id) {
		// use flag to do this only once per draw		
	//	if (touchMovedFlag) {
	//		touchMovedFlag = false;
		
			// start dragging if we've crossed the edge of a bell
			if (down && !dragging && (id == downID)) {
				if (ofDist(tx, ty, screenX, screenY) > (currentRadius * zoom)) {
					startDrag(id, screenX - tx, screenY - ty);
				}
			}
			if (dragging && id == dragID) {			
				canvasX = (canvasX + (tx - screenX) + dragOffsetX[id]);
				canvasY = (canvasY + (ty - screenY) + dragOffsetY[id]);
				return true;
			} else {
				return false;
			}
	//	}
		return false;

	}
    bool slide(int tx, int ty, int id) {
        if (ofDist(tx, ty, screenX, screenY) < (currentRadius * zoom)) {
            if (!slideFlags[id]) {
                slideFlags[id] = true;
                playNote();
                return true;
            }
        } else {
            slideFlags[id] = false;
        }
        return false;
    }
    
	void touchUp(int tx, int ty, int id) {
                
		if (id == downID) {
			if (downCount > 20) { // short taps do not get a note off (i.e. hold down to sustain and release, otherwise just sustain)
                midiNoteOff();     // the problem is that some instruments do not have a finite decay, so you get a stuck note
            }
            down = false;
			downCount = 0;
            
		}
		if (dragging && id == dragID) {
			dragging = false;
		}
	}
	bool deleteMe(int id) {
		if (dragging && id == dragID) {
			return true;
		} else {
			return false;
		}
	}
	float getRatio(int note, int oct) {
		float noteRatios[NUMNOTES];
		int i=0;
		noteRatios[i++] = note_C;
		noteRatios[i++] = note_Cs;
		noteRatios[i++] = note_D;
		noteRatios[i++] = note_Ds;
		noteRatios[i++] = note_E;
		noteRatios[i++] = note_F;
		noteRatios[i++] = note_Fs;
		noteRatios[i++] = note_G;
		noteRatios[i++] = note_Gs;
		noteRatios[i++] = note_A;
		noteRatios[i++] = note_As;
		noteRatios[i++] = note_B;
		noteRatios[i++] = note_C2;
		
		float r = noteRatios[note];
		if (oct == 0) {
			r /= 2.0f;
		} 
		if (oct == 2) {
			r *= 2;
		}
		return r;
	}
	float getCanvasX() {
		return canvasX;
	}
	float getCanvasY() {
		return canvasY;
	}
	float getNoteNum() {
		return noteNum;
	}
	float getOctave() {
		return octave;
	}
	float getInstrument() {
		return instrument;
	}
	float getVelocity() {
		return velocity;
	}
	float getHue() {
		return hue;
	}
	virtual bool isRecorderBell() {
		return false;
	}
	virtual vector<Note *> getNotes() {
		vector<Note *> n;
		return n;
	}
	bool isOnScreen() {
		if (screenX < (0 - (currentRadius * zoom))) {
			return false;
		}
		if (screenX > (ofGetWidth() + (currentRadius  * zoom))) {
			return false;
		}
		if (screenY < (0 - (currentRadius * zoom))) {
			return false;
		}
		if (screenY > (ofGetHeight() + (currentRadius * zoom))) {
			return false;
		}
		return true;
	}
};
#endif

