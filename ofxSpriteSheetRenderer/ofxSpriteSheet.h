
#ifndef OFX_SPRITE_SHEET
#define OFX_SPRITE_SHEET

#include "ofMain.h"
#include <map>

// ---
class spriteType{
    
    public:
        spriteType(){
            position.x = 0.0;
            position.y = 0.0;
            position.z = 0.0;
            anchorOffset = position;
            anchorPosition = position;
            angle = 0.0;
            numFrames = 0;
            currentFrame = 0;
        }
        void addTextureFrame(int x, int y, int w, int h){
            ofRectangle temp;
            temp.x = x;
            temp.y = y;
            temp.width = w;
            temp.height = h;
            frameTextures.push_back( temp );
            numFrames = frameTextures.size();
        }
        string      name;
        ofVec3f     position;
        ofVec3f     anchorOffset;
        ofVec3f     anchorPosition;
        int         meshIndex;
        int         width;
        int         height;
        float       angle;
    
        int         numFrames;
        int         currentFrame;
        vector      <ofRectangle> frameTextures;
    
};

// ---

typedef std::map<std::string, spriteType> spriteLists;

// ---

class ofxSpriteSheet{
	public:
		ofxSpriteSheet();
	
        void draw();
        void drawDebug();

        void loadImage(string file);
    
        void addSprite(string name, int x, int y, int w, int h);
        void addTextureFrame(string name, int x, int y, int w, int h);
    
        void setPosition(string name, int x, int y);
        void setAnchorPoint(string name, int x, int y);
        void setAngle(string name, float tangle);
    
        int getNumFrames(string name);
        int getCurrentFrame(string name);
        void changeFrame(string name, int n);
    
    protected:
    
        void addPoint(int x, int y);
        void movePoint(int tindex, int x, int y);
        void refreshAnchor(string name);
    
        spriteLists sprites;
        ofMesh      mesh;
        ofTexture   texture;
    
        vector <ofVec3f> verticesNow;
        vector <ofVec3f> verticesOrigin;
    
    
        int         imageWidth;
        int         imageHeight;
    
        int         index;
	
};

#endif