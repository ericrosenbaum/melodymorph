//
//  PolySynth.h
//  MelodyMorph
//
//  Created by Eric Rosenbaum on 2/14/14.
//
//

#ifndef MelodyMorph_PolySynth_h
#define MelodyMorph_PolySynth_h

#include "ofMain.h"
#include "ofxMaxim.h"

#include "ofMain.h"
#include "ofxMaxim.h"

class PolySynth {
    
    struct Voice {
        std::tr1::shared_ptr<ofxMaxiSample> sample;
        float speed;
        bool noteOn;
        int sampleNum;
        float amplitude;
        int ageSamples;
        Voice(std::tr1::shared_ptr<ofxMaxiSample> _sample){
            sample = _sample;
            sampleNum = 0;
            speed = 1;
            noteOn = false;
            amplitude = 1;
            ageSamples = 0;
        }
        Voice () {
        }
        void play(float _speed, int _sampleNum, int _length) {
            noteOn = true;
            speed = _speed;
            amplitude = 1;
            ageSamples = 0;
            sampleNum = _sampleNum;
            sample->length = _length;
            sample->trigger();
        }
    };
    
#define MULTI_SAMPLES_NUM 6
    
    bool multiSample;   // we have either one sample (false), or MULTI_SAMPLES_NUM samples (true)
    
    int numVoices = 8;

    vector<Voice> voices;
    
    ofxMaxiSample *theSamples[MULTI_SAMPLES_NUM];
    
    int sustainSamples = 44100;
    float decayMultiplier = .9999;
    
    convert mtof;
    maxiDyn compressor;
    
public:
    
    PolySynth() {
        
    }
    
    void loadSamples(string directoryName) {
        
        ofDirectory samplePaths = *new ofDirectory();
        int numSamples = samplePaths.listDir(directoryName);
        samplePaths.sort();
        
        if (numSamples == MULTI_SAMPLES_NUM) {
            multiSample = true;
            for (int i=0; i<numSamples; i++) {
                theSamples[i] = new ofxMaxiSample();
                theSamples[i]->load(ofToDataPath(samplePaths.getPath(i)));
            }
        } else {
            multiSample = false;
            theSamples[0] = new ofxMaxiSample();
            theSamples[0]->load(ofToDataPath(samplePaths.getPath(0)));
        }
        
        for (int i=0; i<numVoices; i++) {
            std::tr1::shared_ptr<ofxMaxiSample> sample(new ofxMaxiSample);
            sample->length = theSamples[0]->length;
            voices.push_back(Voice(sample));
        }
    }
    
    void playNote(int noteNum, int octave) {
        
        
        int sampleNum = 0;
        int interval = 0;
        float speed = 1;
        float baseFreq = mtof.mtof(60);
        
        if (multiSample) {
            
            // choose a sample (there are two per octave)
            // and the interval to lower it by to get the desired pitch
            if (noteNum < 7) {
                sampleNum = octave * 2; // samples 0,2,4 are F#
                interval = (6 - noteNum);
            } else {
                sampleNum = 1 + (octave * 2); // samples 1,3,5 are C
                interval = 6 - (noteNum - 6);
            }
            
            float freq = mtof.mtof(60 + interval);
            speed = 1/(freq/baseFreq);
            
        } else {
            float freq = mtof.mtof(noteNum + octave * 12 + 48);
            speed = freq/baseFreq;
        }
        
        int indexOfOldest = 0;
        for (int i=0; i<voices.size(); i++) {
            
            // if the sample has finished playing, turn it off
            if (voices[i].sample->position > voices[i].sample->length/2) {
                voices[i].noteOn = false;
            } else {
                // find the voice that has been playing longest, to use if all voices are in use
                if (voices[i].ageSamples > voices[indexOfOldest].ageSamples) {
                    indexOfOldest = i;
                }
            }
            
            // if this voice is not in use, turn it on and return
            if (!voices[i].noteOn) {
                voices[i].play(speed, sampleNum, theSamples[sampleNum]->length);
                return;
            }
        }
        
        // if we make it here, all notes are in use, so we "steal" the one that has been playing longest
        voices[indexOfOldest].play(speed, sampleNum, theSamples[sampleNum]->length);
    }
    
    float sampleRequested(){
        float sum = 0;
        for (int i=0; i<numVoices; i++) {
            if (voices[i].noteOn) {
                voices[i].ageSamples++;
                int sampleNum = voices[i].sampleNum;
                float s = voices[i].sample->playOnceFromSamp(theSamples[sampleNum]->temp, voices[i].speed);
                if (voices[i].ageSamples > sustainSamples) {
                    voices[i].amplitude *= decayMultiplier;
                    s *= voices[i].amplitude;
                }
                sum += s;
            }
        }
        return sum;
    }
    
    
    double getRMS (short arr[], int size)
    
    {
        int i;
        double sumsq;
        double RMS;
        sumsq = 0;
        
        
        for (i = 0; i< size; i++)
        {
            sumsq += arr[i]*arr[i];
        }
        RMS = sqrt((static_cast<double>(1)/size)*(sumsq));
        return RMS;
    }
    
};


#endif
