

#include "ofxSpriteSheet.h"

// --------------------------------------------------------------------------------------
ofxSpriteSheet::ofxSpriteSheet() {
    
    mesh.setMode( OF_PRIMITIVE_TRIANGLES );
    
    index = 0;
    
    verticesNow.clear();
    verticesOrigin.clear();
    
}

// --------------------------------------------------------------------------------------
void ofxSpriteSheet::draw(){
    
    
    // draw mesh with texture
    ofEnableAlphaBlending();
	ofSetColor(255, 255, 255);
    
	texture.bind();
	mesh.draw();

	texture.unbind();
    
    ofDisableAlphaBlending();
    
}

// --------------------------------------------------------------------------------------
void ofxSpriteSheet::drawDebug(){
    
    // draw wireframes for debug
    ofNoFill();
    ofSetColor(255, 255, 255);
	mesh.drawWireframe();
    ofSetColor(255, 0, 0);
    mesh.drawVertices();
    
    //
    map<string, spriteType>::iterator it;
    for(it = sprites.begin(); it != sprites.end(); ++it){
        string name = it->first;
        
        ofSetColor(255,0,0);
		ofCircle(sprites[name].position.x, sprites[name].position.y, 10);
        ofSetColor(100,0,255);
        ofCircle(sprites[name].anchorPosition.x, sprites[name].anchorPosition.y, 10);
    }
    
    
}
// --------------------------------------------------------------------------------------
void ofxSpriteSheet::loadImage(string file){   
    
    // load image
    ofImage loader;
    loader.setUseTexture(false);
    loader.loadImage(file);
    
    // store width & height
    imageWidth = loader.getWidth();
    imageHeight = loader.getHeight();
    
    // allocate texture & copy in data
    texture.allocate(imageWidth, imageHeight, GL_RGBA);
    texture.loadData(loader.getPixels(), imageWidth, imageHeight, GL_RGBA);
    
    // clear temp image
    loader.clear();

    
}

// --------------------------------------------------------------------------------------
void ofxSpriteSheet::addSprite(string name, int x, int y, int w, int h){
    
    // first create the vertices, text coords & mesh colors
    
    // triangle 1
    addPoint(x, y); // top-left
    
    addPoint(x+w, y); // top-right
    
    addPoint(x, y+h); // bottom-left
    
    // triangle 2
    addPoint(x+w, y); // top-right
    
    addPoint(x, y+h); // bottom-left
    
    addPoint(x+w, y+h); // bottom-right
 
    // create a new spriteType object using name as a reference
    sprites.insert( pair<std::string, spriteType>(name, spriteType()) );
    
    // store the name within the object for future use
    sprites[name].name = name;
    
    // temp, set position
    sprites[name].position.x = x;
    sprites[name].position.y = y;
    sprites[name].width = w;
    sprites[name].height = h;
    
    sprites[name].addTextureFrame(x, y, w, h);
    
    // store first index (in vertice/textcoord/color) within object for future use
    sprites[name].meshIndex = index;

    // add 6 to current index position
    // 2 triangles, 3 points each
    index += 6;
    
}
// -----------------------------------------
void ofxSpriteSheet::addTextureFrame(string name, int x, int y, int w, int h){
    
    sprites[name].addTextureFrame(x, y, w, h);    
    
}
// -----------------------------------------
void ofxSpriteSheet::addPoint(int x, int y){
    
    // vertex
    ofVec3f v;
    v.x = x;
    v.y = y;
    v.z = 0;
    mesh.addVertex(v);
    
    verticesNow.push_back(v);
    verticesOrigin.push_back(v);

    // text coord
    ofVec2f t;
    t.x = x / (float)imageWidth;
    t.y = y / (float)imageHeight;
    mesh.addTexCoord(t);
    
    // color
    ofFloatColor c;
    c.set(255.0, 255.0, 255.0);
    mesh.addColor( c );
    
}

