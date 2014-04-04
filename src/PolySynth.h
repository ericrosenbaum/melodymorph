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
#include "Note.cpp"
#include "ofxMaxim.h"

class PolySynth : public ofThread {
    
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
            amplitude = 1;
            ageSamples = 0;
            speed = _speed;
            sampleNum = _sampleNum;
            sample->length = _length;
            sample->trigger();
        }
        void stop() {
            noteOn = false;
            amplitude = 1;
            ageSamples = 0;
        }
    };
    
#define MULTI_SAMPLES_NUM 6
    
    bool multiSample;   // we have either one sample (false), or MULTI_SAMPLES_NUM samples (true)
    
    int numVoices = 8;

    vector<Voice> voices;
    vector<Voice> rampVoices;
    vector<Note*> notesToPlay;
    float prevSum;

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
        
        // each polysynth has numVoices voices. each voice points to an ofxmaxisample sample
        // the actual sounds are stored as ofxmaxisamples in theSamples, so that we do not need
        // to store a copy of the sound in memory for each voice. for multisample instruments,
        // each voice can change which sample it points to when it gets triggered
        for (int i=0; i<numVoices; i++) {
            std::tr1::shared_ptr<ofxMaxiSample> sample(new ofxMaxiSample);
            sample->length = theSamples[0]->length;
            voices.push_back(Voice(sample));
        }        
    }
    
    void playNote(int noteNum, int octave) {
        Note *n = new Note();
        n->note = noteNum;
        n->octave = octave;
        
        lock();
        notesToPlay.push_back(n);
        unlock();
    }
    
    void playNoteInAudioThread(int noteNum, int octave) {
        
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
        
        for (int i=0; i<voices.size(); i++) {
            
            // if this voice is not in use, play the note and return
            if (!voices[i].noteOn) {
                voices[i].play(speed, sampleNum, theSamples[sampleNum]->length);
//                cout << "starting voice " << i << " sample->length: " << voices[i].sample->length << " sample->position: " << voices[i].sample->position << endl;
                return;
            }
        }
        
        // if we make it here, all notes are in use, so we "steal" the one that has been playing longest
        //
        // cout << "play oldest voice " << indexOfOldest << " with age " << voices[indexOfOldest].ageSamples <<endl;
        
        // find the voice that has been playing longest, to use if all voices are in use
        int indexOfOldest = 0;
        for (int i=0; i<voices.size(); i++) {
                if (voices[i].ageSamples > voices[indexOfOldest].ageSamples) {
                    indexOfOldest = i;
                }
        }
        
        // make a temporary ramp voice to taper off the end of the stolen note
        if (rampVoices.size() < 100) { // we probably shouldn't ever get this many! but it crashes over 1000+ for some reason
            float stolenSpeed = voices[indexOfOldest].speed;
            int stolenSampleNum = voices[indexOfOldest].sampleNum;
            float stolenPosition = voices[indexOfOldest].sample->position;
            float stolenAmplitude = voices[indexOfOldest].amplitude;

            std::tr1::shared_ptr<ofxMaxiSample> sample(new ofxMaxiSample);
            rampVoices.push_back(Voice(sample));
            rampVoices.back().play(stolenSpeed, stolenSampleNum, theSamples[stolenSampleNum]->length);
            rampVoices.back().sample->position = stolenPosition;
            rampVoices.back().amplitude = stolenAmplitude;
        }
        
        voices[indexOfOldest].play(speed, sampleNum, theSamples[sampleNum]->length);
//        cout << "STEAL starting voice " << indexOfOldest << " sample->length: " << voices[indexOfOldest].sample->length << " sample->position: " << voices[indexOfOldest].sample->position << endl;


    }
    
    float sampleRequested(){
        
        lock();
        
        int numNotes = notesToPlay.size();
      
        for (vector<Note *>::iterator it = notesToPlay.begin() ; it != notesToPlay.end(); ++it) {
            playNoteInAudioThread((*it)->note, (*it)->octave);
        }

        
        if (notesToPlay.size() != numNotes) {
            cout << "we must have missed a note! before: " << numNotes << " after: " << notesToPlay.size() << endl;
        }
        
        notesToPlay.clear();
        
        unlock();
        
        float sum = 0;
        for (int i=0; i<numVoices; i++) {
            if (voices[i].noteOn) {
            
                // if the voice has finished playing, turn it off
                if (voices[i].sample->position > voices[i].sample->length) {
                    voices[i].stop();
                }
                
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
        
        // linear decay ramp voices to zero
        for (int i=0; i<rampVoices.size(); i++) {
            rampVoices[i].amplitude -= 0.001;
            if (rampVoices[i].amplitude < 0) {
                rampVoices[i].amplitude = 0;
            }
        }
        
        // if the oldest ramp voice is finished playing, remove it
        if (rampVoices.size() > 0) {
            if (rampVoices[0].amplitude < 0.001) {
                rampVoices.erase(rampVoices.begin());
            }
        }
        
        // play all ramps
        for (int i=0; i<rampVoices.size(); i++) {
            float r = rampVoices[i].sample->playOnceFromSamp(theSamples[rampVoices[i].sampleNum]->temp, rampVoices[i].speed);
            r *= rampVoices[i].amplitude;
            sum += r;
        }
        
        return sum;
    }
    
};


#endif
