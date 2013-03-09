
//
//  QuasiModeSelectorCanvas.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 3/3/13.
//
//

#ifndef MelodyMorph_QuasiModeSelectorCanvas_h
#define MelodyMorph_QuasiModeSelectorCanvas_h

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
    
    QuasiModeSelectorCanvas(int x,int y,int w,int h) : ofxUICanvas(x,y,w,h)
    {
        currentMode = NONE;
        
        drawButton = new ofxUIImageButton(100, 100, true, "GUI/pencil_button.png", "drawButton");
        addWidgetDown(drawButton);
        eraseButton = new ofxUIImageButton(100, 100, true, "GUI/eraser_button.png", "eraseButton");
        addWidgetDown(eraseButton);
        slideButton = new ofxUIImageButton(100, 100, true, "GUI/slide_button.png", "slideButton");
        addWidgetDown(slideButton);
        selectButton = new ofxUIImageButton(100, 100, true, "GUI/slide_button.png", "selectButton");
        addWidgetDown(selectButton);
        
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
        
        if (name == "drawButton") {
            ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
            if (btn->getValue()) { // touch down
                currentMode = DRAW_MODE;
            } else {
                resetMode();
            }
        }
        if (name == "eraseButton") {
            ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
            if (btn->getValue()) { // touch down
                currentMode = ERASE_MODE;
            } else {
                resetMode();
            }
        }
        if (name == "slideButton") {
            ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
            if (btn->getValue()) { // touch down
                currentMode = SLIDE_MODE;
            } else {
                resetMode();
            }
        }
        if (name == "selectButton") {
            ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
            if (btn->getValue()) { // touch down
                currentMode = SELECT_MODE;
            } else {
                resetMode();
            }
        }

    }
};

#endif
