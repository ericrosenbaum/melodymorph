//
//  BoundingBoxForLine.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 6/5/13.
//
//

#ifndef MelodyMorph_BoundingBoxForLine_h
#define MelodyMorph_BoundingBoxForLine_h

class BoundingBoxForLine {
	
public:

    int top, bottom, left, right;
    bool initialized;
    int anchorX, anchorY;
    
    BoundingBoxForLine() {
        initialized = false;
    };
		
    void update(int x, int y) {
		if (!initialized) {
			top = y;
			bottom = y;
			left = x;
			right = x;
            
            anchorX = x;
            anchorY = y;

            initialized = true;
		}
		if (y < top) {
			top = y;
		}
		if (y > bottom) {
			bottom = y;
		}
		if (x < left) {
			left = x;
		}
		if (x > right) {
			right = x;
		}
        
        // prevent the bug where a straight line gives a bounding box
        // with a width or height of zero, preventing it from being detected
        // by inBox(), so e.g. it can't be erased
        if ((right - left) < 1) {
            right += 10;
        }
        if ((bottom - top) < 1) {
            bottom += 10;
        }
    }
    
    void moveAnchorPointTo(int x, int y) {
        if (initialized) {
            int diffX = anchorX - x;
            int diffY = anchorY - y;
            
            left -= diffX;
            right -= diffX;
            top -= diffY;
            bottom -= diffY;

            anchorX = x;
            anchorY = y;
        }
    }
    
    bool isOnScreen(int screenPosX, int screenPosY, float zoom) {
		if (((right - screenPosX) * zoom) < 0) {
			return false;
		}
		if (((left - screenPosX) * zoom) > ofGetWidth()) {
			return false;
		}
		if (((top - screenPosY) * zoom) > ofGetHeight()) {
			return false;
		}
		if (((bottom - screenPosY) * zoom) < 0) {
			return false;
		}
		return true;
	}
	
	bool inBox(int canvasX, int canvasY) {
		if (canvasX > left) {
			if (canvasX < right) {
				if (canvasY > top) {
					if (canvasY < bottom) {
						return true;
					}
				}
			}
		}
		return false;
	}

};

#endif
