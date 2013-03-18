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

#define MULTI_SAMPLES_NUM 6

class MultiSampledSoundPlayer {
    
public:
    
    bool multiSample;   // we have either one sample (false), or MULTI_SAMPLES_NUM samples (true)
    
    ofSoundPlayer myPlayer;                       // for instruments with one sample
    ofSoundPlayer myPlayers[MULTI_SAMPLES_NUM];   // for multisample instruments
    
    float ratios[13] = {1, 1.05946309, 1.12246205, 1.18920712, 1.25992105, 1.33483985, 1.41421356, 1.49830708, 1.58740105, 1.68179283, 1.78179744, 1.88774863, 2};
    
    
    MultiSampledSoundPlayer() {
        
    }
    
    void loadSamples(string directoryName){
        
        ofDirectory samplePaths = *new ofDirectory();
        int numSamples = samplePaths.listDir(directoryName);
        samplePaths.sort();
        
        
        if (numSamples == MULTI_SAMPLES_NUM) {
            multiSample = true;
        } else if (numSamples == 1) {
            multiSample = false;
        } else {
            cout << "loaded " + directoryName + " with " + ofToString(numSamples) + " samples" << endl;
            cout << "expected " << ofToString(MULTI_SAMPLES_NUM) << " or 1" << endl;
            return;
        }
        
        if (multiSample) {
            for (int i=0; i<numSamples; i++) {
                myPlayers[i].loadSound(samplePaths.getPath(i));
                myPlayers[i].setMultiPlay(true);
            }
        } else {
            myPlayer.loadSound(samplePaths.getPath(0));
            myPlayer.setMultiPlay(true);
        }
    }
    
    void setVolume(float vol) {
        if (multiSample) {
            for (int i=0; i<MULTI_SAMPLES_NUM; i++) {
                myPlayers[i].setVolume(vol);
            }
        } else {
            myPlayer.setVolume(vol);
        }
    }
    
    void playNote(int num, int octave) {
        
        if (multiSample) {
        
            // choose a sample (there are two per octave)
            // and the interval to lower it by to get the desired pitch
            
            int sampleNum;
            int interval;
            
            if (num < 7) {
                sampleNum = octave * 2; // samples 0,2,4 are F#
                interval = (6 - num);
            } else {
                sampleNum = 1 + (octave * 2); // samples 1,3,5 are C
                interval = 6 - (num - 6);
            }
            
            myPlayers[sampleNum].play();
            myPlayers[sampleNum].setSpeed(1/ratios[interval]); // inverse ratio lowers the pitch
            
        } else {
            
            myPlayer.play();
            float myRatio = ratios[num];
            if (octave == 2) {
                myRatio *= 2;
            }
            if (octave == 0) {
                myRatio /= 2;
            }
            myPlayer.setSpeed(myRatio);
        }

    }
};


#endif
