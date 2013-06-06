//
//  PathPoint.cpp
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 6/5/13.
//
//

class PathPoint {
	
public:
	
	int x;
	int y;
    float t;
	
	PathPoint(int _x, int _y, float _t) {
		x = _x;
		y = _y;
        t = _t;
	}
};