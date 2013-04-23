// melodymorph 
//
// ssh ericr@melodymorph2.xvm.mit.edu
// nohup python manage.py runserver 0.0.0.0:8080
//
// now we are on github yay

/*
 
 app
 
 timestamp.xml
 smallThumbImage_timestamp.png
 largeThumbImage_timestamp.png

 server
 
 xmlfiles/uuid.xml
 small-thumbs/sm_uuid.xml
 large-thumbs/lg_uuid.xml
 
 app shared dir
 
 uuid.xml
 sm_uuid.xml
 lg_uuid.xml
 
 
SHOULD BE THIS
 
 sorting will work
 no more renaming in the app
 one thumbnail only
 
 app
 
 local-timestamp.xml
 local-timestamp.png
 
 server
 
 server-timestamp.xml
 server-timestamp.png
 
 shared
 
 server-timestamp.xml
 server-timestamp.png
 
 *******
 
 paths are used in a few different ways:
 
 local user XML files - full documents path
 local example XML files - examples/ path
 
 morph vectors for user, example and shared tabs
    user and example are loaded from their XML files
    shared paths come from database entries
 
 database entry on server
    points to database file system, which has xml and png folders
        so it's different from local file system paths!
 
 ***
 
 so maybe I should only store an id, which is the timestamp, same as filename
 this would mean XML files have ids stored inside which are the same as their filename
 and then construct paths with concatenation as needed
 this also requires a field in the XML and in the morph for user/example/shared
 
*/

#ifndef _TESTAPP_ER
#define _TESTAPP_ER

#include "testApp.h"
#include "DrawingLine.cpp"
#include "RecorderBell.mm"
#include "topButtons.h"
#include "RecorderBellMaker.h"
#include "LoadFileViewController.h"
#include "ControlPanel.h"
#include "controlPanelToggle.h"
#include "DrawingToggle.h"
#include "utils.h"
#include "BrowserViewController.h"
#include "QuasiModeSelectorCanvas.h"
#include "SegmentedControl.h"
#include "OctaveButtons.h"

vector<Bell*> bells;
vector<MultiSampledSoundPlayer *> instrumentSoundPlayers;
vector<string> instrumentNames;
int numInstruments;

int currentChannel[3];
int currentInstrument;

float palettePositions[NUMNOTES];
int paletteXPos;
float touchPrevX, touchPrevY;
bool draggingCanvas;
int draggingCanvasId;
bool draggingMinimap;
int draggingMinimapId;
float screenPosX, screenPosY;
ofxXmlSettings XML;

float forceBuffer[FORCEBUFFERLENGTH];
int forceBufferIndex;
float forceEstimate;

bool touchesDown[MAXTOUCHES];
int numTouches;
float zoom;
int touchesX[MAXTOUCHES];
int touchesY[MAXTOUCHES];

float prevPinchDist;
float pinchStartDist;
float zoomStart;
bool zooming;
bool zoomBegun;

ofPoint selectionStartCorner;
ofPoint selectionDragCorner;

int octave;

vector<vector<ofImage> > bellImageTriplets;

ofImage recBellImage;
ofImage paletteBack;

bool recording;

float mapWidth;
float mapHeight;
float mapXOffset;
float mapYOffset;	

bool showAllNotes;
bool showNoteNames;

bool drawingOn;
bool erasingOn;
vector<DrawingLine*> drawingLines;

bool slideModeOn;

//PGMidi	*midi;

// http

//ofxHttpUtils httpUtils;
string uploadURL;

vector<MorphMetaData> exampleMorphsMetaData;
vector<MorphMetaData> userMorphsMetaData;
vector<MorphMetaData> sharedMorphsMetaData;

// play mode widgets

QuasiModeSelectorCanvas *quasiModeSelectorCanvas;
SegmentedControl *instrumentSelector;
OctaveButtons *octaveButtons;

// load menu

ofxUICanvas *loadMenuCanvas;
ofxUIMorphCanvas *examplesLoadMenuCanvas;
ofxUIMorphCanvas *userLoadMenuCanvas;
ofxUIMorphCanvas *sharedLoadMenuCanvas;
ofxUICanvas *cancelButtonCanvas;
ofxUILabelButton *cancelButton;
int touchUpX = 0;
int touchUpY = 0;
ofxUILabelToggle *examplesTabLabelToggle;
ofxUILabelToggle *userTabLabelToggle;
ofxUILabelToggle *sharedTabLabelToggle;

ofxUILabelButton *descriptionLabel;
ofxTextBlock descriptionTextView;
ofxTextBlock authorTextView;
ofxTextBlock titleTextView;

ofxUILabelButton *previousButton;
ofxUILabelButton *nextButton;

ofImage largeThumbImageForLoading;

// save dialog
ofxUICanvas *saveDialogCanvas;
ofxiPhoneKeyboard *titleKeyboard;
ofxiPhoneKeyboard *authorKeyboard;
ofxiPhoneKeyboardWrapping *descriptionKeyboard;

ofImage largeThumbImageForSaving;

// native UI widgets

TopButtons *topButtons;
ControlPanel *controlPanel;
ControlPanelToggle *controlPanelToggle;
RecorderBellMaker *recorderBellMaker;
LoadFileViewController *loadView;
DrawingToggle *drawingToggle;
BrowserViewController *browser;

// UI mode
// current mode of the UI (#defines are in config.h):
// PLAY_MODE, LOAD_MENU_MODE, PRE_SAVE_MODE, SAVE_DIALOG_MODE
int UIMode;

// current load menu tab
// which of the tabs in the load menu is currently open:
// EXAMPLES_TAB, USER_TAB, SHARED_TAB
int currentLoadMenuTab;

////////////////
// OF events
////////////////

//--------------------------------------------------------------
void testApp::setup(){
        
    UIMode = PLAY_MODE;
    
    ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
    
	ofEnableAlphaBlending();
    
    setupInstruments();
    
	// compute palette positions
	float inc = (768 - 100) / (float)(NUMNOTES+1);
	int x = inc + 55 + 128;
	for (int i=0; i<NUMNOTES; i++) {
		palettePositions[i] = x;
		x += inc;
	}
	
	screenPosX = SCREENSTARTPOSX;
	screenPosY = SCREENSTARTPOSY;
	
	paletteXPos = 0;
	
	showAllNotes = false;
	showNoteNames = false;
    
    // build menus
    
    buildLoadMenu();
    buildSaveDialog();
       
    ///////////////////////////////////
    
	// accelerometer stuff for tap force sensing
	ofxAccelerometer.setup();
	for (int i=0; i<FORCEBUFFERLENGTH; i++) {
		forceBuffer[i] = 0;
	}
	forceBufferIndex = 0;
	forceEstimate = 0;
	
	for (int i=0; i<MAXTOUCHES; i++) {
		touchesDown[i] = false;
	}
	numTouches = 0;
	
	zoom = 1;
	prevPinchDist = 0;
	pinchStartDist = 0;
	zooming = false;
    zoomBegun = false;
	zoomStart = zoom;
	draggingCanvas = false;
	draggingMinimap = false;
		
	loadBellImages();
	recBellImage.loadImage("rec-bell-image/rec_bell.png");
	
	recording = false;
    
	//setupMiniMap();
	  
    // MIDI
    // check that the device we're loading the app onto actually supports CoreMIDI
//	IF_IOS_HAS_COREMIDI
//    (
//     midi = [[PGMidi alloc] init];
//     [midi enableNetwork:YES];
//    )
    
    
    // native UI components
    
     // control panel
     controlPanel = [[ControlPanel alloc] initWithNibName:@"ControlPanel" bundle:nil];
     [[[UIApplication sharedApplication] keyWindow] addSubview:controlPanel.view];
    // CGRect r = CGRectMake(ofGetHeight()-150, ofGetWidth() - 410, 140, 300);
     CGRect r = CGRectMake(ofGetHeight()-250, ofGetWidth() - 350, 300, 140); // apparently x and y are swapped (but not for of)
     controlPanel.view.frame = r;
     [controlPanel.view setHidden:YES];
     controlPanel.view.transform = CGAffineTransformMakeRotation(ofDegToRad(-90));
    
     // control panel toggle
     controlPanelToggle = [[ControlPanelToggle alloc] initWithNibName:@"ControlPanelToggle" bundle:nil];
     [[[UIApplication sharedApplication] keyWindow] addSubview:controlPanelToggle.view];
     r = CGRectMake(ofGetHeight()-100, ofGetWidth() - 100, 100, 100);
     controlPanelToggle.view.frame = r;
        
     // recorder bell maker
     recorderBellMaker = [[RecorderBellMaker alloc] initWithNibName:@"RecorderBellMaker" bundle:nil];
     //[ofxiPhoneGetGLView() addSubview:recorderBellMaker.view];
     [[[UIApplication sharedApplication] keyWindow] addSubview:recorderBellMaker.view];
     r = CGRectMake(ofGetHeight() - 130, 10, 130, 130);
     recorderBellMaker.view.frame = r;
    
    
    // web view
    
//    browser = [[BrowserViewController alloc] initWithNibName:@"BrowserViewController" bundle:nil];
//    [[[UIApplication sharedApplication] keyWindow] addSubview:browser.view];
    
    // play mode widgets
    
    quasiModeSelectorCanvas = new QuasiModeSelectorCanvas(0, 100, 100, 400);
    quasiModeSelectorCanvas->autoSizeToFitWidgets();
    
    instrumentSelector = new SegmentedControl(0,0,ofGetWidth(),100);
    instrumentSelector->initWithNames(instrumentNames);
    setInstrument(numInstruments-1);
    instrumentSelector->setSelectedIndex(currentInstrument);
    
    octaveButtons = new OctaveButtons(128, 35, 768, 80);
    
}

