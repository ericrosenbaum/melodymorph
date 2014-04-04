#ifndef _BELL_ER
#define _BELL_ER

/*
 *  Bell.cpp
 */

#include "ofMain.h"

#include "config.h"
#include "utils.h"
#include "Note.cpp"
#include "SelectionBox.h"
#include "PolySynth.h"

#include "ofxSpriteSheetRenderer.h"

class Bell {
		
public:
	
	float canvasX, canvasY;
	int noteNum;
	float velocity;
	
	float screenX, screenY;
	float ratio;
	ofImage *img;
    vector<ofImage *> bellImages;
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
    PolySynth *player;
	
	bool touchMovedFlag;
    
    bool isSelected;
    
    ofxSpriteSheetRenderer *renderer;
    
	Bell(int _canvasX, int _canvasY, int _noteNum, int _octave, int _inst, ofxSpriteSheetRenderer *_renderer) {
			
         renderer = _renderer;
        
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
		
		touchMovedFlag = false;
        
        for (int i=0; i<MAXTOUCHES; i++) {
            slideFlags[i] = false;
        }
        
        isSelected = false;
    };
	
	Bell() {
	}
    
    void setPlayer(PolySynth *p) {
        player = p;
    }

    void setImageTriplet(vector<ofImage *> _bellImages) {
        bellImages = _bellImages;
        setImg();
    }
    
    void setImg() {
		int function = noteFunctions[noteNum];
		img = bellImages[function];
		img->setAnchorPercent(0.5, 0.5);
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
		      
		float saturation = 1;
		float brightness = 1;
		if (octave == 0) {
			brightness = LOWOCTBRIGHTNESS;
		}
		if (octave == 2) {
			saturation = HIGHOCTSATURATION;
		}
        if (isSelected) {
            brightness = ofMap(sin(ofGetElapsedTimef()*18),-1,1,0.5,1);
        }
        
		int rgb[3];
		setColorHSV(hue, saturation, brightness, rgb);

		if (dragging) {
			ofSetColor(rgb[0], rgb[1], rgb[2], 200);
		}
        
        // new style faster drawing using sprite sheet!
        renderer->addCenteredTile(noteFunctions[noteNum] + instrument * 8,
                                        0,
                                        screenX,screenY,
                                        0,1,1,F_NONE,
                                        currentRadius / BELLRADIUS * zoom,
                                        rgb[0],rgb[1],rgb[2],255);

        
		// draw note names
		if (showNoteNames) {
			ofSetHexColor(0x000000);
			ofDrawBitmapString(noteNames(noteNum), screenX+1-3, screenY+1+3);
			ofSetHexColor(0xffffff);
			ofDrawBitmapString(noteNames(noteNum), screenX-3, screenY+3);
		}
		if (currentRadius != targetRadius) {
			currentRadius += (targetRadius - currentRadius) / 10;
		}
	}
	void startDrag(int id, float xOffset, float yOffset) {
		dragging = true;
		dragID = id;
		dragOffsetX[id] = xOffset;
		dragOffsetY[id] = yOffset;
	}
	virtual void playNote() {
        player->playNote(noteNum, octave);
		currentRadius = BELLRADIUS + 25;
    }

	bool touchDown(int tx, int ty, int id) {
		if (ofDist(tx, ty, screenX, screenY) < (currentRadius * zoom)) {
            
			down = true;
			downID = id;
			bendStart = bend;
			
			return true;
		} else {
			return false;
		}

	}
	bool touchMoved(float tx, float ty, int id) {
		
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
    
    void deselect() {
        isSelected = false;
    }

    void setSelectedIfInside(SelectionBox s) {
        if (s.isInside(canvasX, canvasY)) {
            isSelected = true;
        }
    }
    
    virtual void dragIfSelected(ofPoint prev, int x, int y) {
        if (isSelected) {
            canvasX += x - prev.x;
            canvasY += y - prev.y;
        }
    }
    bool getIsSelected() {
        return isSelected;
    }
    
	void touchUp(int tx, int ty, int id) {
                
		if (id == downID) {
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
	virtual bool isPathPlayer() {
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
    
    void changePitchBy(int num){
        noteNum += num;
        if (noteNum > 12) {
            noteNum -= 12;
            octave++;
            if (octave > 2) {
                octave -= 3;
            }
        }
        if (noteNum < 0) {
            noteNum += 12;
            octave--;
            if (octave < 0) {
                octave += 3;
            }
        }
        setImg();
        hue = noteNum / 13.0f;
    }
};
#endif

