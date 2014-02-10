//
//  ToggleCanvas.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 2/6/14.
//
//

#ifndef MelodyMorph_ToggleCanvas_h
#define MelodyMorph_ToggleCanvas_h

class ToggleCanvas : public ofxUICanvas {
    
public:
    
    ToggleCanvas() : ofxUICanvas(x,y,w,h)
    {
        ofxUIImageButton *b = new ofxUIImageButton(100, 100, false, "GUI/help_button.png", "help_button");
        b->setColorFillHighlight(127);    // down
        b->setColorBack(255);             // false
        addWidgetDown(b);
        setDrawBack(false);
        ofAddListener(newGUIEvent, this, &ToggleCanvas::guiEvent);
        autoSizeToFitWidgets();
    }
    
    void guiEvent(ofxUIEventArgs &e) {

        string name = e.widget->getName();
        ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
        if (!btn->getValue()) { // touch up (can't do touch up inside since we don't know the touch coords here)
            ofSendMessage("help button pressed");
        }
    }


};

#endif