// -----------------------------------------
void ofxSpriteSheet::setPosition(string name, int x, int y){
    
    sprites[name].position.x = x;
    sprites[name].position.y = y;
    
    int w = sprites[name].width;
    int h = sprites[name].height;
    
    // first index    
    int thisIndex = sprites[name].meshIndex;
    
    // triangle 1 update ----
    
    // top left
    movePoint(thisIndex, sprites[name].position.x, sprites[name].position.y);
    
    // top right    
    movePoint(thisIndex+1, sprites[name].position.x+w, sprites[name].position.y);
    
    // bottom left
    movePoint(thisIndex+2, sprites[name].position.x, sprites[name].position.y+h);
    
    // triangle 2 update ----
    
    // top right 
    movePoint(thisIndex+3, sprites[name].position.x+w, sprites[name].position.y);
    
    // bottom left
    movePoint(thisIndex+4, sprites[name].position.x, sprites[name].position.y+h);
    
    // bottom right
    movePoint(thisIndex+5, sprites[name].position.x+w, sprites[name].position.y+h);
    
    refreshAnchor(name);
    
    
}
// -----------------------------------------
void ofxSpriteSheet::movePoint(int tindex, int x, int y){
    
    ofVec3f tv;
    
    tv.x = (float)x;
    tv.y = (float)y;
    
    mesh.setVertex(tindex, tv);
    
    verticesNow[tindex] = tv;
    verticesOrigin[tindex] = tv;
    
    
}
// -----------------------------------------
void ofxSpriteSheet::setAnchorPoint(string name, int x, int y){
    
    sprites[name].anchorOffset.x = (float)x;
    sprites[name].anchorOffset.y = (float)y;
    
}
// -----------------------------------------
void ofxSpriteSheet::refreshAnchor(string name){
    
    sprites[name].anchorPosition = sprites[name].position + sprites[name].anchorOffset;
    
}
// -----------------------------------------
void ofxSpriteSheet::setAngle(string name, float tangle){
    
    // store angle
    sprites[name].angle = tangle;
    
    // first index    
    int thisIndex = sprites[name].meshIndex;
    
    // angle rotation point
    ofVec3f anchor = sprites[name].anchorPosition;
    
    for(int i=0; i<6; i++){
        
        int tindex = thisIndex + i;
        
        ofVec3f tempvec = verticesOrigin[tindex];//mesh.getVertex(tindex);
        
        tempvec.rotate(tangle, anchor, ofVec3f(0,0,1));
        
        //ofVec3f newvec = tempvec.getRotated(tangle, ofVec3f(0,0,1));
        
        mesh.setVertex(tindex, tempvec);
    }
    
}
// -----------------------------------------
int ofxSpriteSheet::getNumFrames(string name){
    return sprites[name].numFrames;
}
// -----------------------------------------
int ofxSpriteSheet::getCurrentFrame(string name){
    return sprites[name].currentFrame;
}
// -----------------------------------------
void ofxSpriteSheet::changeFrame(string name, int n){
    
    int numframes = sprites[name].numFrames;
    int firstIndex = sprites[name].meshIndex;
    
    int thisFrame = n;
    
    ofVec2f t;
    
    // change texture coords 
    
    // triangle 1 update ----

    // top left
    t.x = sprites[name].frameTextures[thisFrame].x / (float)imageWidth;
    t.y = sprites[name].frameTextures[thisFrame].y / (float)imageHeight;
    mesh.setTexCoord(firstIndex+0, t);
    
    // top right    
    t.x = (sprites[name].frameTextures[thisFrame].x+sprites[name].width) / (float)imageWidth;
    t.y = sprites[name].frameTextures[thisFrame].y / (float)imageHeight;
    mesh.setTexCoord(firstIndex+1, t);

    // bottom left
    t.x = sprites[name].frameTextures[thisFrame].x / (float)imageWidth;
    t.y = (sprites[name].frameTextures[thisFrame].y+sprites[name].height) / (float)imageHeight;
    mesh.setTexCoord(firstIndex+2, t);

    // triangle 2 update ----
    
    // top right
    t.x = (sprites[name].frameTextures[thisFrame].x+sprites[name].width) / (float)imageWidth;
    t.y = (sprites[name].frameTextures[thisFrame].y / (float)imageHeight);
    mesh.setTexCoord(firstIndex+3, t);

    // bottom left
    t.x = sprites[name].frameTextures[thisFrame].x / (float)imageWidth;
    t.y = (sprites[name].frameTextures[thisFrame].y+sprites[name].height) / (float)imageHeight;
    mesh.setTexCoord(firstIndex+4, t);
 
    // bottom right
    t.x = (sprites[name].frameTextures[thisFrame].x+sprites[name].width) / (float)imageWidth;
    t.y = (sprites[name].frameTextures[thisFrame].y+sprites[name].height) / (float)imageHeight;
    mesh.setTexCoord(firstIndex+5, t);

    // update current frame number
    sprites[name].currentFrame = thisFrame;
        
    
}