//--------------------------------------------------------------
void testApp::update(){
}

//--------------------------------------------------------------
void testApp::draw(){
	
	calculateForce();

    ofBackground(50, 50, 50);

    if ((UIMode == PLAY_MODE) || (UIMode == PRE_SAVE_MODE)) {
        float bendAmt = bend();
        
        drawGrid();
        drawSelection();
        
        for (int i=0; i<drawingLines.size(); i++) {
            drawingLines[i]->draw(screenPosX, screenPosY, zoom);
        }
        for (int i=0; i<bells.size(); i++) {
            bells[i]->draw(screenPosX, screenPosY, zoom, forceEstimate, bendAmt, showNoteNames);
        }
    }
    
    // if we are in pre-save mode, we are about to create the thumbnail, so do not draw the palette
    if (UIMode == PLAY_MODE) {
        drawPalette();
    }
    
    // in pre-save mode, create the thumbnails, then switch to save dialog mode
    if (UIMode == PRE_SAVE_MODE) {
        largeThumbImageForSaving.grabScreen(0,0,ofGetWidth(),ofGetHeight());
        largeThumbImageForSaving.resize(400,300);
        
        enterUIMode(SAVE_DIALOG_MODE);
    }
    
    if (UIMode == LOAD_MENU_MODE) {
        ofxUIRectangle *rect = descriptionLabel->getRect();
        int x = rect->getX() + 110;
        int y = rect->getY();
        descriptionTextView.draw(x, y);
        authorTextView.draw(x, y - 40);
        titleTextView.draw(x, y - 80);
    }
}

