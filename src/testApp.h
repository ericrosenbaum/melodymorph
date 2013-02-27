#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxOpenALSoundPlayer.h"
#include "ofxXmlSettings.h"
#include "ofxTextSuite.h"
#include "config.h"
#include "ofxDirList.h"
#include "Note.cpp"
#include "Bell.mm"
#include "ofxCurl.h"


//#import "PGMidi.h"
//#import "iOSVersionDetection.h"
#import "ofxUI.h"
#include "SegmentedControl.h"

class testApp : public ofxiPhoneApp {

		
public:
    
	void setup();
	void update();
	void draw();
	
	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);
	void touchCancelled(ofTouchEventArgs &touch);
	
	void setupMiniMap();
	
	void drawPalette();
	void drawMiniMap();
	
	void calculateForce();
	float bend();

    void buildLoadMenu();
    MorphMetaData loadMorphMetaData(string xmlPath);
    ofxUIMorphCanvas *canvasForMenuPage(vector<MorphMetaData> morphs, string tag, int pageNum);
    MorphMetaData getSelectedMorphFromMenuCanvas(int tab);
    void updateSharedLoadMenuCanvas();
    vector<MorphMetaData> downloadPageOfSharedMorphs(int pageNum);


    void loadMenuSwitchToTab(int tab);
    void setPrevAndNextButtonsFor(ofxUIMorphCanvas *canvas);

    void hideAllLoadMenuCanvases();

    void buildSaveDialog();
    
    void enterUIMode(int mode);
    void hideAllUIModes();
    
    void loadMenuModeSetVisible(bool visible);
    void playModeSetVisible(bool visible);
    void saveDialogModeSetVisible(bool visible);
  
	void saveCanvas(bool saveToServer);
	void loadCanvas(string path);
	void clearCanvas();
    string paddedNumberString(int num);
	
	void toggleControlPanel();
	
	void toggleAllNotes();
	void toggleNoteNames();
	
	void countTouches();
	float pinchDist();
	int getPaletteNote(int x);

	void setOctave(int oct);
	void setInstrument(int inst);
	
	void addBell(Bell *b);
	void makeRecBell(vector<Note*> notes);
	
	void startRecording();
	void stopRecording();
	
	void setDrawingOn();
	void setDrawingOff();
	void setErasingOn();
	void setErasingOff();
    void setSlidingOn();
    void setSlidingOff();
	
	void eraseLine(int canvasX, int canvasY);
	
    void uploadMorph(MorphMetaData morph);
    void saveToServer();
    void browseServer();
	
    void exit();
    void guiEvent(ofxUIEventArgs &e);
    
    void allCanvasesSetVisible(bool visible);
    bool noCanvasIsHit(int x, int y);

};

