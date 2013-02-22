// melodymorph 
//
// ssh ericr@melodymorph2.xvm.mit.edu
//
// now we are on github yay

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

vector<Bell*> bells;
ofxOpenALSoundPlayer voices[3][NUMVOICES];
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

int octave;

ofImage bellImages[3][3]; // 3 instruments * 3 functions
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
ofImage smallThumbImageForSaving;

// native UI widgets

TopButtons *topButtons;
ControlPanel *controlPanel;
ControlPanelToggle *controlPanelToggle;
RecorderBellMaker *recorderBellMaker;
LoadFileViewController *loadView;
DrawingToggle *drawingToggle;

// UI mode
// current mode of the UI (#defines are in config.h):
// PLAY_MODE, LOAD_MENU_MODE, PRE_SAVE_MODE, SAVE_DIALOG_MODE
int UIMode;

// current load menu tab
// which of the tabs in the load menu is currently open:
// EXAMPLES_TAB, USER_TAB, SHARED_TAB
int currentLoadMenuTab;

//--------------------------------------------------------------
void testApp::setup(){
        
    UIMode = PLAY_MODE;
    
    ofxiPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
    
	ofEnableAlphaBlending();
			
	for (int i=0; i<NUMVOICES; i++) {
		voices[0][i].loadSound("acoustic_bass_sample.wav");
	}
	for (int i=0; i<NUMVOICES; i++) {
		voices[1][i].loadSound("piano_sample.wav");
	}
	for (int i=0; i<NUMVOICES; i++) {
		voices[2][i].loadSound("vibe_sample.wav");
	}

	currentChannel[0] = 0;
	currentChannel[1] = 0;
	currentChannel[2] = 0;
	
	// compute palette positions
	float inc = (768 - 100) / (float)(NUMNOTES+1);
	int x = inc + 55 + 128;
	for (int i=0; i<NUMNOTES; i++) {
		palettePositions[i] = x;
		x += inc;
	}
	
	screenPosX = SCREENSTARTPOSX;
	screenPosY = SCREENSTARTPOSY;
	
	octave = 1;
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
		
	bellImages[0][0].loadImage("images/ball_plain.png");
	bellImages[0][1].loadImage("images/ball_band.png");
	bellImages[0][2].loadImage("images/ball_stripes.png");
	
	bellImages[1][0].loadImage("images/square_plain.png");
	bellImages[1][1].loadImage("images/square_band.png");
	bellImages[1][2].loadImage("images/square_stripes.png");
	
	bellImages[2][0].loadImage("images/triangle_plain.png");
	bellImages[2][1].loadImage("images/triangle_band.png");
	bellImages[2][2].loadImage("images/triangle_stripes.png");
	
	recBellImage.loadImage("images/rec_bell.png");
	
	paletteBack.loadImage("images/palette_back.png");
	
	recording = false;
    
	//setupMiniMap();
	  
    // MIDI
    // check that the device we're loading the app onto actually supports CoreMIDI
//	IF_IOS_HAS_COREMIDI
//    (
//     midi = [[PGMidi alloc] init];
//     [midi enableNetwork:YES];
//    )
    
     
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
     
     //  drawing toggle
     drawingToggle = [[DrawingToggle alloc] initWithNibName:@"DrawingToggle" bundle:nil];
     [[[UIApplication sharedApplication] keyWindow] addSubview:drawingToggle.view];
     r = CGRectMake(90, ofGetWidth()-100, 300, 100);
     drawingToggle.view.frame = r;
     
     // recorder bell maker
     recorderBellMaker = [[RecorderBellMaker alloc] initWithNibName:@"RecorderBellMaker" bundle:nil];
     //[ofxiPhoneGetGLView() addSubview:recorderBellMaker.view];
     [[[UIApplication sharedApplication] keyWindow] addSubview:recorderBellMaker.view];
     r = CGRectMake(ofGetHeight() - 130, 10, 130, 130);
     recorderBellMaker.view.frame = r;
    
     // buttons at the top of the screen
     topButtons = [[TopButtons alloc] initWithNibName:@"TopButtons" bundle:nil];
     [ofxiPhoneGetGLView() addSubview:topButtons.view];
     // ugh. only way I could figure out to do this
     // it needs to use the GLView to pass touches through it
     // but GLView is apparently not rotated, so we rotate manually
     topButtons.view.transform = CGAffineTransformMakeRotation(ofDegToRad(-90));
     setInstrument(2);
    
     r = CGRectMake(0, 0, 768, 1024);
     topButtons.view.frame = r;
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
 
        smallThumbImageForSaving.clone(largeThumbImageForSaving);
        smallThumbImageForSaving.resize(133,100);
        
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
    
    examplesLoadMenuCanvas = canvasForMenuPage(exampleMorphsMetaData, "exampleMorphButton", 1);
    userLoadMenuCanvas = canvasForMenuPage(userMorphsMetaData, "userMorphButton", 1);

    loadMenuCanvas->addWidget(examplesLoadMenuCanvas);
    loadMenuCanvas->addWidget(userLoadMenuCanvas);
        
    ofAddListener(examplesLoadMenuCanvas->newGUIEvent, this, &testApp::guiEvent);
    ofAddListener(userLoadMenuCanvas->newGUIEvent, this, &testApp::guiEvent);
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
  
    ofxUIRectangle *rect = examplesLoadMenuCanvas->getPaddingRect();
    int y = rect->getY();
    y += rect->getHeight();
    y += 10;
    int x = 10;
    
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
    
    // previous and next buttons
    y = rect->getY() + rect->getHeight() - 40;
    previousButton = new ofxUILabelButton(10, y, 100, false, "Previous Page");
    nextButton = new ofxUILabelButton(ofGetWidth() - 110, y, 100, false, "Next Page");
    loadMenuCanvas->addWidget(previousButton);
    loadMenuCanvas->addWidget(nextButton);

}
//--------------------------------------------------------------
MorphMetaData testApp::loadMorphMetaData(string xmlPath) {
    
    MorphMetaData morph;
    morph.xmlFilePath = xmlPath;
    
    XML.loadFile(morph.xmlFilePath);
    morph.title = ofToString(XML.getValue("TITLE:TEXT", "-", 0));
    morph.author = ofToString(XML.getValue("AUTHOR:TEXT", "-", 0));
    morph.description = ofToString(XML.getValue("DESCRIPTION:TEXT", "-", 0));
    morph.smallThumbFilePath = ofToString(XML.getValue("THUMBPATH:SMALL", "", 0));
    morph.largeThumbFilePath = ofToString(XML.getValue("THUMBPATH:LARGE", "", 0));
    
    return(morph);
}
//--------------------------------------------------------------
ofxUIMorphCanvas* testApp::canvasForMenuPage(vector<MorphMetaData> morphs, string tag, int pageNum) {
    // height of the labelbuttons being used for tabs is 35, plus 10 padding on top
    // so we position the menu page canvases at y = 45
    // the height is 3 rows of 100px + 4 x padding 10px = 340 + 50 more for prev/next btns = 390
    int top = 45;
    int height = 390;
    ofxUIMorphCanvas *newCanvas = new ofxUIMorphCanvas(0, top, ofGetWidth(), height);
    
    // grab a page worth of morphs
    int morphsPerRow = 7;
    int numRows = 3;
    int morphsPerPage = morphsPerRow * numRows;
    int startIndex = (pageNum - 1) * morphsPerPage; //page nums are one-indexed (like in django pagination)
    
    if (startIndex >= morphs.size()) { // if pagenum is too high, just get first page
        startIndex = 0;
    }
    
    int numToAdd = morphsPerPage;
    if ((startIndex + numToAdd) > morphs.size()) {     // if we have less than a page
        numToAdd = morphs.size() - startIndex;
    }
    
    // add buttons to canvas in rows of 7
    for(int i = 0; i < numToAdd; i++){
        string path = morphs[startIndex + i].smallThumbFilePath;
        ofxUIImageButton *btn = new ofxUIImageButton(133, 100, true, path, tag);
        btn->setColorPadded(ofColor(255,255,255));
        btn->setDrawPadding(false);
        btn->setID(startIndex + i); // this is the actual index of the morph in the morphmetadata vector
        if ((i % morphsPerRow) == 0) {
            newCanvas->addWidgetDown(btn);
        } else {
            newCanvas->addWidgetRight(btn);
        }
    }
        
    newCanvas->setName(tag+"MenuPage");
    
    newCanvas->setVisible(false);
    newCanvas->setDrawBack(true);
    newCanvas->setColorBack(ofColor(100));
    
    return newCanvas;
}
//--------------------------------------------------------------
MorphMetaData testApp::getSelectedMorphFromMenuCanvas(int tab) {

    if (tab == EXAMPLES_TAB) {
        return examplesLoadMenuCanvas->getMorph();
    }
    if (tab == USER_TAB) {
        return userLoadMenuCanvas->getMorph();
    }
}
//--------------------------------------------------------------
void testApp::hideAllLoadMenuCanvases() {
    examplesLoadMenuCanvas->setVisible(false);
    userLoadMenuCanvas->setVisible(false);
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
            break;
        case USER_TAB:
            userTabLabelToggle->setValue(true);
            userLoadMenuCanvas->setVisible(true);
            break;
        case SHARED_TAB:
            sharedTabLabelToggle->setValue(true);
            userLoadMenuCanvas->setVisible(false);
            break;
        default:
            break;
    }
    
    // and load up the meta data for the currently selected morph

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
void testApp::drawPalette(){
	
//	ofSetColor(100, 100, 100);
//	ofRect(0, 0, ofGetWidth(), 90);
	
    // background rectangle
	//paletteBack.draw(128, 0, 768, 90);
	ofSetColor(100, 100, 100);
    ofRect(128, 20, 768, 80);
	ofSetHexColor(0xffffff);
    
	int paletteYPos = 75;
	float targetXPos = 0;
	if (octave == 0) {
		targetXPos = 768;
	} 
	if (octave == 2) {
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
				ofImage *img = &bellImages[currentInstrument][function];
				img->setAnchorPercent(0.5, 0.5);
				float xPos = palettePositions[i] + xOffset + paletteXPos;
				if ((xPos < (768 + 128 - 55)) && (xPos > (128 + 55))) {
					img->draw(xPos, paletteYPos + yOffset, diam, diam);
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
        
    // generate a number for the file by incrementing the number of the last one in the dir
    // assuming the number is left padded with zeros to four places
//    string lastPath = userMorphsMetaData.back().xmlFilePath;
//    int len = lastPath.length();
//    string fileName = lastPath.substr(len - 8, 4);
//    int canvasNum = ofToInt(fileName) + 1;

    string timestamp = ofGetTimestampString();
    
    // generate file names and paths
    string smallThumbFilePath = ofxiPhoneGetDocumentsDirectory() + "smallThumbImage_" + timestamp + ".png";
    string largeThumbFilePath = ofxiPhoneGetDocumentsDirectory() + "largeThumbImage_" + timestamp + ".png";
    string XMLFilePath = ofxiPhoneGetDocumentsDirectory() + "bells_" + timestamp + ".xml";
    
	// save thumb images (these were just generated in pre-save mode, inside draw())
    smallThumbImageForSaving.saveImage(smallThumbFilePath);
    largeThumbImageForSaving.saveImage(largeThumbFilePath);
		
	// XML
    string title = titleKeyboard->getText();
    string author = authorKeyboard->getText();
    string description = descriptionKeyboard->getText();
    
	XML.clear();
    XML.setValue("TITLE:TEXT", title, 0);
    XML.setValue("AUTHOR:TEXT", author, 0);
    XML.setValue("DESCRIPTION:TEXT", description, 0);
	XML.setValue("THUMBPATH:SMALL", smallThumbFilePath, 0);
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
        morph.smallThumbFilePath = smallThumbFilePath;
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
void testApp::browseServer(){
//    string p = ofxiPhoneGetDocumentsDirectory() + "test.xml";
//    ofSaveURLTo("http://melodymorph2.xvm.mit.edu:8080/media/xml_files/0a789293-92b9-4340-8eea-0da9944136aa.xml", p);
//    loadCanvas(p);
    
    ofHttpResponse response = ofLoadURL(ofToString(BROWSE_URL) + "?page=1");
    cout << "response to browse request:" << endl;
    cout << response.data.getText() << endl;
    
    // right now this just pulls out file names of thumbs
    XML.loadFromBuffer(response.data.getText());
    XML.pushTag("django-objects");
    int numMorphs = XML.getNumTags("object");
    if (numMorphs > 0) {
        for (int i=0; i<numMorphs; i++) {
            XML.pushTag("object", i);
            int numFields = XML.getNumTags("field");
            for (int j=0; j<numFields; j++) {
                string name = XML.getAttribute("field", "name", "default", j);
                if (name == "thumb"){
                    cout << XML.getValue("field", "", j) << endl;
                }
            }
            XML.popTag();
        }
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
    form->addFile("smallThumb", morph.smallThumbFilePath);
    form->addFile("largeThumb", morph.largeThumbFilePath);
    form->addFile("xmlFile",morph.xmlFilePath);
    
    try {
        form->post();
    }
    catch(...) {
        // put an alert box for the user here!
        cout << "OOPS.. something went wrong while posting" << endl;
    }
    
    // Do something with the response from the post.
    // another alert box for failures
    vector<char> response_buf = form->getPostResponseAsBuffer();
    string response_str = form->getPostResponseAsString();
    cout << "Response string:" << endl;
    cout << response_str <<endl;
    cout << "-----------------" << endl;
    
    // Cleanup
    delete form;
}


//--------------------------------------------------------------
void testApp::loadCanvas(string path){
		
	clearCanvas();
    
    XML.loadFile(path);
    
	int numBells = XML.getNumTags("BELL");
	if (numBells > 0) {
		 for (int i=0; i<numBells; i++) {
			 int newX = XML.getValue("BELL:X", 0.0f, i);
			 int newY = XML.getValue("BELL:Y", 0.0f, i);
			 int newNoteNum = XML.getValue("BELL:NOTENUM", 0, i);
			 int newOctave  = XML.getValue("BELL:OCTAVE", 1, i);
			 int newInst = XML.getValue("BELL:INSTRUMENT", 2, i);
			 Bell *b = new Bell(newX, newY, newNoteNum, newOctave, newInst, voices[newInst], &currentChannel[newInst], bellImages[newInst]);
             bells.push_back(b);
             //b->setMidi(midi);
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
			bells.push_back(new RecorderBell(newX, newY, notes, voices, currentChannel, recBellImage, recorderBellMaker));
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
	octave = 1; 
    [topButtons resetOctave];
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
    
	RecorderBell *b = new RecorderBell(x, y, notes, voices, currentChannel, recBellImage, recorderBellMaker);
	bells.push_back(b);

//    b->setMidi(midi);
//    bells[bells.size()-1]->setMidi(midi);

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
        
        // palette
        if ((touch.y < 100) && (touch.y > 40)) { // above bottom of palette, and below the instrument selector
            int noteNum = getPaletteNote(touch.x);
            if (noteNum != -1) {
                int x = (touch.x / zoom + screenPosX);
                int y =  (touch.y / zoom + screenPosY) + (BELLRADIUS * zoom);
                bells.push_back(new Bell(x, y, noteNum, octave, currentInstrument, voices[currentInstrument], &currentChannel[currentInstrument], bellImages[currentInstrument]));
                bells[bells.size()-1]->startDrag(touch.id, 0, BELLRADIUS * zoom);
                //bells[bells.size()-1]->setMidi(midi);
                bells[bells.size()-1]->playNote();
            }
            return;
        }
        // minimap
    //	if ((touch.y > mapYOffset) && (touch.x > mapXOffset)) {
    //		touchPrevX = touch.x;
    //		touchPrevY = touch.y;
    //		draggingMinimap = true;
    //		draggingMinimapId = touch.id;
    //		return;
    //	}
        
        // drawing and erasing
        if (touch.id == 0) { // changed from 1 in of 71 not sure why
            if (drawingOn) {
                drawingLines.push_back(new DrawingLine());
                int canvasX = int (screenPosX + (touch.x / zoom));
                int canvasY = int (screenPosY + (touch.y / zoom));
                drawingLines.back()->addPoint(canvasX, canvasY);
                return;
            }
            if (erasingOn) {
                int canvasX = int (screenPosX + (touch.x / zoom));
                int canvasY = int (screenPosY + (touch.y / zoom));
                eraseLine(canvasX, canvasY);
                return;
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
            }
        }
        // zooming
        if (numTouches == 2 && !drawingOn) {
            zooming = true;
            zoomBegun = false;
            pinchStartDist = pinchDist();
            zoomStart = zoom;
            return;
        }
        
        // dragging the screen over the canvas
        // (if we make it here, we are not touching a bell or the palette or minimap or zooming)
        if (!draggingCanvas && !drawingOn && !erasingOn) {
            touchPrevX = touch.x;
            touchPrevY = touch.y;
            draggingCanvas = true;
            draggingCanvasId = touch.id;
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
        
        // drawing
        if (touch.id == 0) { //changed from 1 in of 71 not sure why
            if (drawingOn) {
                int canvasX = int (screenPosX + (touch.x / zoom));
                int canvasY = int (screenPosY + (touch.y / zoom));
                drawingLines.back()->addPoint(canvasX, canvasY);
                return;
            }
            if (erasingOn) {
                int canvasX = int (screenPosX + (touch.x / zoom));
                int canvasY = int (screenPosY + (touch.y / zoom));
                eraseLine(canvasX, canvasY);
                return;
            }		
        }
        
        // slide mode
        if (slideModeOn) {
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
        // drag the minimap
    //	if (draggingMinimap && touch.id == draggingMinimapId) {
    //		screenPosX -= (touchPrevX - touch.x) / MINIMAPSCALE;
    //		screenPosY -= (touchPrevY - touch.y) / MINIMAPSCALE;
    //		touchPrevX = touch.x;
    //		touchPrevY = touch.y;		
    //		return;
    //	}
        // drag the canvas
        if (draggingCanvas && touch.id == draggingCanvasId) {
            screenPosX += (touchPrevX - touch.x) / zoom;
            screenPosY += (touchPrevY - touch.y) / zoom;
            touchPrevX = touch.x;
            touchPrevY = touch.y;
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
    //	if (touch.id == draggingMinimapId) {
    //		draggingMinimap = false;
    //	}
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

void testApp::guiEvent(ofxUIEventArgs &e)
{

    string name = e.widget->getName();
    
    // load menu buttons
    if (name == "userMorphButton") {
        ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                int morphNum = e.widget->getID();
                //loadCanvas(userMorphsMetaData[morphNum].xmlFilePath);
                //enterUIMode(PLAY_MODE);
                
                userLoadMenuCanvas->setDrawWidgetPadding(false);
                btn->setDrawPadding(true);
                
                MorphMetaData morph = userMorphsMetaData[morphNum];
                
                userLoadMenuCanvas->setMorph(morph);
                
                largeThumbImageForLoading.loadImage(morph.largeThumbFilePath);
                descriptionTextView.setText(morph.description);
                descriptionTextView.wrapTextX(300);
                authorTextView.setText(morph.author);
                titleTextView.setText(morph.title);

            }
        }
    }
    if (name == "exampleMorphButton") {
        ofxUIImageButton *btn = (ofxUIImageButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                int morphNum = e.widget->getID();
                //loadCanvas(exampleMorphsMetaData[morphNum].xmlFilePath);
                //enterUIMode(PLAY_MODE);
                
                examplesLoadMenuCanvas->setDrawWidgetPadding(false);
                btn->setDrawPadding(true);
                
                MorphMetaData morph = exampleMorphsMetaData[morphNum];
                
                examplesLoadMenuCanvas->setMorph(morph);
                
                largeThumbImageForLoading.loadImage(morph.largeThumbFilePath);
                descriptionTextView.setText(morph.description);
                descriptionTextView.wrapTextX(300);
                authorTextView.setText(morph.author);
                titleTextView.setText(morph.title);

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
                MorphMetaData morph;
                morph = getSelectedMorphFromMenuCanvas(currentLoadMenuTab);
                loadCanvas(morph.xmlFilePath);
                enterUIMode(PLAY_MODE);
            }
        }
    }
    
    if (name == "Next Page") {
        ofxUILabelButton *btn = (ofxUILabelButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                if (currentLoadMenuTab == USER_TAB) {
                    loadMenuCanvas->removeWidget(userLoadMenuCanvas);
                    userLoadMenuCanvas = canvasForMenuPage(userMorphsMetaData, "userMorphButton", 2);
                    loadMenuCanvas->addWidget(userLoadMenuCanvas);
                    ofAddListener(userLoadMenuCanvas->newGUIEvent, this, &testApp::guiEvent);
                    loadMenuSwitchToTab(USER_TAB);

                }
            }
        }
    }
    if (name == "Previous Page") {
        ofxUILabelButton *btn = (ofxUILabelButton *) e.widget;
        if (!btn->getValue()) { // touch up
            if (btn->isHit(touchUpX, touchUpY)) { // prevent triggering on touch up outside
                if (currentLoadMenuTab == USER_TAB) {
                    userLoadMenuCanvas = canvasForMenuPage(userMorphsMetaData, "userMorphButton", 1);
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