//--------------------------------------------------------------
float testApp::bend(){
	float yForce = ofxAccelerometer.getForce().y;
	float forceEst = ofMap(yForce, -1, 1, 1.2, 0.8);
	return(ofClamp(forceEst, 0.8, 1.2));
}
//--------------------------------------------------------------
void testApp::calculateForce(){
	float zForce = ofxAccelerometer.getForce().z;
	forceBuffer[forceBufferIndex] = zForce;
	forceBufferIndex++;
	forceBufferIndex %= FORCEBUFFERLENGTH;
	
	float min = forceBuffer[0];
	for (int i=0; i<FORCEBUFFERLENGTH; i++) {
		if (forceBuffer[i] < min) {
			min = forceBuffer[i];
		}
	}
	float max = forceBuffer[0];
	for (int i=0; i<FORCEBUFFERLENGTH; i++) {
		if (forceBuffer[i] > max) {
			max = forceBuffer[i];
		}
	}
	float prevEstimate = forceEstimate;
	forceEstimate = max - min;
	if (forceEstimate < prevEstimate) {
		forceEstimate = (prevEstimate * 0.9) + (forceEstimate * 0.1);
	}
	
	//forceEstimate = ((max - min) + .9*forceEstimate)/1.9;
	//forceEstimate = (((max - min) * .1) + (forceEstimate * 0.9)) / 2.0f;  
	//forceEstimate *= forceEstimate;
}
//--------------------------------------------------------------
void testApp::setupMiniMap(){
	float mapScale = MINIMAPSCALE;
	mapWidth = CANVASWIDTH * mapScale;
	mapHeight = CANVASHEIGHT * mapScale;
	mapXOffset = ofGetWidth() - mapWidth - 5;
	mapYOffset = ofGetHeight() - mapHeight - 5;	
}
//--------------------------------------------------------------
void testApp::drawMiniMap(){
	float mapScale = MINIMAPSCALE;
	float mapScreenWidth = ofGetWidth() * mapScale / zoom;
	float mapScreenHeight = ofGetHeight() * mapScale / zoom;
	
	ofSetColor(100, 100, 100);
	ofRect(mapXOffset, mapYOffset, mapWidth, mapHeight);
	
	for (int i=0; i<bells.size(); i++) {
		int rgb[3];
		if (bells[i]->isRecorderBell()) {
			setColorHSV(0, 0, 1, rgb);
		} else {	
			setColorHSV(bells[i]->getHue(), 1, 1, rgb);
		}
		float x = bells[i]->getCanvasX() * mapScale + mapXOffset;
		float y = bells[i]->getCanvasY() * mapScale + mapYOffset;
		ofCircle(x, y, BELLRADIUS * mapScale);
	}
	
	ofSetColor(255, 255, 255);
	ofNoFill();
	float mapScreenX = screenPosX * mapScale + mapXOffset;
	float mapScreenY = screenPosY * mapScale + mapYOffset;
	ofRect(mapScreenX, mapScreenY, mapScreenWidth, mapScreenHeight);
	ofFill();
}
//--------------------------------------------------------------
void testApp::drawGrid(){
    ofSetColor(55);
    int gridSpacing = 240;
    int numColumns = 2 + int(((1024 + gridSpacing) / zoom) / gridSpacing);
    int numRows = 2 + int(((768 + gridSpacing) / zoom) / gridSpacing);
    
    for (int i=0; i<numColumns; i++) {
        for (int j=0; j<numRows; j++) {
            int colNum = int(screenPosX / gridSpacing) + i - 1;
            int rowNum = int(screenPosY / gridSpacing) + j - 1;
            int x = ((colNum*gridSpacing)-screenPosX) * zoom;
            int y = ((rowNum*gridSpacing)-screenPosY) * zoom;
            
            // checkerboard pattern
            int c = abs(colNum);
            int r = abs(rowNum);
            if ((c%2==0 && r%2==1) || (c%2==1 && r%2==0))  {
                ofRect(x,y,gridSpacing*zoom,gridSpacing*zoom);
            }
        }
    }
}
//--------------------------------------------------------------
void testApp::drawSelection(){
    if (quasiModeSelectorCanvas->getCurrentMode() == SELECT_MODE) {
        
        float startX = (selectionStartCorner.x - screenPosX) * zoom;
        float startY = (selectionStartCorner.y - screenPosY) * zoom;
        float endX = (selectionDragCorner.x - screenPosX) * zoom;
        float endY = (selectionDragCorner.y - screenPosY) * zoom;
        
        ofSetColor(255, 255, 0, 20);
        ofRect(startX, startY, endX-startX, endY-startY); // x, y, w, h
    }
}
//--------------------------------------------------------------
void testApp::drawPalette(){
	
    // background rectangle
    ofSetColor(128, 128, 128);
    roundedRect(128, 35, 768, 80, 10);
        
	ofSetHexColor(0xffffff);
    
	int paletteYPos = 75;
	float targetXPos = 0;
	if (octaveButtons->getOctave() == 0) {
		targetXPos = 768;
	} 
	if (octaveButtons->getOctave() == 2) {
		targetXPos = 768 * -1;
	}
	paletteXPos += (targetXPos - paletteXPos) / 10; 
	paletteXPos = round(paletteXPos);
	
	for (int oct = 0; oct<3; oct++) { 
		float xOffset = 0;
		if (oct == 0) {
			xOffset = -768;
		}
		if (oct == 2) {
			xOffset = 768;
		}
		
		float saturation = 1;
		float brightness = 1;
		if (oct == 0) {
			brightness = LOWOCTBRIGHTNESS;
		}
		if (oct == 2) {
			saturation = HIGHOCTSATURATION;
		}
		
		for (int i=0; i<NUMNOTES; i++) {
			int function = noteFunctions(i);
			if (!showAllNotes && function == 2) {
				continue;
			} else {
				float hue = i / (float)NUMNOTES;
				int rgb[3];
				setColorHSV(hue, saturation, brightness, rgb);
				int yOffset = 0;
				float diam = 40;
				if (function == 2) {
					yOffset = -10; 
					diam = 30;
				}
				float xPos = palettePositions[i] + xOffset + paletteXPos;
				if ((xPos < (768 + 128 - 55)) && (xPos > (128 + 55))) {
                    bellImageTriplets[currentInstrument][function].setAnchorPercent(0.5, 0.5);
                    bellImageTriplets[currentInstrument][function].draw(xPos,paletteYPos + yOffset, diam, diam);
					if (showNoteNames) {
						ofSetHexColor(0x000000);
						ofDrawBitmapString(noteNames(i), xPos+1-4, paletteYPos + yOffset+1+3);
						ofSetHexColor(0xffffff);
						ofDrawBitmapString(noteNames(i), xPos-4, paletteYPos + yOffset+3);
					}
					
				}
			}
		}
	}
	 
}
//--------------------------------------------------------------
void testApp::roundedRect(float x, float y, float w, float h, float r) {
    ofBeginShape();
    ofVertex(x+r, y);
    ofVertex(x+w-r, y);
    quadraticBezierVertex(x+w, y, x+w, y+r, x+w-r, y);
    ofVertex(x+w, y+h-r);
    quadraticBezierVertex(x+w, y+h, x+w-r, y+h, x+w, y+h-r);
    ofVertex(x+r, y+h);
    quadraticBezierVertex(x, y+h, x, y+h-r, x+r, y+h);
    ofVertex(x, y+r);
    quadraticBezierVertex(x, y, x+r, y, x, y+r);
    ofEndShape();
}
//--------------------------------------------------------------
void testApp::quadraticBezierVertex(float cpx, float cpy, float x, float y, float prevX, float prevY) {
    float cp1x = prevX + 2.0/3.0*(cpx - prevX);
    float cp1y = prevY + 2.0/3.0*(cpy - prevY);
    float cp2x = cp1x + (x - prevX)/3.0;
    float cp2y = cp1y + (y - prevY)/3.0;
    
    // finally call cubic Bezier curve function
    ofBezierVertex(cp1x, cp1y, cp2x, cp2y, x, y);
}
//--------------------------------------------------------------
void testApp::setupInstruments() {
    
    ofDirectory instrumentPaths = *new ofDirectory();
    numInstruments = instrumentPaths.listDir("instruments");
    instrumentPaths.sort();
    
    for (int i=0; i<numInstruments; i++) {
        MultiSampledSoundPlayer *inst = new MultiSampledSoundPlayer();
        string path = instrumentPaths.getPath(i);
        inst->loadSamples(path);
        instrumentSoundPlayers.push_back(inst);
        
        vector<string> s = ofSplitString(path, "/");
        string name = s[1];
        instrumentNames.push_back(name);
        
        cout << "loaded instrument " + path << endl;
        
    }
}
//--------------------------------------------------------------
void testApp::loadBellImages() {
    
    ofDirectory bellImagePaths = *new ofDirectory();
    int numBellImagePaths = bellImagePaths.listDir("bell-images");
    bellImagePaths.sort();
    
    for (int i=0; i<numBellImagePaths; i++) {
        string path = bellImagePaths.getPath(i);
        ofDirectory imageDir = *new ofDirectory();
        int numImages = imageDir.listDir(path);
        
        vector<ofImage> triplet;

        for (int j=0; j<numImages; j++) {
            ofImage img;
            img.loadImage(imageDir.getPath(j));
            img.setAnchorPercent(0.5, 0.5);
            triplet.push_back(img);
        }
        
        bellImageTriplets.push_back(triplet);
        cout << "loaded " + ofToString(numImages) + " images from " + path << endl;
    }
}
//--------------------------------------------------------------
void testApp::setOctave(int oct){
	octave = oct;
}
//--------------------------------------------------------------
void testApp::setInstrument(int inst){
	currentInstrument = inst;
}
//--------------------------------------------------------------
string testApp::paddedNumberString(int num) {
    char buf[5];
    sprintf(buf, "%04d", num);
    return(ofToString(buf));
}
//--------------------------------------------------------------
void testApp::saveCanvas(bool saveToServer){

    string timestamp = ofGetTimestampString();
    
    // generate file names and paths
    string largeThumbFilePath = ofxiPhoneGetDocumentsDirectory() + timestamp + ".png";
    string XMLFilePath = ofxiPhoneGetDocumentsDirectory() + timestamp + ".xml";
    
	// save thumb image (generated in pre-save mode, inside draw())
    largeThumbImageForSaving.saveImage(largeThumbFilePath);
		
	// XML
    string title = titleKeyboard->getText();
    string author = authorKeyboard->getText();
    string description = descriptionKeyboard->getText();
    
	XML.clear();
    XML.setValue("TITLE:TEXT", title, 0);
    XML.setValue("AUTHOR:TEXT", author, 0);
    XML.setValue("DESCRIPTION:TEXT", description, 0);
	XML.setValue("THUMBPATH:LARGE", largeThumbFilePath, 0);
	XML.setValue("ZOOM:VALUE", zoom, 0);
	XML.setValue("SCREENPOS:X", screenPosX, 0);
	XML.setValue("SCREENPOS:Y", screenPosY, 0);
	for(int i=0; i<bells.size(); i++) {
		if (!bells[i]->isRecorderBell()) {
			int num = XML.addTag("BELL");
			XML.pushTag("BELL", num);
			XML.setValue("X", bells[i]->getCanvasX(), i);
			XML.setValue("Y", bells[i]->getCanvasY(), i);
			XML.setValue("NOTENUM", bells[i]->getNoteNum(), i);
			XML.setValue("OCTAVE", bells[i]->getOctave(), i);
			XML.setValue("INSTRUMENT", bells[i]->getInstrument(), i);
			XML.popTag();
		} else {
			int num = XML.addTag("RECBELL");
			XML.pushTag("RECBELL", num);
			XML.setValue("X", bells[i]->getCanvasX(), i);
			XML.setValue("Y", bells[i]->getCanvasY(), i);
		 	vector<Note *> notes = bells[i]->getNotes();
			for (int j=0; j<notes.size(); j++) {
				Note *n = notes[j];
				XML.addTag("NOTE");
				XML.setValue("NOTE:TIME", n->time, j);
				XML.setValue("NOTE:NOTE", n->note, j);
				XML.setValue("NOTE:OCTAVE", n->octave, j);
				XML.setValue("NOTE:VELOCITY", n->velocity, j);
				XML.setValue("NOTE:INSTRUMENT", n->instrument, j);
			}
			XML.popTag();
		}
	}
	
	for (int i=0; i<drawingLines.size(); i++) {
		int num = XML.addTag("LINE");
		XML.pushTag("LINE", num);
		vector<Point2D *> points = drawingLines[i]->getPoints();
		for (int j=0; j<points.size(); j++) {
			XML.addTag("P");
			XML.setValue("P:X", points[j]->x, j);
			XML.setValue("P:Y", points[j]->y, j);
		}
		XML.popTag();
	}
    	
	XML.saveFile(XMLFilePath);
    
    // upload 
    if (saveToServer) {
        MorphMetaData morph;
        
        morph.title = title;
        morph.author = author;
        morph.description = description;
        morph.xmlFilePath = XMLFilePath;
        morph.largeThumbFilePath = largeThumbFilePath;
        
        uploadMorph(morph);
    }
	
    buildLoadMenu();
}
//--------------------------------------------------------------
void testApp::saveToServer(){
    saveCanvas(true);
}
//--------------------------------------------------------------
void testApp::updateSharedLoadMenuCanvas() {
    sharedMorphsMetaData = downloadPageOfSharedMorphs(1);
    sharedLoadMenuCanvas = canvasForMenuPage(sharedMorphsMetaData, "sharedMorphButton", 1);
    loadMenuCanvas->addWidget(sharedLoadMenuCanvas);
    ofAddListener(sharedLoadMenuCanvas->newGUIEvent, this, &testApp::guiEvent);
    
}
//--------------------------------------------------------------
vector<MorphMetaData> testApp::downloadPageOfSharedMorphs(int pageNum){
    ofHttpResponse response = ofLoadURL(ofToString(BROWSE_URL) + "?page=" + ofToString(pageNum));

    //cout << "response to browse request:" << endl;
    //cout << response.data.getText() << endl;

    vector<MorphMetaData> morphs;
    
    
    XML.clear();
    XML.loadFromBuffer(response.data.getText());
    XML.pushTag("django-objects");
    int numMorphs = XML.getNumTags("object");
    if (numMorphs > 0) {
        for (int i=0; i<numMorphs; i++) {
            
            MorphMetaData morph;
            
            XML.pushTag("object", i);
            int numFields = XML.getNumTags("field");
            for (int j=0; j<numFields; j++) {
                string name = XML.getAttribute("field", "name", "default", j);
                if (name == "authorName"){
                    morph.author = XML.getValue("field", "", j);
                }
                if (name == "morphName"){
                    morph.title = XML.getValue("field", "", j);
                }
                if (name == "description"){
                    morph.description = XML.getValue("field", "", j);
                }
                if (name == "largeThumb"){
                    string path = XML.getValue("field", "", j);
                    vector<string> s = ofSplitString(path, "/");
                    string fileName = s.back();
                    morph.largeThumbFilePath = fileName;
                }
                if (name == "xmlFile"){
                    string path = XML.getValue("field", "", j);
                    vector<string> s = ofSplitString(path, "/");
                    string fileName = s.back();
                    morph.xmlFilePath = fileName;
                }
            }
            
            morphs.push_back(morph);
            XML.popTag();
        }
                        
        for (int i=0; i<numMorphs; i++) {
            string remotePath = ofToString(morphs[i].largeThumbFilePath);
            remotePath = "thumb_files/" + remotePath;
            downloadFile(remotePath);
         }
    }
     
    return morphs;
}
//--------------------------------------------------------------
void testApp::downloadFile(string remotePath){
    string sharedDirPath = ofxiPhoneGetDocumentsDirectory() + "sharedMorphs/";
    if (!ofDirectory::doesDirectoryExist(sharedDirPath)){
        ofDirectory::createDirectory(sharedDirPath);
    }
    vector<string> s = ofSplitString(remotePath, "/");
    string fileName = s[1];
    string localPath = sharedDirPath + fileName;
    
    // check if we already have this image locally, if not, download it
    if (!ofFile::doesFileExist(localPath)) {
        string fileURL = ofToString(MEDIA_URL) + "/" + remotePath;
        ofSaveURLTo(fileURL, localPath);
        cout << "downloaded: " + fileName << endl;
    }
}
//--------------------------------------------------------------
void testApp::uploadMorph(MorphMetaData morph){
    
    if (morph.title == "") {
        cout << "title was empty" << endl;
        morph.title = "untitled";
    }
    if (morph.author == "") {
        cout << "author was empty" << endl;
        morph.author = "anonymous";
    }
    if (morph.description == "") {
        cout << "description was empty" << endl;
        morph.description = "---";
    }
    
    ofxCurl curl;
    ofxCurlForm* form = curl.createForm(UPLOAD_URL);
    form->addInput("authorName", morph.author);
    form->addInput("morphName", morph.title);
    form->addInput("description", morph.description);
    form->addFile("largeThumb", morph.largeThumbFilePath);
    form->addFile("xmlFile",morph.xmlFilePath);
    
    form->setTimeout(10000);
    
    try {
        form->post();
    }
    catch(...) {
        // put an alert box for the user here!
        cout << "OOPS.. something went wrong while posting" << endl;
    }
    
    // get the response from the post.
    vector<char> response_buf = form->getPostResponseAsBuffer();
    string response_str = form->getPostResponseAsString();
    
    cout << "Response string:" << endl;
    cout << response_str <<endl;
    cout << "-----------------" << endl;
    
    // create an alert box to report success or failure
    string ofMessage;
    if (response_str == "success") {
        ofMessage = "Your Morph was successfully shared. Press the Open button and go to the Shared tab to see all the shared Morphs.";
    } else {
        ofMessage = "Something went wrong and I couldn't upload your Morph, sorry. Try checking your internet connection.";
    }
    NSString *objcMessage = [NSString stringWithCString:ofMessage.c_str()
                                              encoding:[NSString defaultCStringEncoding]];
    UIAlertView *alertUploadComplete = [[UIAlertView alloc] initWithTitle:@""
													message:objcMessage
												   delegate:nil
										  cancelButtonTitle:@"Okay"
                                            otherButtonTitles:nil, nil];
	[alertUploadComplete show];
	[alertUploadComplete release];
    
    // Cleanup
    delete form;
}
//--------------------------------------------------------------
void testApp::loadCanvas(MorphMetaData morph){
    
	clearCanvas();
    
    bool loaded = XML.loadFile(morph.xmlFilePath);

    if (!loaded) {
        string remotePath = ofToString(morph.xmlFilePath);
        downloadFile("xml_files/" + remotePath);
        loaded = XML.loadFile(morph.xmlFilePath);
        if (!loaded) {
            return;
        }
    }
    
	int numBells = XML.getNumTags("BELL");
	if (numBells > 0) {
		 for (int i=0; i<numBells; i++) {
			 int newX = XML.getValue("BELL:X", 0.0f, i);
			 int newY = XML.getValue("BELL:Y", 0.0f, i);
			 int newNoteNum = XML.getValue("BELL:NOTENUM", 0, i);
			 int newOctave  = XML.getValue("BELL:OCTAVE", 1, i);
			 int newInst = XML.getValue("BELL:INSTRUMENT", 2, i);
			 Bell *b = new Bell(newX, newY, newNoteNum, newOctave, newInst);
             b->setPlayer(instrumentSoundPlayers[newInst]);
             b->setImageTriplet(bellImageTriplets[newInst]);
             bells.push_back(b);
		 }
	 }
	int numRecBells = XML.getNumTags("RECBELL");
	if (numRecBells > 0) {
		for (int i=0; i<numRecBells; i++) {
			int newX = XML.getValue("RECBELL:X", 0, i);
			int newY = XML.getValue("RECBELL:Y", 0, i);
			XML.pushTag("RECBELL", i);
			int numNotes = XML.getNumTags("NOTE");
			vector<Note*> notes;
			for (int j=0; j<numNotes; j++) {
				Note *n = new Note();
				n->time = XML.getValue("NOTE:TIME", 0.0f, j);
				n->note = XML.getValue("NOTE:NOTE", 0, j);
				n->octave = XML.getValue("NOTE:OCTAVE", 0, j);
				n->velocity = XML.getValue("NOTE:VELOCITY", 0.0f, j);
				n->instrument = XML.getValue("NOTE:INSTRUMENT", 0, j);
				notes.push_back(n);
			}
			XML.popTag();
            RecorderBell *b = new RecorderBell(newX, newY, notes, recBellImage, recorderBellMaker);
            b->setPlayers(instrumentSoundPlayers);
			bells.push_back(b);
		}
	}
	
	int numLines = XML.getNumTags("LINE");
	if (numLines > 0) {
		for (int i=0; i<numLines; i++) {
			XML.pushTag("LINE", i);
			int numPoints = XML.getNumTags("P");
			drawingLines.push_back(new DrawingLine());
			for (int j=0; j<numPoints; j++) {
				int newX = XML.getValue("P:X", 0, j);
				int newY = XML.getValue("P:Y", 0, j);
				drawingLines.back()->addPoint(newX, newY);
			}
			XML.popTag();
		}
	}
	
	zoom = (float)XML.getValue("ZOOM:VALUE", 1.0f, 0);
	screenPosX = (float)XML.getValue("SCREENPOS:X", SCREENSTARTPOSX, 0);
	screenPosY = (float)XML.getValue("SCREENPOS:Y", SCREENSTARTPOSY, 0);
    
    titleKeyboard->setText(ofToString(XML.getValue("TITLE:TEXT", "", 0)));
    authorKeyboard->setText(ofToString(XML.getValue("AUTHOR:TEXT", "", 0)));
    descriptionKeyboard->setText(ofToString(XML.getValue("DESCRIPTION:TEXT", "", 0)));
}
//--------------------------------------------------------------
void testApp::clearCanvas(){
	for (int i=0; i<bells.size(); i++) {
		if (bells[i]->isRecorderBell()) {
			for(int j=0; j<bells[i]->notes.size(); j++) {
				delete bells[i]->notes[j];
			}
			bells[i]->notes.clear();
		}
		delete bells[i];
	}
	bells.clear();
	
	for (int i=0; i<drawingLines.size(); i++) {
		for (int j=0; j<drawingLines[i]->points.size(); j++) {
			delete drawingLines[i]->points[j];
		}
		drawingLines[i]->points.clear();
		delete drawingLines[i];
	}
	drawingLines.clear();
	
	zoom = 1;
    octaveButtons->reset();
    paletteXPos = 0;
    
	screenPosX = SCREENSTARTPOSX;
	screenPosY = SCREENSTARTPOSY;
    
    titleKeyboard->setText("");
    authorKeyboard->setText("");
    descriptionKeyboard->setText("");
}
//--------------------------------------------------------------
void testApp::toggleControlPanel(){
	[controlPanel.view setHidden:!controlPanel.view.hidden];
}
//--------------------------------------------------------------
void testApp::toggleAllNotes(){
	showAllNotes = !showAllNotes;
}
//--------------------------------------------------------------
void testApp::toggleNoteNames(){
	showNoteNames = !showNoteNames;
}
//--------------------------------------------------------------
void testApp::setDrawingOn(){
	drawingOn = true;
}
//--------------------------------------------------------------
void testApp::setDrawingOff(){
	drawingOn = false;
}
//--------------------------------------------------------------
void testApp::setErasingOn(){
	erasingOn = true;
}
//--------------------------------------------------------------
void testApp::setErasingOff(){
	erasingOn = false;
}
//--------------------------------------------------------------
void testApp::setSlidingOn(){
	slideModeOn = true;
}
//--------------------------------------------------------------
void testApp::setSlidingOff(){
	slideModeOn = false;
}
//--------------------------------------------------------------
void testApp::eraseLine(int canvasX, int canvasY){
	vector<int> nearbyLineIndices;
	for (int i=0; i<drawingLines.size(); i++) {
		if (drawingLines[i]->inBox(canvasX, canvasY)) {
			nearbyLineIndices.push_back(i);
		}
	}
	int closestLineIndex = -1;
	float minDist = 10;
	for (int i=0; i<nearbyLineIndices.size(); i++) {
		vector<Point2D*> pts = drawingLines[nearbyLineIndices[i]]->getPoints();
		for (int j=0; j<pts.size(); j++) {
			float d = ofDist(canvasX, canvasY, pts[j]->x, pts[j]->y);
			if (d < minDist) {
				minDist = d;
				closestLineIndex = nearbyLineIndices[i];
			}
		}
	}
	if (minDist < 10) {
		drawingLines.erase(drawingLines.begin() + closestLineIndex);
	}
}
//--------------------------------------------------------------
void testApp::countTouches(){
	numTouches = 0;
	for (int i=0; i<MAXTOUCHES; i++) {
		if (touchesDown[i]) {
			numTouches++;
		}
	}
}
//--------------------------------------------------------------
float testApp::pinchDist(){
	int touchOneId = -1;
	int touchTwoId = -1;
	for (int i=0; i<MAXTOUCHES; i++) {
		if (touchesDown[i]) {
			if (touchOneId == -1) {
				touchOneId = i;
			} else { 
				touchTwoId = i;
			}
		}
	}
	float d = ofDist(touchesX[touchOneId], touchesY[touchOneId], touchesX[touchTwoId], touchesY[touchTwoId]);
	return d;
}
//--------------------------------------------------------------
int testApp::getPaletteNote(int x) {
	float inc = (768 - 100) / (float)(NUMNOTES+1);
	for(int i=0; i<NUMNOTES; i++) {
		if (absf(x - palettePositions[i]) < (inc / 2.0)) {
			if (!showAllNotes && noteFunctions(i) == 2) {
				return -1;
			} else {
				return i;
			}
		}
	}
	return -1;
}
//--------------------------------------------------------------
void testApp::startRecording(){
	recording = true;
}
//--------------------------------------------------------------
void testApp::stopRecording(){
	recording = false;
}
//--------------------------------------------------------------
void testApp::addBell(Bell *b){
	bells.push_back(b);
}
//--------------------------------------------------------------
void testApp::makeRecBell(vector<Note*> notes){
    
    // wow this is all screwy due to coordinate systems with different rotations...

    //printf("%d %d", ofGetWidth(), ofGetHeight());
    // ofGetWidth/Height gives 1024 x 768 i.e. landscape coords
    // but... native UI objects are in portrait coords...?
    
    // pick a default position for the recorder bell to appear, near the recorder bell maker
    int x = ((ofGetWidth() - 130 )/ zoom) + screenPosX;
	int y = ((recorderBellMaker.view.center.x - 130) / zoom) + screenPosY;

    // add some random jitter so successive recorder bells don't perfectly overlap
    float jitterSize = 25.0;
    x += ofRandom(-jitterSize,jitterSize);
    y += ofRandom(-jitterSize,jitterSize);
    
	RecorderBell *b = new RecorderBell(x, y, notes, recBellImage, recorderBellMaker);
    b->setPlayers(instrumentSoundPlayers);
	bells.push_back(b);

//    b->setMidi(midi);
//    bells[bells.size()-1]->setMidi(midi);

}



