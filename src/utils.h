#ifndef _UTILS_ER
#define _UTILS_ER

#include "Poco/UUIDGenerator.h"

struct MorphMetaData {
    string author;
    string title;
    string description;
    string xmlFilePath;
    string largeThumbFilePath;
};

static float absf(float num) {
	if (num > 0) {return num;}
	else {return num * -1;}
}

static string noteNames(int n) {
	string noteNames[13] = {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "C"};
	return noteNames[n];
}

static int noteFunctions(int n) {
	int functions[13] = {0, 2, 1, 2, 0, 1, 2, 0, 2, 1, 2, 1, 0};
	return functions[n];
}

static string generateUUID() {
    Poco::UUIDGenerator &generator = Poco::UUIDGenerator::defaultGenerator();
    Poco::UUID uuid(generator.createRandom());
    return uuid.toString();
}

static void setColorHSV(float hue, float saturation, float value, int rgb[]) {
	float colorRange = 1;
	float red = 0;
	float green = 0;
	float blue = 0;
	if(value == 0) {
		red = 0;
		green = 0;
		blue = 0;
	} else if(saturation == 0) {
		red = value;
		green = value;
		blue = value;
	} else {
		float normalHue = (float) hue / (colorRange / 6.);
		float normalSaturation = (float) saturation / colorRange;
		int hueCategory = (int) floor(normalHue);
		float hueRemainder = normalHue - hueCategory;
		float pv = (1. - normalSaturation) * value;
		float qv = (1. - normalSaturation * hueRemainder) * value;
		float tv = (1. - normalSaturation * (1. - hueRemainder)) * value;
		switch(hueCategory) {
			case 0: // red
				red = value;
				green = tv;
				blue =  pv;
				break;
			case 1: // green
				red = qv;
				green = value;
				blue = pv;
				break;
			case 2:
				red = pv;
				green = value;
				blue = tv;
				break;
			case 3: // blue
				red = pv;
				green = qv;
				blue = value;
				break;
			case 4:
				red = tv;
				green = pv;
				blue = value;
				break;
			case 5: // back to red
				red = value;
				green = pv;
				blue = qv;
				break;
		}
	}
	float redVal = red * 255;
	float greenVal = green * 255;
	float blueVal = blue * 255;
	ofSetColor(redVal, greenVal, blueVal);
	
	rgb[0] = redVal;
	rgb[1] = greenVal;
	rgb[2] = blueVal;
}

#endif

