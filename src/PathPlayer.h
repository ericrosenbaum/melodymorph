//
//  PathPlayer.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 6/5/13.
//
//

#ifndef MelodyMorph_PathPlayer_h
#define MelodyMorph_PathPlayer_h

/*
  things to fix

 box update on load
 not playing the last one or two pathpoints?
 
 */


#include "Bell.mm"
#include "PathPoint.cpp"
#include "BoundingBoxForLine.h"

class PathPlayer : public Bell {
    
public:

    vector<PathPoint *> pathPoints;
    BoundingBoxForLine *box;
    
    float drawingStartTime;
    
    bool playing;
    float playBackStartTime;
    
    ofImage pathHeadImg;
    ofPoint pathHeadPoint;
    int pathPointsIndex;
    
    float pathHeadAngle;
    float targetPathHeadAngle;
    
    float imgAngle;
    bool imgAngleSet;
    
    vector <Bell *> *bells;
    Bell *BellTheHeadIsTouching;
    Bell *myself;
    
    int screenPosX, screenPosY;
    
    float tempoInterval;
    
    PathPlayer(int _canvasX, int _canvasY, ofImage *_img, ofImage _pathHeadImg, vector <Bell *> *_bells) {
        bells = _bells;
        BellTheHeadIsTouching = nil;
        myself = this;
        
        playing = false;
        
        canvasX = _canvasX;
        canvasY = _canvasY;
        
        img = _img;
        img->setAnchorPercent(0.5, 0.5);
        imgAngle = 0;
        imgAngleSet = false;
        
        pathHeadImg = _pathHeadImg;
        pathHeadImg.setAnchorPercent(0.5, 0.5);
        
        currentRadius = PATHPLAYERRADIUS;
        targetRadius = PATHPLAYERRADIUS;
        
        drawingStartTime = ofGetElapsedTimef();
        
        tempoInterval = 0.5;
        
        // set up bounding box
        // in this case bounding box coordinates are stored as
        // relative canvas coordinates: the distance in canvas units from the anchor point
        box = new BoundingBoxForLine();
        
        // initial update sets the anchor point for the bounding box (the center of the path player)
        // which is used to recalculate the bounding box if the path player is dragged
        box->update(canvasX, canvasY);
        
        // update bounding box to include the path player object
        float r = PATHPLAYERRADIUS;
        
        int topLeftX = canvasX - r;
        int topLeftY = canvasY - r;
        box->update(topLeftX, topLeftY);

        int bottomRightX = canvasX + r;
        int bottomRightY = canvasY + r;
        box->update(bottomRightX, bottomRightY);
        
        // other init stuff
        dragging = false;
		down = false;
		dragID = -1;
		downID = -1;
				
		bendStart = 0;
		downCount = 0;
		
		touchMovedFlag = false;
        
        for (int i=0; i<MAXTOUCHES; i++) {
            slideFlags[i] = false;
        }
        
        isSelected = false;

    }
    
    void draw(float _screenPosX, float _screenPosY, float _zoom, float force, float _bend, bool showNoteNames) {
        zoom = _zoom;
        
        screenPosX = _screenPosX;
        screenPosY = _screenPosY;
		
		screenX = (canvasX - screenPosX) * zoom;
		screenY = (canvasY - screenPosY) * zoom;
        
        if (dragging) {
            box->moveAnchorPointTo(canvasX, canvasY);
        }

        if (playing) {
            movePathHeadAndPlayBells();
        }
        
        if (box->isOnScreen(screenPosX, screenPosY, zoom)) {
            drawPath();
            drawImage();
            drawPathHead();
        }
        
    }
    
