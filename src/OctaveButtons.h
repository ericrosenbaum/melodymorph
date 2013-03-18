//
//  OctaveButtons.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 3/15/13.
//
//

#ifndef MelodyMorph_OctaveButtons_h
#define MelodyMorph_OctaveButtons_h

class OctaveButtons : public ofxUICanvas {
    
public:

    int octave;
    ofxUIImageButton *left;
    ofxUIImageButton *right;
    
    OctaveButtons(int x,int y,int w,int h) : ofxUICanvas(x,y,w,h) {
        
        left = new ofxUIImageButton(50, 50, false, "GUI/button_left.png", "left_button");
        right = new ofxUIImageButton(50, 50, false, "GUI/button_right.png", "right_button");
        
        left->setColorFillHighlight(100);    // down
        left->setColorBack(255);             // false/normal

        right->setColorFillHighlight(100);    // down
        right->setColorBack(255);             // false/normal
        
        addWidgetPosition(left, OFX_UI_WIDGET_POSITION_LEFT, OFX_UI_ALIGN_LEFT);
        addWidgetPosition(right, OFX_UI_WIDGET_POSITION_RIGHT, OFX_UI_ALIGN_RIGHT);
        
        ofAddListener(newGUIEvent, this, &OctaveButtons::guiEvent);
        
        octave = 1;
    }
    
    void octaveDown() {
        octave -= 1;
        if (octave == 0) {
            left->setVisible(false);
        }
        right->setVisible(true);
    }

    void octaveUp() {
        octave += 1;
        if (octave == 2) {
            right->setVisible(false);
        }
        left->setVisible(true);
    }
    
    int getOctave() {
        return octave;
    }
    
    void reset() {
        octave = 1;
        left->setVisible(true);
        right->setVisible(true);
    }

    void guiEvent(ofxUIEventArgs &e) {
        ofxUIImageButton *b = (ofxUIImageButton *) e.widget;
        string name = b->getName();
        if (!b->getValue()) { // touch up
            if (name == "left_button") {
                octaveDown();
            }
            if (name == "right_button") {
                octaveUp();
            }
        }
    }
};

#endif
