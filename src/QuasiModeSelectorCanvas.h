
//
//  QuasiModeSelectorCanvas.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 3/3/13.
//
//

#ifndef MelodyMorph_QuasiModeSelectorCanvas_h
#define MelodyMorph_QuasiModeSelectorCanvas_h

#define NUM_MODES                   5

// quasi modes
#define NONE                        0
#define DRAW_MODE                   1
#define ERASE_MODE                  2
#define SLIDE_MODE                  3
#define SELECT_MODE                 4
#define MUTE_MODE                   5

class QuasiModeSelectorCanvas : public ofxUICanvas {

public:
    // quasi modes
    // they are mutually exclusive modes, only active while you're holding one down
    int currentMode;
    
    ofxUIImageButton *drawButton;
    ofxUIImageButton *eraseButton;
    ofxUIImageButton *slideButton;
    ofxUIImageButton *selectButton;
    ofxUIImageButton *muteButton;

    // icon image file names
    string names[NUM_MODES] = {"pencil_button", "eraser_button", "slide_button", "select_button", "mute_button"};
    
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
            ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
            
            // set currentMode to the corresponding #defined int value (above)
            if (name == names[i]) {
                ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
                if (btn->getValue()) { // touch down
                    currentMode = i+1;
                } else {
                    resetMode();
                }
            }
            
            // if we just released the select button, send a message to testApp
            // so that we can deselect everything
            if (name == "select_button") {
                if (!btn->getValue()) { // touch up
                    ofSendMessage("select_button_released");
                }
            }
        }
    }
};

#endif
