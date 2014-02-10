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

#import "TestFlight.h"

#include "ofxiPhoneWebViewController.h"


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
	
    void drawGrid();
    void drawLines();
    void drawBells();
    void drawBellsForThumbnail();

	void drawPalette();
    void drawSelectionBox();

    void roundedRect(float x, float y, float w, float h, float r);
    void quadraticBezierVertex(float cpx, float cpy, float x, float y, float prevX, float prevY);
    
	void calculateForce();
	float bend();

    void buildLoadMenu();
    MorphMetaData loadMorphMetaData(string xmlPath);
    ofxUIMorphCanvas *canvasForMenuPage(vector<MorphMetaData> morphs, string tag, int pageNum);
    MorphMetaData getSelectedMorphFromMenuCanvas(int tab);
    void updateSharedLoadMenuCanvas(int page);
    vector<MorphMetaData> downloadPageOfSharedMorphs(int pageNum);
    void downloadFile(string remotePath);

    void selectMorph(ofxUIMorphCanvas *canvas, int num);
    void populateMetaDataViews(MorphMetaData *morph);

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
	void loadCanvas(MorphMetaData morph);
	void clearCanvas();
    string paddedNumberString(int num);
	
	void toggleControlPanel();
	
	void toggleAllNotes(bool val);
	void toggleNoteNames(bool val);
	
	void countTouches();
	float pinchDist();
	int getPaletteNote(int x);

    void setupInstruments();
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
    void gotMessage(ofMessage msg);

    void allCanvasesSetVisible(bool visible);
    bool noCanvasIsHit(int x, int y);

    void loadBellImages();
    
    void deleteBellNum(int num);
    
    ofxiPhoneWebViewController inlineWebViewController;
    void webViewEvent(ofxiPhoneWebViewControllerEventArgs &args);



};

