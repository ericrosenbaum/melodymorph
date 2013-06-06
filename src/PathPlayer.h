//
//  PathPlayer.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 6/5/13.
//
//

#ifndef MelodyMorph_PathPlayer_h
#define MelodyMorph_PathPlayer_h


#include "Bell.mm"
#include "PathPoint.cpp"

class PathPlayer : public Bell {
    
public:

    vector<PathPoint *> pathPoints;
    
    PathPlayer(int _canvasX, int _canvasY, ofImage _img) {
        canvasX = _canvasX;
        canvasY = _canvasY;
        
        img = _img;
        img.setAnchorPercent(0.5, 0.5);
        
        currentRadius = RECBELLRADIUS;
    }
    
    void draw(float screenPosX, float screenPosY, float _zoom) {
        
    }
    
};


#endif
