/*
 *  DrawingLine.cpp
 *  MelodyMorph
 *
 *  Created by Eric Rosenbaum on 6/2/11.
 *  Copyright 2011 MIT. All rights reserved.
 *
 */

#include "ofMain.h"
#include "Point2D.cpp"

class DrawingLine {
	
public:
	
	vector<Point2D*> points;
	int boxTop, boxBottom, boxLeft, boxRight;
	
	void addPoint(int x, int y) {
		points.push_back(new Point2D(x, y));
		
		// update bounding box
		if (points.size() == 1) {
			boxTop = y;
			boxBottom = y;
			boxLeft = x;
			boxRight = x;
		}
		if (y < boxTop) {
			boxTop = y;
		}
		if (y > boxBottom) {
			boxBottom = y;
		}
		if (x < boxLeft) {
			boxLeft = x;
		}
		if (x > boxRight) {
			boxRight = x;
		}
        
        // prevent the bug where a straight line gives a bounding box
        // with a width or height of zero, preventing it from being detected
        // by inBox(), so it can't be erased
        if ((boxRight - boxLeft) < 1) {
            boxRight += 10;
        }
        if ((boxBottom - boxTop) < 1) {
            boxBottom += 10;
        }
        
	}
	
	void draw(int screenPosX, int screenPosY, float zoom){
		
		if (!isOnScreen(screenPosX, screenPosY, zoom)) {
			return;
		}
		
		ofSetHexColor(0xffffff);
		
		int prevX = (points[0]->x - screenPosX) * zoom;
		int prevY = (points[0]->y - screenPosY) * zoom;
		
		for (int i=1; i<points.size(); i++) {
			int x = (points[i]->x - screenPosX) * zoom;
			int y = (points[i]->y - screenPosY) * zoom;
			ofLine(prevX, prevY, x, y);
			prevX = x;
			prevY = y;
		}
//		ofCircle((boxLeft - screenPosX) * zoom, (boxTop - screenPosY) * zoom, 1.0);
//		ofCircle((boxRight - screenPosX) * zoom, (boxTop - screenPosY) * zoom, 1.0);
//		ofCircle((boxLeft - screenPosX) * zoom, (boxBottom - screenPosY) * zoom, 1.0);
//		ofCircle((boxRight - screenPosX) * zoom, (boxBottom - screenPosY) * zoom, 1.0);

	}
	
	bool isOnScreen(int screenPosX, int screenPosY, float zoom) {
		if (((boxRight - screenPosX) * zoom) < 0) {
			return false;
		}
		if (((boxLeft - screenPosX) * zoom) > ofGetWidth()) {
			return false;
		}
		if (((boxTop - screenPosY) * zoom) > ofGetHeight()) {
			return false;
		}
		if (((boxBottom - screenPosY) * zoom) < 0) {
			return false;
		}
		return true;
	}
	
	bool inBox(int canvasX, int canvasY) {
		if (canvasX > boxLeft) {
			if (canvasX < boxRight) {
				if (canvasY > boxTop) {
					if (canvasY < boxBottom) {
						return true;
					}
				}
			}
		}
		return false;
	}
	
	vector<Point2D*> getPoints() {
		return points;
	}
};
