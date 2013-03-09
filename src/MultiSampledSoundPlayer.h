//
//  MultiSampledSoundPlayer.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 3/7/13.
//
//

#ifndef MelodyMorph_MultiSampledSoundPlayer_h
#define MelodyMorph_MultiSampledSoundPlayer_h

#include "ofMain.h"

#define NUM_SAMPLES 6

class MultiSampledSoundPlayer {
    
public:
    
    ofSoundPlayer players[NUM_SAMPLES];
    float ratios[7] = {1, 1.05946309, 1.12246205, 1.18920712, 1.25992105, 1.33483985, 1.41421356};
    
    MultiSampledSoundPlayer() {
        
    }
    
    void loadSamples(string directoryName){
        
        ofDirectory samplePaths = *new ofDirectory();
        int numSamples = samplePaths.listDir(directoryName);
        samplePaths.sort();
        
        if (numSamples != NUM_SAMPLES) {
            cout << "expected " + ofToString(NUM_SAMPLES) + " in " + directoryName + " but found " + ofToString(numSamples) << endl;
            return;
        }
        
        for (int i=0; i<numSamples; i++) {
            players[i].loadSound(samplePaths.getPath(i));
            //            cout << "loaded " << samplePaths.getPath(i) << endl;
            players[i].setMultiPlay(true);
        }
    }
    
    void setVolume(float vol) {
        for (int i=0; i<NUM_SAMPLES; i++) {
            players[i].setVolume(vol);
        }
    }
    
    void playNote(int num, int octave) {
        
        int sampleNum;
        int diff;
        
        if (num < 7) {
            sampleNum = octave * 2; // samples 0,2,4 are C
            diff = num;
        } else {
            sampleNum = 1 + (octave * 2); // samples 1,3,5 are G
            diff = num - 7;
        }
        
        players[sampleNum].play();
        players[sampleNum].setSpeed(1/ratios[diff]);
    }
};


#endif
