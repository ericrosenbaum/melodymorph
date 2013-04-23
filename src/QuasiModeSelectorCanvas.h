
//
//  QuasiModeSelectorCanvas.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 3/3/13.
//
//

#ifndef MelodyMorph_QuasiModeSelectorCanvas_h
#define MelodyMorph_QuasiModeSelectorCanvas_h

#define NUM_MODES                   4

// quasi modes
#define NONE                        0
#define DRAW_MODE                   1
#define ERASE_MODE                  2
#define SLIDE_MODE                  3
#define SELECT_MODE                 4

class QuasiModeSelectorCanvas : public ofxUICanvas {

public:
    // quasi modes
    // they are mutually exclusive modes, only active while you're holding one down
    int currentMode;
    
    ofxUIImageButton *drawButton;
    ofxUIImageButton *eraseButton;
    ofxUIImageButton *slideButton;
    ofxUIImageButton *selectButton;
    
    string names[4] = {"pencil_button", "eraser_button", "slide_button", "select_button"}; // icon image file names
    
    QuasiModeSelectorCanvas(int x,int y,int w,int h) : ofxUICanvas(x,y,w,h)
    {
        currentMode = NONE;
        
        for (int i=0; i<NUM_MODES; i++) {
            ofxUIImageButton *b = new ofxUIImageButton(100, 100, false, "GUI/" + names[i] + ".png", names[i]);
            b->setColorFillHighlight(127);    // down
            b->setColorBack(255);             // false
            addWidgetDown(b);
        }
                
        setDrawBack(false);
        
        ofAddListener(newGUIEvent, this, &QuasiModeSelectorCanvas::guiEvent);
    }

    void resetMode() {
        currentMode = NONE;
    }
    
    int getCurrentMode() {
        return currentMode;
    }
    
    void guiEvent(ofxUIEventArgs &e) {
        string name = e.widget->getName();
        
        for (int i=0; i<NUM_MODES; i++) {
            if (name == names[i]) {
                ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
                if (btn->getValue()) { // touch down
                    currentMode = i+1;
                } else {
                    resetMode();
                }
            }
        }
    }
};

#endif