    void drawPath() {

        if (pathPoints.size() == 0) {
            return;
        }
        
        int prevX = pathPoints[0]->x + canvasX;
        int prevY = pathPoints[0]->y + canvasY;
        prevX = (prevX - screenPosX) * zoom;
		prevY = (prevY - screenPosY) * zoom;
        
        ofColor pink;
        pink.setHsb(220,255,255);
        if (!playing) {
            pink.setBrightness(75);
        }
        
        ofColor white;
        white.setHsb(0, 0, 255);
        if (!playing) {
            white.setBrightness(75);
        }
        
		for (int i=1; i<pathPoints.size(); i++) {
            if ((i%2)==0) {
                ofSetColor(pink);
            } else {
                ofSetColor(white);
            }
            
            int x = pathPoints[i]->x + canvasX;
            int y = pathPoints[i]->y + canvasY;
            x = (x - screenPosX) * zoom;
            y = (y - screenPosY) * zoom;
			ofLine(prevX, prevY, x, y);
			prevX = x;
			prevY = y;
		}

    }
    
    void drawImage() {
        
        ofColor gray;
        gray.setHsb(0,0,255);
        if(!playing) {
            gray.setBrightness(150);
        }
        int alpha = 255;
        if (dragging) {
            alpha = 200;
        }
        if (isSelected) {
            float brightness = ofMap(sin(ofGetElapsedTimef()*18),-1,1,0.5,1);
            gray.setBrightness(brightness * 255);
        }
        ofSetColor(gray, alpha);
		
		if (currentRadius != targetRadius) {
			currentRadius += (targetRadius - currentRadius) / 10;
		}
        
        float r = currentRadius * 2 * zoom;
//		img.draw(screenX, screenY, r, r);
        
        if (pathPoints.size() > 1 && !imgAngleSet) {
            int x1 = pathPoints[0]->x;
            int y1 = pathPoints[0]->y;
            int x2 = pathPoints[1]->x;
            int y2 = pathPoints[1]->y;
            
            imgAngle = ofRadToDeg(atan2(x2-x1, y2-y1));
            imgAngleSet = true;
        }
        
        ofPushMatrix();
        ofTranslate(screenX, screenY);
        ofRotate(180+(-1*imgAngle));
        
        img->draw(0, 0, r, r);
        
        ofPopMatrix();

    }
    
