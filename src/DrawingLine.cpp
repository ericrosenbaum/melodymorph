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
#include "BoundingBoxForLine.h"

class DrawingLine {
	
public:
	
	vector<Point2D*> points;
    BoundingBoxForLine *boundingBox;
    
    DrawingLine() {
        boundingBox = new BoundingBoxForLine();
    };
	
	void addPoint(int x, int y) {
		points.push_back(new Point2D(x, y));
		boundingBox->update(x,y);
	}
	
	void draw(int screenPosX, int screenPosY, float zoom){
		
		if (!boundingBox->isOnScreen(screenPosX, screenPosY, zoom)) {
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

        // draw the corners, for debugging
//      ofCircle((boundingBox->left - screenPosX) * zoom, (boundingBox->top - screenPosY) * zoom, 1.0);
//		ofCircle((boundingBox->right - screenPosX) * zoom, (boundingBox->top - screenPosY) * zoom, 1.0);
//		ofCircle((boundingBox->left - screenPosX) * zoom, (boundingBox->bottom - screenPosY) * zoom, 1.0);
//		ofCircle((boundingBox->right - screenPosX) * zoom, (boundingBox->bottom - screenPosY) * zoom, 1.0);

	}
		
	vector<Point2D*> getPoints() {
		return points;
	}
};