//--------------------------------------------------------------
void testApp::buildLoadMenu() {
    
    // LOAD METADATA FROM XML FILES
    
    // load XML files of examples and user morphs, and populate vectors of morph metadata
    // the metadata will be used to generate menu items
    
    ofDirectory exampleXmlPaths;
    exampleXmlPaths = *new ofDirectory();
    exampleXmlPaths.allowExt("xml");
    int numExampleMorphs = exampleXmlPaths.listDir("examples");
    exampleXmlPaths.sort();
    
    ofDirectory userXmlPaths;
    userXmlPaths = *new ofDirectory();
    userXmlPaths.allowExt("xml");
    int numUserMorphs = userXmlPaths.listDir(ofxiPhoneGetDocumentsDirectory());
    userXmlPaths.sort();
    
    // the example morphs are manually named in the order they should appear in the menu
    // so results of the ofDirectory sort are fine
    exampleMorphsMetaData.clear();
    for(int i = 0; i < numExampleMorphs; i++){
        MorphMetaData morph = loadMorphMetaData(exampleXmlPaths.getPath(i));
        exampleMorphsMetaData.push_back(morph);
    }
    
    // the user morphs are in ascending order of time since the filenames use timestamps
    // but we want them in reverse time order (newest first) in the menu
    // ofDirectory doesn't seem to have reverse sort, so we'll load them into the
    // metadata vector in reverse
    userMorphsMetaData.clear();
    for (int i = numUserMorphs - 1; i >= 0; i--) {
        MorphMetaData morph = loadMorphMetaData(userXmlPaths.getPath(i));
        userMorphsMetaData.push_back(morph);
    }
    
    // CREATE A PAGE OF THUMBNAIL BUTTONS FOR EACH TAB
    
    // create canvases for example and user morphs, and
    // put the first page of buttons to load the morphs on them
    // colorfill of these tabs matches colorback of the canvases, to get the visual effect of tabs
    
    loadMenuCanvas = new ofxUICanvas(0, 0, ofGetWidth(), ofGetHeight());
    
    // prev and next buttons
    int y = 395;
    int x = 10;
    previousButton = new ofxUILabelButton(10, y, 100, false, "Previous");
    loadMenuCanvas->addWidget(previousButton);
    nextButton = new ofxUILabelButton(ofGetWidth()-110, y, 100, false, "Next");
    loadMenuCanvas->addWidget(nextButton);
    ofxUISpacer *graySpacer = new ofxUISpacer(0, y-10, ofGetWidth(), 50);
    graySpacer->setColorFill(ofColor(100));
    loadMenuCanvas->addWidget(graySpacer);
    
    // generate pages
    examplesLoadMenuCanvas = canvasForMenuPage(exampleMorphsMetaData, "exampleMorphButton", 1);
    userLoadMenuCanvas = canvasForMenuPage(userMorphsMetaData, "userMorphButton", 1);
    sharedLoadMenuCanvas = new ofxUIMorphCanvas(); // defer downloading until first view
    
    loadMenuCanvas->addWidget(examplesLoadMenuCanvas);
    loadMenuCanvas->addWidget(userLoadMenuCanvas);
    loadMenuCanvas->addWidget(sharedLoadMenuCanvas);
    
    ofAddListener(examplesLoadMenuCanvas->newGUIEvent, this, &testApp::guiEvent);
    ofAddListener(userLoadMenuCanvas->newGUIEvent, this, &testApp::guiEvent);
    ofAddListener(sharedLoadMenuCanvas->newGUIEvent, this, &testApp::guiEvent);
    ofAddListener(loadMenuCanvas->newGUIEvent, this, &testApp::guiEvent);
    
    loadMenuCanvas->setVisible(false);
    
    // CREATE TAB BUTTONS
    
    // tabs at the top for examples, my stuff, shared (made using label toggles)
    int buttonWidth = 100;
    int spacer = 10;
    int left = (ofGetWidth() / 2) - ((3 * buttonWidth + 2 * spacer) / 2);
    
    examplesTabLabelToggle = new ofxUILabelToggle(left, 10, buttonWidth, 35, false, "Examples");
    examplesTabLabelToggle->setColorFill(100);
    examplesTabLabelToggle->setColorBack(10);
    loadMenuCanvas->addWidget(examplesTabLabelToggle);
    
    userTabLabelToggle = new ofxUILabelToggle(left + buttonWidth + spacer, 10, buttonWidth, 35, false, "My Stuff");
    userTabLabelToggle->setColorFill(100);
    userTabLabelToggle->setColorBack(10);
    loadMenuCanvas->addWidget(userTabLabelToggle);
    
    sharedTabLabelToggle = new ofxUILabelToggle(left + 2 * (buttonWidth + spacer), 10, buttonWidth, 35, false, "Shared");
    sharedTabLabelToggle->setColorFill(100);
    sharedTabLabelToggle->setColorBack(10);
    loadMenuCanvas->addWidget(sharedTabLabelToggle);
    
    currentLoadMenuTab = EXAMPLES_TAB; // this could be loaded from a settings file, and saved between launches
    
    // CREATE METADATA DISPLAY AND BUTTONS AT BOTTOM OF THE SCREEN
    
    y = graySpacer->getRect()->getY() + graySpacer->getRect()->getHeight() + 10;
    
    largeThumbImageForLoading.allocate(ofGetWidth(), ofGetHeight(), OF_IMAGE_COLOR_ALPHA);
    ofxUIImage *img = new ofxUIImage(x, y, 400, 300, &largeThumbImageForLoading, "");
    loadMenuCanvas->addWidget(img);
    
    // text labels for the fields that display metadata
    // (the actual text fields displaying it are in the draw function, because they are rendered by ofxTextSuite
    // because ofxUI does not have multiline text fields)
    loadMenuCanvas->addWidget(new ofxUILabelButton(420, y, false, "Title"));
    loadMenuCanvas->addWidgetSouthOf(new ofxUILabelButton(false, "Author"), "Title");
    descriptionLabel = new ofxUILabelButton(100, false, "Description");
    loadMenuCanvas->addWidgetSouthOf(descriptionLabel, "Author");
    
    descriptionTextView.init("NewMedia Fett.ttf", 12);
    authorTextView.init("NewMedia Fett.ttf", 12);
    titleTextView.init("NewMedia Fett.ttf", 12);
    
    // open and cancel buttons
    loadMenuCanvas->addWidget(new ofxUILabelButton(420, ofGetHeight() - 40, 100, false, "Open"));
    loadMenuCanvas->addWidget(new ofxUILabelButton(530, ofGetHeight() - 40, 100, false, "Cancel"));
}
//--------------------------------------------------------------
MorphMetaData testApp::loadMorphMetaData(string xmlPath) {
    
    MorphMetaData morph;
    morph.xmlFilePath = xmlPath;
    
    XML.loadFile(morph.xmlFilePath);
    morph.title = ofToString(XML.getValue("TITLE:TEXT", "-", 0));
    morph.author = ofToString(XML.getValue("AUTHOR:TEXT", "-", 0));
    morph.description = ofToString(XML.getValue("DESCRIPTION:TEXT", "-", 0));
    morph.largeThumbFilePath = ofToString(XML.getValue("THUMBPATH:LARGE", "", 0));
    
    return(morph);
}
//--------------------------------------------------------------
ofxUIMorphCanvas* testApp::canvasForMenuPage(vector<MorphMetaData> morphs, string tag, int pageNum) {
    // height of the labelbuttons being used for tabs is 35, plus 10 padding on top
    // so we position the menu page canvases at y = 45
    // the height is 3 rows of 100px + 4 x padding 10px = 340
    int top = 45;
    int height = 340;
    ofxUIMorphCanvas *newCanvas = new ofxUIMorphCanvas(0, top, ofGetWidth(), height);
    newCanvas->setMorphs(morphs);
    
    newCanvas->setPageNum(pageNum);
    
    bool nextButtonNeeded = false;
    bool prevButtonNeeded = false;
    
    if (pageNum > 1) {
        prevButtonNeeded = true;
    }
    
    // grab a page worth of morphs to make the buttons
    int morphsPerRow = 7;
    int numRows = 3;
    int morphsPerPage = morphsPerRow * numRows;
    
    int startIndex = (pageNum - 1) * morphsPerPage; //page nums are one-indexed (like in django pagination)
    
    if (startIndex >= morphs.size()) { // if pagenum is too high, just get first page
        startIndex = 0;
        prevButtonNeeded = false;
    }
    
    int numToAdd = morphsPerPage;
    if ((startIndex + numToAdd) >= morphs.size()) {     // if we have less than a page (or exactly one page)
        numToAdd = morphs.size() - startIndex;
    } else {
        nextButtonNeeded = true;
    }
    
    // add buttons to canvas in rows of 7
    for(int i = 0; i < numToAdd; i++){
        string path = morphs[startIndex + i].largeThumbFilePath;
        ofxUIImageButton *btn = new ofxUIImageButton(133, 100, true, path, tag);
        btn->setColorPadded(ofColor(255,255,255)); // selection border
        btn->setColorFillHighlight(127);    // down
        btn->setColorBack(255);             // false
        btn->setDrawPadding(false);
        btn->setID(i);
        
        if ((i % morphsPerRow) == 0) {
            newCanvas->addWidgetDown(btn);
        } else {
            newCanvas->addWidgetRight(btn);
        }
    }
    
    // previous page and next page buttons
    newCanvas->prevButtonVisible = prevButtonNeeded;
    newCanvas->nextButtonVisible = nextButtonNeeded;
    
    newCanvas->setName(tag+"MenuPage");
    
    newCanvas->setVisible(false);
    newCanvas->setDrawBack(true);
    newCanvas->setColorBack(ofColor(100));
    
    return newCanvas;
}
//--------------------------------------------------------------
MorphMetaData testApp::getSelectedMorphFromMenuCanvas(int tab) {
    
    if (tab == EXAMPLES_TAB) {
        return examplesLoadMenuCanvas->getSelectedMorph();
    }
    if (tab == USER_TAB) {
        return userLoadMenuCanvas->getSelectedMorph();
    }
    if (tab == SHARED_TAB) {
        return sharedLoadMenuCanvas->getSelectedMorph();
    }
}
//--------------------------------------------------------------
void testApp::hideAllLoadMenuCanvases() {
    examplesLoadMenuCanvas->setVisible(false);
    userLoadMenuCanvas->setVisible(false);
    sharedLoadMenuCanvas->setVisible(false);
}