    void drawPathHead() {
        
        if (playing && pathPointsIndex > 0 && pathPoints.size() > 1) {
            
            int x1 = pathPoints[pathPointsIndex-1]->x;
            int y1 = pathPoints[pathPointsIndex-1]->y;
            int x2 = pathPoints[pathPointsIndex]->x;
            int y2 = pathPoints[pathPointsIndex]->y;
            
            targetPathHeadAngle = ofRadToDeg(atan2(x2-x1, y2-y1));
        
            
            float angleDiff = targetPathHeadAngle - pathHeadAngle;
            if (fabs(angleDiff) > 1) {
                pathHeadAngle += angleDiff / 2;
            }
            
            int x = canvasX + pathPoints[pathPointsIndex]->x; // actual canvas position
            int y = canvasY + pathPoints[pathPointsIndex]->y;
            x = (x - screenPosX) * zoom;                      // screen position
            y = (y - screenPosY) * zoom;
            
            float d = PATHHEADRADIUS * 2 * zoom;
            
            ofPushMatrix();
            ofTranslate(x, y);
            ofRotate(180+(-1*pathHeadAngle));
            
            pathHeadImg.draw(0, 0, d, d);
            
            ofPopMatrix();
        }
    }
    void movePathHeadAndPlayBells() {
        if (pathPoints.size() > 1) {
            float t = ofGetElapsedTimef() - playBackStartTime;
            float nextTime = pathPoints[pathPointsIndex]->t;
            
            // the do while loop advances the path head until it reaches the current time
            // this is necessary so that it can catch up if the framerate at playback is
            // lower than at the time it was recorded (prevents laggy playback)
            while (t > nextTime) {
                playBells();
                
                if (BellTheHeadIsTouching == myself) {
                    return; // otherwise we get trapped in this loop
                }
                
                pathPointsIndex++;
                                
                if (pathPointsIndex >= pathPoints.size() - 1) {
                    playing = false;
                    return;
                }

                nextTime = pathPoints[pathPointsIndex]->t;
                
            } 
        }
    }
    
//    void updatePathHeadLocation() {
//        float t = ofGetElapsedTimef() - playBackStartTime;
//        
//        float nextTime = 0;
//        if (pathPoints.size() > 1) {
//            nextTime = pathPoints[pathPointsIndex]->t;
//            if (t > nextTime) {
//                pathPointsIndex++;
//                if (pathPointsIndex >= pathPoints.size() - 1) {
//                    playing = false;
//                }
//            }
//        }
//    }

    
    void playBells() {
        // play any bells we are touching
        
        if (pathPoints.size() == 0) {
            return;
        }
        if (pathPointsIndex >= pathPoints.size()) {
            return;
        }
        
        int pathHeadCanvasX = canvasX + pathPoints[pathPointsIndex]->x;
        int pathHeadCanvasY = canvasY + pathPoints[pathPointsIndex]->y;
        
        bool touchFlag = false;
        for (int i=0; i<bells->size(); i++) {
            if (ofDist(pathHeadCanvasX, pathHeadCanvasY, (*bells)[i]->getCanvasX(), (*bells)[i]->getCanvasY()) < BELLRADIUS) {
                touchFlag = true;
                
                // prevent triggering right away if the head starts on the player
                if (((*bells)[i] == myself) && pathPointsIndex == 0) {
                    BellTheHeadIsTouching = myself;
                }
                
                // if we're not already touching this one, play it
                if (BellTheHeadIsTouching != (*bells)[i]) {
                    (*bells)[i]->playNote();
                    BellTheHeadIsTouching = (*bells)[i];
                }
                
                // if it's us, trigger again since we just toggled ourself off
                if (BellTheHeadIsTouching == myself) {
                    playNote();
                }
            }
        }
        if (!touchFlag) {
            BellTheHeadIsTouching = nil;
        }

    }
    
    void addPoint(int _x, int _y) {
        int x = _x - canvasX; // convert to relative coords for storage
        int y = _y - canvasY;

        // prevent the path from starting inside player img
        if (pathPoints.size() == 0) {
            float dist = ofDist(_x, _y, canvasX, canvasY);
            if (dist < PATHPLAYERRADIUS) {
                drawingStartTime = ofGetElapsedTimef();
                return;
            }
        }
        
        // the finger must travel at least a few pixels before we add a new point
        if (pathPoints.size() > 0) {
            float dist = ofDist(x, y, pathPoints.back()->x, pathPoints.back()->y);
            if (dist < 5) {
                //cout << dist << endl;
                return;
            }
        }
        
        float t = ofGetElapsedTimef() - drawingStartTime;
        PathPoint *p = new PathPoint(x, y, t);
        pathPoints.push_back(p);
        box->update(_x, _y); // update bounding box using canvas coords
    }
    
    void playNote() {
		currentRadius = RECBELLRADIUS + 25;

        if (!playing) {
            playing = true;
            playBackStartTime = ofGetElapsedTimef();
            pathPointsIndex = 0;
            pathHeadAngle = 0;
            targetPathHeadAngle = 0;
        } else {
            playing = false;
        }
        
    }
    bool isPathPlayer() {
		return true;
	}
    
    vector <PathPoint *> getPathPoints() {
        return pathPoints;
    }
    
    void setPathPoints(vector <PathPoint *> _pathPoints) {
        for (int i=0; i<_pathPoints.size(); i++) {
            float x = _pathPoints[i]->x;
            float y = _pathPoints[i]->y;
            float t = _pathPoints[i]->t;
            
            PathPoint *p = new PathPoint(x, y, t);
            pathPoints.push_back(p);
            
            box->update(canvasX + x, canvasY + y); // we store relative coords, but update box using canvas coords
        }
    }
};


#endif
