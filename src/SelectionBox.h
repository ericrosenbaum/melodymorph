//
//  SelectionBox.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 6/16/13.
//
//

#ifndef MelodyMorph_SelectionBox_h
#define MelodyMorph_SelectionBox_h

#include "ofMain.h"
#include "ofxUI.h"

class SelectionBox {
  
public:
    
    ofRectangle rect; // in canvas coords, as are all arguments
    bool begun;
    ofPoint dragPrev;
    ofxUICanvas *canvas;
    float buttonHeight;
    
    string buttonNames[3] = {"duplicate", "pitch +", "pitch -"};
    
    SelectionBox() {
        canvas = new ofxUICanvas(0, 0, ofGetWidth(), ofGetHeight());
        canvas->setDrawBack(false);
        
        for (int i=0; i<3; i++) {
            ofxUILabelButton *btn = new ofxUILabelButton(false, buttonNames[i]);
            canvas->addWidgetRight(btn);
            buttonHeight = btn->getRect()->height;
        }
        
        reset();
        ofAddListener(canvas->newGUIEvent, this, &SelectionBox::guiEvent);

    };
    
    void reset() {
        rect = *new ofRectangle();
        begun = false;
        canvas->setVisible(false);
    }

    void setSelectionStart(int _x, int _y) {
        rect.set(_x, _y, 0, 0);
        begun = true;
        canvas->setVisible(true);
    }
    
    void updateSelection(int _x, int _y) {
        rect.width = _x - rect.x;
        rect.height = _y - rect.y;
    }
    
    void startDrag(int x, int y) {
        dragPrev.set(x, y);
    }
    
    void drag(int x, int y) {
        rect.x += x - dragPrev.x;
        rect.y += y - dragPrev.y;
        
        dragPrev.x = x;
        dragPrev.y = y;
        
    }
    
    ofRectangle getFlipped() {
        
        // this function gives you back a rectangle that has positive width and height
        // sometimes they are negative, when you drag to select up or left
        // so this flips the coordinates in those cases
        
        ofRectangle r = ofRectangle(rect);
        
        if (r.width < 0) {
            r.width *= -1;
            r.x -= r.width;
        }
        if (r.height < 0) {
            r.height *= -1;
            r.y -= r.height;
        }
        
        return r;
    }
    
    bool isInside(int x, int y) {
        ofRectangle r = getFlipped();
        return r.inside(x, y);
    }
    

    ofPoint getTopLeft() {
        ofRectangle r = getFlipped();
        return ofPoint(r.x, r.y);
    }
    
    void draw(float screenPosX, float screenPosY, float zoom) {
        
        // convert to screen coords for drawing
        ofRectangle r = getFlipped();
        float x = (r.x - screenPosX) * zoom;
        float y = (r.y - screenPosY) * zoom;
        float w = r.width * zoom;
        float h = r.height * zoom;
        
        // move the buttons to the top left of the selection box
        canvas->setRectParent(new ofxUIRectangle(x, y-buttonHeight, w, h));
        
        ofSetColor(SELECTION_COLOR);
        ofRect(x, y, w, h);
    }
    
    void guiEvent(ofxUIEventArgs &e) {
        ofxUILabelButton *btn = (ofxUILabelButton *)e.widget;
        if (! btn->getValue()) { // touch up
            string name = e.widget->getName();
            ofSendMessage(name);
        }
    }
};

#endif
