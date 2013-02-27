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
    MorphMetaData morph;
    int pageNum;
    
    bool prevButtonVisible;
    bool nextButtonVisible;

    ofxUIMorphCanvas(int x,int y,int w,int h) : ofxUICanvas(x,y,w,h)
    {
        
    }
    ofxUIMorphCanvas() : ofxUICanvas()
    {
    }
    
    void setMorph(MorphMetaData _morph) {
        morph = _morph;
    }
    MorphMetaData getMorph() {
        return(morph);
    }
    
    void setPageNum(int _pageNum) {
        pageNum = _pageNum;
    }
    int getPageNum(){
        return pageNum;
    }
    
    
    
};

#endif