//--------------------------------------------------------------
void testApp::loadMenuSwitchToTab(int tab) {
    
    currentLoadMenuTab = tab;
    
    hideAllLoadMenuCanvases();
    
    // turn off all the toggles so we end up with just one lit
    examplesTabLabelToggle->setValue(false);
    userTabLabelToggle->setValue(false);
    sharedTabLabelToggle->setValue(false);
    
    switch (tab) {
        case EXAMPLES_TAB:
            examplesTabLabelToggle->setValue(true);
            examplesLoadMenuCanvas->setVisible(true);
            setPrevAndNextButtonsFor(examplesLoadMenuCanvas);
            break;
        case USER_TAB:
            userTabLabelToggle->setValue(true);
            userLoadMenuCanvas->setVisible(true);
            setPrevAndNextButtonsFor(userLoadMenuCanvas);
            break;
        case SHARED_TAB:
            updateSharedLoadMenuCanvas();
            setPrevAndNextButtonsFor(sharedLoadMenuCanvas);
            sharedTabLabelToggle->setValue(true);
            sharedLoadMenuCanvas->setVisible(true);
            break;
        default:
            break;
    }
}
//--------------------------------------------------------------
void testApp::setPrevAndNextButtonsFor(ofxUIMorphCanvas *canvas) {
    previousButton->setVisible(canvas->prevButtonVisible);
    nextButton->setVisible(canvas->nextButtonVisible);
}
//--------------------------------------------------------------
void testApp::buildSaveDialog() {
    
    int xOffset = 20;
    int yOffset = 20;
    int ySpacing = 40;
    
    saveDialogCanvas = new ofxUICanvas(0,0,ofGetWidth(), ofGetHeight());
    saveDialogCanvas->setVisible(false);
    saveDialogCanvas->setDrawBack(true);
    saveDialogCanvas->setColorBack(ofColor(0,0,0));
    
    
    // these are labelbuttons being used as text labels... ofxUILabel causes a crash for some reason
    saveDialogCanvas->addWidget(new ofxUILabelButton(xOffset, yOffset, false, "Title"));
    saveDialogCanvas->addWidget(new ofxUILabelButton(xOffset, yOffset+ySpacing, false, "Author"));
    saveDialogCanvas->addWidget(new ofxUILabelButton(xOffset, yOffset+ySpacing*2, false, "Description"));
    
    // keyboard text input boxes
    // each text input area is a separate ofxiPhoneKeyboard object
    
    xOffset = 140;
    int textHeight = 25;
    int textWidth = 300;
    
    titleKeyboard = new ofxiPhoneKeyboard(xOffset, yOffset, textWidth, textHeight);
	titleKeyboard->setVisible(false);
	titleKeyboard->setBgColor(255, 255, 255, 255);
	titleKeyboard->setFontColor(0,0,0, 255);
	titleKeyboard->setFontSize(18);
    
    authorKeyboard = new ofxiPhoneKeyboard(xOffset, yOffset+ySpacing, textWidth, textHeight);
	authorKeyboard->setVisible(false);
	authorKeyboard->setBgColor(255, 255, 255, 255);
	authorKeyboard->setFontColor(0,0,0, 255);
	authorKeyboard->setFontSize(18);
    
    // Two hacks were required to make the description field work:
    // to get the text to wrap, we need to use UITextView instead of UITextField
    // so I created a modified class called ofxiPhoneKeyboardWrapping that uses UITextView
    // also, the UITextView wrapping seems to be off by 90 degrees (sigh), even though the
    // actual box is drawn correctly- it uses the height to set the width at which the text wraps
    // so... it's fine as long as it's a square
    descriptionKeyboard = new ofxiPhoneKeyboardWrapping(xOffset, yOffset+ySpacing*2, textWidth, textWidth);
	descriptionKeyboard->setVisible(false);
	descriptionKeyboard->setBgColor(255, 255, 255, 255);
	descriptionKeyboard->setFontColor(0,0,0, 255);
	descriptionKeyboard->setFontSize(18);
    
    // large thumbnail
    int thumbX = xOffset + textWidth + 20;
    int thumbWidth = 400;
    int thumbHeight = 300;
    largeThumbImageForSaving.allocate(ofGetWidth(), ofGetHeight(), OF_IMAGE_COLOR_ALPHA);
    saveDialogCanvas->addWidget(new ofxUIImage(thumbX, yOffset, thumbWidth, thumbHeight, &largeThumbImageForSaving, ""));
    
    // buttons
    int buttonY = yOffset + thumbHeight + 20;
    saveDialogCanvas->addWidget(new ofxUILabelButton(thumbX, buttonY, 100, false, "Share"));
    saveDialogCanvas->addWidget(new ofxUILabelButton(thumbX + 110, buttonY, 100, false, "Cancel"));
    saveDialogCanvas->addWidget(new ofxUILabelButton(thumbX + 220, buttonY, 100, false, "Save"));
    
    ofAddListener(saveDialogCanvas->newGUIEvent, this, &testApp::guiEvent);
    
}
//--------------------------------------------------------------
void testApp::enterUIMode(int mode){
    
    UIMode = mode;
    
    hideAllUIModes();
    
    switch (mode) {
        case PLAY_MODE:
            playModeSetVisible(true);
            break;
        case PRE_SAVE_MODE:
            playModeSetVisible(true);
            break;
        case SAVE_DIALOG_MODE:
            saveDialogModeSetVisible(true);
            break;
        case LOAD_MENU_MODE:
            loadMenuModeSetVisible(true);
            loadMenuSwitchToTab(currentLoadMenuTab);
            break;
        default:
            break;
    }
}
//--------------------------------------------------------------
void testApp::hideAllUIModes(){
    loadMenuModeSetVisible(false);
    playModeSetVisible(false);
    saveDialogModeSetVisible(false);
}
//--------------------------------------------------------------
void testApp::loadMenuModeSetVisible(bool visible) {
    
    hideAllLoadMenuCanvases();
    loadMenuCanvas->setVisible(visible);
}
//--------------------------------------------------------------
void testApp::playModeSetVisible(bool visible) {
    
    // show or hide the native UI components
    // note we have to use setHidden here, so we set it to the inverse of visible
    [topButtons.view setHidden:!visible];
    [controlPanelToggle.view setHidden:!visible];
    [recorderBellMaker.view setHidden:!visible];
    [drawingToggle.view setHidden:!visible];
    
    // ofxUI based components
    instrumentSelector->setVisible(visible);
    quasiModeSelectorCanvas->setVisible(visible);
    
    //special case- we close the control panel when returning to play mode
    [controlPanel.view setHidden:YES];
    
    
    
}
//--------------------------------------------------------------
void testApp::saveDialogModeSetVisible(bool visible) {
    
    saveDialogCanvas->setVisible(visible);
    
    // show or hide keyboard widget and open it if necessary
    authorKeyboard->setVisible(visible);
    titleKeyboard->setVisible(visible);
    descriptionKeyboard->setVisible(visible);
    
    if (visible) {
        titleKeyboard->openKeyboard();
    }
    
}



