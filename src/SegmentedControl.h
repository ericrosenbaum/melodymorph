//
//  SegmentedControl.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 2/12/13.
//
//

#ifndef MelodyMorph_SegmentedControl_h
#define MelodyMorph_SegmentedControl_h

class SegmentedControl : public ofxUIWidget {

public:
    SegmentedControl(vector<string> _names):ofxUIWidget(){
        
        names = _names;
        
        for (int i=0; i<names.size(); i++) {
            toggles.push_back(new ofxUILabelToggle(false, names[i]));
        }
    }
    
protected:
    vector<string> names;
    vector<ofxUILabelToggle*> toggles;
    
};

#endif
