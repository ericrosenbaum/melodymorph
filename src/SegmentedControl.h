//
//  SegmentedControl.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 2/12/13.
//
//

#ifndef MelodyMorph_SegmentedControl_h
#define MelodyMorph_SegmentedControl_h

class SegmentedControl : public ofxUICanvas {

public:
    
    vector<ofxUIImageToggle*> toggles;

    SegmentedControl(int x,int y,int w,int h) : ofxUICanvas(x,y,w,h) {
    }
    
    void initWithNames(vector<string> names) {

        setWidgetSpacing(0);
        setPadding(0);

        for (int i=0; i<names.size(); i++) {
            string imgPath = "GUI/tab-middle.png";
            if (i == 0) {
                imgPath = "GUI/tab-left.png";
            }
            if (i == names.size() - 1) {
                imgPath = "GUI/tab-right.png";
            }
            
            ofxUIImageToggle *t = new ofxUIImageToggle(90, 35, false, imgPath, names[i]);
            t->setColorFill(255);             // true
            t->setColorFillHighlight(127);    // down
            t->setColorBack(80);              // false
            t->setPadding(1);
            toggles.push_back(t);

            ofxUILabel *label = new ofxUILabel(0, 0, "label", names[i], OFX_UI_FONT_MEDIUM);
            
            addWidget(label);
            addWidgetRight(t);
            
            // ofxui draws things in reverse order that they are added, so the labels must be added
            // before the image toggles in order to show up in front of them. but in order to
            // set the position of the label using the toggle position, the toggle has to be added first...
            // so that's why I'm positioning the label down here
            ofxUIRectangle *r = t->getRect();
            int x = r->getX();
            int y = r->getY();
            label->getStringWidth(names[i]);
            label->getRect()->set(x+20, y-10, 90, 35);
        }
        
        ofAddListener(newGUIEvent, this, &SegmentedControl::guiEvent);
        
        centerWidgetsHorizontallyOnCanvas();
        setDrawBack(false);
        
        reset();
    }
    
    void setSelectedIndex(int num) {
        setAllTogglesFalse();
        toggles[num]->setValue(true);
    }

    int getSelectedIndex() {
        for (int i=0; i<toggles.size(); i++) {
            if (toggles[i]->getValue() == true) {
                return i;
            }
        }
        return -1;
    }
    
    void reset() {
        setAllTogglesFalse();
        toggles[toggles.size()-1]->setValue(true);
    }
    
    void setAllTogglesFalse() {
        for (int i=0; i<toggles.size(); i++) {
            toggles[i]->setValue(false);
        }
    }
    
    void guiEvent(ofxUIEventArgs &e) {
        ofxUIImageToggle *t = (ofxUIImageToggle *) e.widget;
        string name = t->getName();
        setAllTogglesFalse();
        t->setValue(true);
        ofSendMessage(name);
    }
    
};

#endif