//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
    
    // hide the control panel, since we touched outside of it
    [controlPanel.view setHidden:YES];
    
    //if (!loadMenuScrollableCanvas->isVisible() && noCanvasIsHit(touch.x, touch.y)) {
    //if (!loadMenuCanvas->isVisible()) {
    if (UIMode == PLAY_MODE) {
        
        touchesDown[touch.id] = true;
        touchesX[touch.id] = touch.x;
        touchesY[touch.id] = touch.y;
        countTouches();
        
        //cout << "id " + ofToString(touch.id) + " mode " + ofToString(quasiModeSelectorCanvas->getCurrentMode()) << endl;
        //cout << ofToString(touch.x) << " " << ofToString(touch.y) << endl;
        
        // if we're on a quasimode button
        // prevent touches to bells beneath the button
        if (quasiModeSelectorCanvas->isHit(touch.x, touch.y)) {
            return;
        }
        
        // palette
        if ((touch.y < 100) && (touch.y > 40)) { // above bottom of palette, and below the instrument selector
            int noteNum = getPaletteNote(touch.x);
            if (noteNum != -1) {
                int x = (touch.x / zoom + screenPosX);
                int y =  (touch.y / zoom + screenPosY) + (BELLRADIUS * zoom);
                Bell *b = new Bell(x, y, noteNum, octaveButtons->getOctave(), currentInstrument);
                b->setPlayer(instrumentSoundPlayers[currentInstrument]);
                b->setImageTriplet(bellImageTriplets[currentInstrument]);
                b->startDrag(touch.id, 0, BELLRADIUS * zoom);
                b->playNote();
                bells.push_back(b);
            }
            return;
        }

        // drawing and erasing
        //if (touch.id == 1) {
            if (quasiModeSelectorCanvas->getCurrentMode() == DRAW_MODE) {
                drawingLines.push_back(new DrawingLine());
                int canvasX = int (screenPosX + (touch.x / zoom));
                int canvasY = int (screenPosY + (touch.y / zoom));
                drawingLines.back()->addPoint(canvasX, canvasY);
                return;
            }
            if (quasiModeSelectorCanvas->getCurrentMode() == ERASE_MODE) {
                int canvasX = int (screenPosX + (touch.x / zoom));
                int canvasY = int (screenPosY + (touch.y / zoom));
                eraseLine(canvasX, canvasY);
                return;
            }
        //}
        
        // select mode
        if (quasiModeSelectorCanvas->getCurrentMode() == SELECT_MODE) {
            if (touch.id == 1) {
                selectionStartCorner.x = int (screenPosX + (touch.x / zoom));
                selectionStartCorner.y = int (screenPosY + (touch.y / zoom));
                selectionDragCorner.x = selectionStartCorner.x;
                selectionDragCorner.y = selectionStartCorner.y;
            }
        }

        // bells
        calculateForce();
        for (int i=bells.size()-1; i>=0; i--) {
            bool touched = bells[i]->touchDown((int)touch.x, (int)touch.y, touch.id);
            if (touched) {
                if (recording) {
                    [recorderBellMaker recordNote:bells[i]];
                }
                // put the touched bell at the end of the list so it draws last (in front)
                std::swap(bells[i], bells.back());
                return; // return so we don't play multiple bells if they are overlapping
                        // this also prevents overlapping bells from dragging together (they get stuck together)
            }
        }
        // zooming
        if (numTouches == 2 && (quasiModeSelectorCanvas->getCurrentMode() == NONE)) {
            zooming = true;
            zoomBegun = false;
            pinchStartDist = pinchDist();
            zoomStart = zoom;
            return;
        }
        
        // dragging the screen over the canvas
        // (if we make it here, we are not touching a bell or the palette or minimap or zooming)
        if (!draggingCanvas) {
            if (quasiModeSelectorCanvas->getCurrentMode() == NONE) {
                touchPrevX = touch.x;
                touchPrevY = touch.y;
                draggingCanvas = true;
                draggingCanvasId = touch.id;
            }
        }
    }
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){

//    if (!loadMenuScrollableCanvas->isVisible() && noCanvasIsHit(touch.x, touch.y)) {
//    if (!loadMenuCanvas->isVisible()) {
    if (UIMode == PLAY_MODE) {
        
        touchesX[touch.id] = touch.x;
        touchesY[touch.id] = touch.y;
        
        // if we're on a quasimode button
        // prevent touches to bells beneath the button
        if (quasiModeSelectorCanvas->isHit(touch.x, touch.y)) {
            return;
        }
        
        // drawing
        if (touch.id == 1) { 
            if (quasiModeSelectorCanvas->getCurrentMode() == DRAW_MODE) {
                if (drawingLines.size() == 0) {
                    drawingLines.push_back(new DrawingLine());
                }
                int canvasX = int (screenPosX + (touch.x / zoom));
                int canvasY = int (screenPosY + (touch.y / zoom));
                drawingLines.back()->addPoint(canvasX, canvasY);
                return;
            }
            if (quasiModeSelectorCanvas->getCurrentMode() == ERASE_MODE) {
                int canvasX = int (screenPosX + (touch.x / zoom));
                int canvasY = int (screenPosY + (touch.y / zoom));
                eraseLine(canvasX, canvasY);
                return;
            }		
        }
        
        // slide mode
        if (quasiModeSelectorCanvas->getCurrentMode() == SLIDE_MODE) {
            for (int i=0; i<bells.size(); i++) {
                bool played = bells[i]->slide(touch.x, touch.y, touch.id);
                if (played) {
                    if (recording) {
                        [recorderBellMaker recordNote:bells[i]];
                    }
                }
            }
            return;
        }
        
        // select mode
        if (quasiModeSelectorCanvas->getCurrentMode() == SELECT_MODE) {
            if (touch.id == 1) {
                selectionDragCorner.x = int (screenPosX + (touch.x / zoom));
                selectionDragCorner.y = int (screenPosY + (touch.y / zoom));
            }
        }
        
        // bells get dragged
        int numDragging = 0;
        if (!zooming) {
            for (int i=0; i<bells.size(); i++) {
                bool dragging = bells[i]->touchMoved(touch.x, touch.y, touch.id);
                if (dragging) {
                    numDragging++;
                }
            }
        }
        // pinch zoom
        if (quasiModeSelectorCanvas->getCurrentMode() == NONE) {
            if (zooming && numDragging == 0 && numTouches == 2) {
                
                float dist = pinchDist();
                
                if (!zoomBegun) {
                    if (absf(dist - pinchStartDist) > MINPINCHZOOMDIST) {  // hm this threshold still causes a jump when you start zooming
                        zoomBegun = true;
                    }
                }
                    
                if (zoomBegun) {
                    float prevZoom = zoom;
                    zoom = zoomStart + ((dist - pinchStartDist) / 400.0f);
                    zoom = ofClamp(zoom, MINZOOM, MAXZOOM);
                    
                    float screenCenterX = screenPosX + ((ofGetWidth() / 2.0) / prevZoom);
                    float screenCenterY = screenPosY + ((ofGetHeight() / 2.0) / prevZoom);
                    
                    float newWidth = (ofGetWidth() / 2.0) / zoom;
                    float newHeight = (ofGetHeight() / 2.0) / zoom;
                    
                    screenPosX = screenCenterX - newWidth;
                    screenPosY = screenCenterY - newHeight;
                }
                return;
            }
        }
        // drag the canvas
        if (quasiModeSelectorCanvas->getCurrentMode() == NONE) {
            if (draggingCanvas && touch.id == draggingCanvasId) {
                screenPosX += (touchPrevX - touch.x) / zoom;
                screenPosY += (touchPrevY - touch.y) / zoom;
                touchPrevX = touch.x;
                touchPrevY = touch.y;
            }
        }
    }
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
    
//    if (!loadMenuScrollableCanvas->isVisible() && noCanvasIsHit(touch.x, touch.y)) {
//    if (!loadMenuCanvas->isVisible()) {
    if (UIMode == PLAY_MODE) {

        touchesDown[touch.id] = false;
        countTouches();

        if (touch.y < 90) {
            for (int i=0; i<bells.size(); i++) {
                if (bells[i]->deleteMe(touch.id)) {
                    if (bells[i]->isRecorderBell()) {
                        for (int j=0; j<bells[i]->notes.size(); j++) {
                            delete bells[i]->notes[j];
                        }
                    }
                    bells.erase(bells.begin()+i);
                }
            }
        }
        for (int i=0; i<bells.size(); i++) {
            bells[i]->touchUp((int)touch.x, (int)touch.y, touch.id);
        }
        if (touch.id == draggingCanvasId) {
            draggingCanvas = false;
        }
        if (numTouches < 2) {
            zooming = false;
            zoomBegun = false;
        }
    }
    if ((UIMode == LOAD_MENU_MODE) || (UIMode == SAVE_DIALOG_MODE)) {
        // we need the location of the touch up to check for "touch up outside" in the gui event
        touchUpX = (int)touch.x;
        touchUpY = (int)touch.y;
    }
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){
    
}
//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs &touch){
    
}

