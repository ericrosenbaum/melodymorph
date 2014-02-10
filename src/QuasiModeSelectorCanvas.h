
//
//  QuasiModeSelectorCanvas.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 3/3/13.
//
//

#ifndef MelodyMorph_QuasiModeSelectorCanvas_h
#define MelodyMorph_QuasiModeSelectorCanvas_h

#define NUM_MODES                   6

// quasi modes
#define NONE                        0
#define DRAW_MODE                   1
#define ERASE_MODE                  2
#define SELECT_MODE                 3
#define PATH_MODE                   4
#define MUTE_MODE                   5
#define SLIDE_MODE                  6

// selection mode states
#define SELECT_DRAWING              0
#define SELECT_DONE_DRAWING         1

class QuasiModeSelectorCanvas : public ofxUICanvas {

public:
    // quasi modes
    // they are mutually exclusive modes, only active while you're holding one down
    int currentMode;
    
    int selectionState;
    
    // icon image file names
    string names[NUM_MODES] = {"pencil_button", "eraser_button", "select_button", "path_button", "mute_button", "slide_button"};
        
    QuasiModeSelectorCanvas(int x,int y,int w,int h) : ofxUICanvas(x,y,w,h)
    {
        currentMode = NONE;
        
        setWidgetSpacing(0);
        
        for (int i=0; i<NUM_MODES; i++) {
            ofxUIImageButton *b = new ofxUIImageButton(100, 100, false, "GUI/" + names[i] + ".png", names[i]);
            b->setColorFillHighlight(127);    // down
            b->setColorBack(255);             // false
            addWidgetDown(b);
            
            // add a spacer between edit-modes and play modes
            if (i==4) {
                ofxUISpacer *spacer = new ofxUISpacer(100,30);
                spacer->setVisible(false);
                addWidgetDown(spacer);
            }
        }
        
        setDrawBack(false);
        ofAddListener(newGUIEvent, this, &QuasiModeSelectorCanvas::guiEvent);
        
        autoSizeToFitWidgets();
    }

    void resetMode() {
        currentMode = NONE;
    }
    
    int getCurrentMode() {
        return currentMode;
    }
    
    int getSelectionState() {
        return selectionState;
    }
    
    void setSelectionState(int s) {
        selectionState = s;
    }
    
    void setVisibilityOfEditModesOnly(bool visible) {
        vector<ofxUIWidget *> w = getWidgets();
        for (int i=0; i<5; i++) {
            w[i]->setVisible(visible);
        }
    }
    
    bool isHit(float x, float y, bool allModes) {
        vector<ofxUIWidget *> w = getWidgets();
        if (allModes) {
            for (int i=0; i<NUM_MODES; i++) {
                if (w[i]->isHit(x, y)) {
                    return true;
                }
            }
        } else {
            if (w[NUM_MODES-1]->isHit(x, y)) {
                return true;
            }
//            if (w[NUM_MODES-2]->isHit(x, y)) {
//                return true;
//            }
        }
        return false;
    }
    
    void guiEvent(ofxUIEventArgs &e) {
        string name = e.widget->getName();
        
        ofxUIButton *btn = (ofxUIButton *) e.widget;

        for (int i=0; i<NUM_MODES; i++) {
            // set currentMode to the corresponding #defined int value (above)
            if (name == names[i]) {
                if (btn->getValue()) { // touch down
                    currentMode = i+1;
                } else {
                    resetMode();
                }
            }
        }
        
        // when we first enter selection mode, we are about to draw a selection
        if (name == "select_button") {
            if (btn->getValue()) { // touch down
                selectionState = SELECT_DRAWING;
                autoSizeToFitWidgets();
                ofSendMessage("select_button_pressed");
            }
        }
        // if we just released the select button, send a message to testApp
        // so that we can deselect everything
        if (name == "select_button") {
            if (!btn->getValue()) { // touch up
                autoSizeToFitWidgets();
                ofSendMessage("select_button_released");
            }
        }
    }
};

#endif
