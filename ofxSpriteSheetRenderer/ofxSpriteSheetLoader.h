
#ifndef OFX_SPRITE_SHEET_LOADER
#define OFX_SPRITE_SHEET_LOADER

#include "ofMain.h"

#include "ofxXmlSettings.h"

class ofxSpriteSheetLoader:public ofxXmlSettings{
	public:
		ofxSpriteSheetLoader();
	

        void loadFromTexturePackerXml(string file);
    
	
	
};

#endif