/////////////
// ofxUI stuf
/////////////

void testApp::exit() {
    // there should probably be some stuff here?
}

void testApp::selectMorph(ofxUIMorphCanvas *canvas, int num) {
    
    int morphNum = num + (canvas->getPageNum() - 1) * 21;
    vector <MorphMetaData> morphs = canvas->getMorphs();
    MorphMetaData morph = morphs[morphNum];
    
    canvas->setSelectedMorph(morph);
    canvas->highlightButton(num);
    
    populateMetaDataViews(&morph);
}

void testApp::populateMetaDataViews(MorphMetaData *morph) {
    descriptionTextView.setText(morph->description);
    descriptionTextView.wrapTextX(300);
    authorTextView.setText(morph->author);
    titleTextView.setText(morph->title);
    
    bool loaded = largeThumbImageForLoading.loadImage(morph->largeThumbFilePath);

    if (!loaded) {
        string remotePath = ofToString(morph->largeThumbFilePath);
        downloadFile(remotePath);
        largeThumbImageForLoading.loadImage(morph->largeThumbFilePath);
    }
}

// messages are sent from the instrument selector, containing instrument names
void testApp::gotMessage(ofMessage msg) {
    for (int i=0; i<instrumentNames.size(); i++) {
        if (msg.message == instrumentNames[i]) {
            setInstrument(i);
        }
    }
}

