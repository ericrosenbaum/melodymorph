//
//  RecorderMaker.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 3/18/13.
//
//

#ifndef MelodyMorph_RecorderMaker_h
#define MelodyMorph_RecorderMaker_h

class RecorderMaker : public ofxUICanvas {
    
public:

	testApp *myApp;
	ofxUIImageToggle *toggleButton;
	bool recording;
	float recStartTime;
	int noteCount;
	vector<Note*> notes;
    
    
    RecorderMaker(int x,int y,int w,int h) : ofxUICanvas(x,y,w,h) {
        toggleButton = new ofxUIImageToggle(x, y, false, "rec_bell_maker.png");
    }
};

#endif
