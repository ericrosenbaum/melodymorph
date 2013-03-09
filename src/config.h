/*
 *  config.h
 *  iPhoneAdvancedEventsExample
 *
 *  Created by England on 11/6/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#define NUMVOICES	10
#define NUMNOTES	13
#define MAXTOUCHES	5

#define SCREENSTARTPOSX	 100
#define SCREENSTARTPOSY	 100
#define CANVASWIDTH 2000
#define CANVASHEIGHT 2666

#define BELLRADIUS		50
#define RECBELLRADIUS	75
#define DRAGZONE		50

#define MINPINCHZOOMDIST    50

#define LOWOCTBRIGHTNESS	0.5
#define HIGHOCTSATURATION	0.5
 
#define FORCEBUFFERLENGTH	20

#define MINZOOM	0.2
#define MAXZOOM	1.9

#define MINIMAPSCALE	0.05

#define note_C						1
#define	note_Cs						1.05946309
#define note_D						1.12246205
#define	note_Ds                     1.18920712
#define	note_E                      1.25992105
#define	note_F                      1.33483985
#define	note_Fs                     1.41421356
#define	note_G                      1.49830708
#define	note_Gs						1.58740105
#define	note_A						1.68179283
#define	note_As						1.78179744
#define	note_B						1.88774863
#define	note_C2						2

#define UPLOAD_URL					"http://melodymorph2.xvm.mit.edu:8080/upload"
#define BROWSE_URL					"http://melodymorph2.xvm.mit.edu:8080/browse"
#define MEDIA_URL                   "http://melodymorph2.xvm.mit.edu:8080/media"

// UI modes
#define PLAY_MODE                   1
#define LOAD_MENU_MODE              2
#define PRE_SAVE_MODE               3
#define SAVE_DIALOG_MODE            4

// load menu tabs
#define EXAMPLES_TAB                1
#define USER_TAB                    2
#define SHARED_TAB                  3