void testApp::guiEvent(ofxUIEventArgs &e)
{
    string name = e.widget->getName();
    
    // load menu buttons
    if (name == "userMorphButton") {
        ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                selectMorph(userLoadMenuCanvas, btn->getID());
            }
        }
    }
    if (name == "exampleMorphButton") {
        ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                selectMorph(examplesLoadMenuCanvas, btn->getID());
            }
        }
    }
    if (name == "sharedMorphButton") {
        ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                selectMorph(sharedLoadMenuCanvas, btn->getID());
            }
        }
    }
    
    // cancel is triggered here by a button on the load menu or the save dialog
    if (name == "Cancel") {
        ofxUILabelButton *btn = (ofxUILabelButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                enterUIMode(PLAY_MODE);
            }
        }
    }
    
    // share and save buttons in the save dialog
    if (name == "Share") {
        ofxUILabelButton *btn = (ofxUILabelButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                saveCanvas(true);
                enterUIMode(PLAY_MODE);
            }
        }
    }
    if (name == "Save") {
        ofxUILabelButton *btn = (ofxUILabelButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                saveCanvas(false);
                enterUIMode(PLAY_MODE);
            }
        }
    }
    
    // load menu open button
    if (name == "Open") {
        ofxUILabelButton *btn = (ofxUILabelButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                MorphMetaData morph = getSelectedMorphFromMenuCanvas(currentLoadMenuTab);
                loadCanvas(morph);
                enterUIMode(PLAY_MODE);
            }
        }
    }
    
    if (name == "Next") {
        ofxUILabelButton *btn = (ofxUILabelButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                if (currentLoadMenuTab == USER_TAB) {
                    int pageNum = userLoadMenuCanvas->getPageNum();
                    loadMenuCanvas->removeWidget(userLoadMenuCanvas);
                    userLoadMenuCanvas = canvasForMenuPage(userMorphsMetaData, "userMorphButton", pageNum + 1);
                    loadMenuCanvas->addWidget(userLoadMenuCanvas);
                    ofAddListener(userLoadMenuCanvas->newGUIEvent, this, &testApp::guiEvent);
                    loadMenuSwitchToTab(USER_TAB);

                }
            }
        }
    }
    if (name == "Previous") {
        ofxUILabelButton *btn = (ofxUILabelButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                if (currentLoadMenuTab == USER_TAB) {
                    int pageNum = userLoadMenuCanvas->getPageNum();
                    loadMenuCanvas->removeWidget(userLoadMenuCanvas);
                    userLoadMenuCanvas = canvasForMenuPage(userMorphsMetaData, "userMorphButton", pageNum - 1);
                    loadMenuCanvas->addWidget(userLoadMenuCanvas);
                    ofAddListener(userLoadMenuCanvas->newGUIEvent, this, &testApp::guiEvent);
                    loadMenuSwitchToTab(USER_TAB);
                }
            }
        }
    }
    
    
    
    // load menu tabs
    if (name == "Examples") {
        loadMenuSwitchToTab(EXAMPLES_TAB);
    }
    if (name == "My Stuff") {
        loadMenuSwitchToTab(USER_TAB);
    }
    if (name == "Shared") {
        loadMenuSwitchToTab(SHARED_TAB);
    }

}

#endif


