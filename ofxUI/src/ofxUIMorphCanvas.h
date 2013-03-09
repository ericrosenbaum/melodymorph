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
    MorphMetaData selectedMorph;
    vector<MorphMetaData> morphs;
    int pageNum;
    
    bool prevButtonVisible;
    bool nextButtonVisible;

    ofxUIMorphCanvas(int x,int y,int w,int h) : ofxUICanvas(x,y,w,h)
    {
        
    }
    ofxUIMorphCanvas() : ofxUICanvas()
    {
    }
    
    void highlightButton(int num) {
        setDrawWidgetPadding(false); // turn off all button highlights
        
        // highlight the one with the id num
        vector <ofxUIWidget *> widgets = getWidgets();
        for (int i=0; i<widgets.size(); i++) {
            if (widgets[i]->getID() == num) {
                widgets[i]->setDrawPadding(true);
                return;
            }
        }
    }
    
    void setSelectedMorph(MorphMetaData _morph) {
        selectedMorph = _morph;
    }
    MorphMetaData getSelectedMorph() {
        return(selectedMorph);
    }
    void setMorphs(vector<MorphMetaData> _morphs) {
        morphs = _morphs;
    }
    vector<MorphMetaData> getMorphs() {
        return morphs;
    }
    void setPageNum(int _pageNum) {
        pageNum = _pageNum;
    }
    int getPageNum(){
        return pageNum;
    }
    
    
    
};

#endif

