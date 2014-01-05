//
//  SoundPlayerQueue.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 8/2/13.
//
//

#ifndef MelodyMorph_SoundPlayerQueue_h
#define MelodyMorph_SoundPlayerQueue_h


#include "ofMain.h"

#define QUEUE_LENGTH           10

class SoundPlayerQueue {
    
public:
    
    ofSoundPlayer myPlayerQueue[QUEUE_LENGTH];         
    int queueIndex = 0;
    
    float ratios[13] = {1, 1.05946309, 1.12246205, 1.18920712, 1.25992105, 1.33483985, 1.41421356, 1.49830708, 1.58740105, 1.68179283, 1.78179744, 1.88774863, 2};
    
    
    SoundPlayerQueue() {
        
    }
    
    void loadSamples(string directoryName){
        
        ofDirectory samplePaths = *new ofDirectory();
        int numSamples = samplePaths.listDir(directoryName);
        samplePaths.sort();
        
        for (int i=0; i<QUEUE_LENGTH; i++) {
            myPlayerQueue[i].loadSound(samplePaths.getPath(0));
            myPlayerQueue[i].setMultiPlay(false);
        }
    }
    
    void setVolume(int playerId, float vol) {
        myPlayerQueue[playerId].setVolume(vol);
    }
    
    int playNote(int num, int octave) {
        
        queueIndex++;
        queueIndex %= QUEUE_LENGTH;
        
        cout << "queueIndex " + ofToString(queueIndex) << endl;
        
        myPlayerQueue[queueIndex].play();
        
        float myRatio = ratios[num];
        if (octave == 2) {
            myRatio *= 2;
        }
        if (octave == 0) {
            myRatio /= 2;
        }
        myPlayerQueue[queueIndex].setSpeed(myRatio);
        
        return queueIndex;
        
    }
        
};



#endif
