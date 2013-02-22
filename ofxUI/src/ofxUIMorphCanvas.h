//
//  ofxUIMorphCanvas.h
//
//  Created by Eric Rosenbaum on 2/7/13.
//
//

#ifndef emptyExample_ofxUIMorphCanvas_h
#define emptyExample_ofxUIMorphCanvas_h

#import "utils.h"

class ofxUIMorphCanvas : public ofxUICanvas
{
public:
    ofxUIMorphCanvas(int x,int y,int w,int h) : ofxUICanvas(x,y,w,h)
    {
        
    }
    
    void setMorph(MorphMetaData _morph) {
        morph = _morph;
    }
    MorphMetaData getMorph() {
        return(morph);
    }
    
    
protected:
    MorphMetaData morph;
};

#endif

