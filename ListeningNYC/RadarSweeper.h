#pragma once
#include <vector>

struct RadarColor {
    RadarColor(){};
    RadarColor(float r, float g, float b):r(r),g(g),b(b){};
    float r;
    float g;
    float b;
    float a;
};

float RadarMapFloat(float input, float inputMin, float inputMax, float outputMin, float outputMax);
float RadarMapQuasdEaseIn(float input, float inputMin, float inputMax, float outputMin, float outputMax);

class RadarScanline {
public:
    RadarScanline(unsigned int numberOfParticles, float width, float height):numParticles(numberOfParticles),_height(height),_width(width),drawsSinceLastAlphaUpdate(0) {
        vertices    = new float[numParticles * 4];
        colors      = new float[numParticles * 8];
        setHeight(_height);
    };
    virtual ~RadarScanline() {
        delete [] colors;
        delete [] vertices;
    }
    void draw();
    void hsvTransformColor(float hueDegrees, float saturation, float value, float alpha, unsigned int which);
    void setParticleHSVAColor(float h, float s, float v, float a, unsigned int which);
    void setParticleRGBAColor(float r, float g, float b, float a, unsigned int which) {
        unsigned int needle = which * 8;
        if (needle>numParticles * 8) {
            NSLog(@"Error: RadarScanline::setParticleColor trying to set to high a particle color");
            return;
        }
        colors[needle]   = r;
        colors[needle+1] = g;
        colors[needle+2] = b;
        colors[needle+3] = a;
        colors[needle+4] = r;
        colors[needle+5] = g;
        colors[needle+6] = b;
        colors[needle+7] = a;
    }
    RadarColor colorForParticle(int which) {
        RadarColor color;
        which = which * 8;
        color.r = colors[which];
        color.g = colors[which+1];
        color.b = colors[which+2];
        color.a = colors[which+3];
        return color;
    };
    void colorizeRandom() {
        for (int i=0; i<numParticles * 8; ++i) {
            colors[i] = (float)rand()/(float)RAND_MAX;
        }
    }
    void setAlpha(float alpha, unsigned int which) {
        //NSLog(@"setting alpha to %f", alpha);
        which = which * 8;
        colors[which+3] = alpha;
        colors[which+7] = alpha;
        drawsSinceLastAlphaUpdate = 0;
    }
    float getAlpha(unsigned int which) {
        which = which * 8;
        return colors[which+3];
    }
    void decayAlpha(float multiplier, unsigned int  which) {
        which = which * 8;
        float alpha = colors[which+3] * multiplier;
        colors[which+7] = alpha;
        colors[which+3] = alpha;
    }
    void setHeight(float height) {
        _height = height;
        float halfWidth = _width/2.0f;
        int needle = -1;
        for (int i = 0; i < numParticles; ++i) {
            float width = RadarMapFloat(i, 0, numParticles-1, 0.0f, halfWidth);
            float newHeight = RadarMapFloat(i, 0, numParticles-1, 0.0f, height);
            vertices[++needle] = -width;
            vertices[++needle] = newHeight;
            vertices[++needle] = width;
            vertices[++needle] = newHeight;
        }
    }
    void rotate(float degree, float x, float y, float z);
    unsigned int  getNumParticles() {
        return numParticles;
    }
    unsigned int drawsSinceLastAlphaUpdate;
private:
    float   _height;
    float   _width;
    float   *colors;
    float   *vertices;
    unsigned int numParticles;
};

typedef std::vector<RadarScanline *> Scanlines;
typedef std::vector<RadarScanline *>::iterator ScanlinesIt;

class RadarCurrentLine {
public:
    RadarCurrentLine(){}
    void setup(float startRadius, float endRadius, float width = 10.0f) {
        float vert[8] = {
            startRadius, 0.0f,      endRadius, 0.0f,
            startRadius, width,     endRadius, width
        };
        for (int i=0; i<8; ++i) {
            vertices[i] = vert[i];
        }
        
        float grey = 0.8f;
        float color[16] = {
            grey, grey, grey, 1.0f,
            grey, grey, grey, 1.0f,
            grey, grey, grey, 1.0f,
            grey, grey, grey, 1.0f
        };
        for (int i=0; i<16; ++i) {
            colors[i] = color[i];
        }
        currentRotation = 90.0f;
    };
    void draw();
    void setRotate(float degrees);
    
    virtual ~RadarCurrentLine() {};
protected:
    float vertices[8];
    float colors[16];
    float currentRotation;
};

class RadarSweeper {
public:

    RadarSweeper(unsigned int numScanlines, unsigned int particlesPerScanLine, float radius):numScanlines(numScanlines),decayRate(0.8),delayDecayForNumberOfDraws(10),drawsCurrentline(true){
        scanlines.reserve(numScanlines);
        float spreadDegree = 360.0f / float(numScanlines);
        currentline.setup(20.0f, radius, 1.0f);
        float width = radius * sinf( (spreadDegree / 2.0f) * M_PI/180.0f );
        float height = sqrt( (radius * radius) - (width * width) );
        float currentRotation = 180.0f;
        for (int i=0; i < numScanlines; ++i) {
            RadarScanline *scanline = new RadarScanline(particlesPerScanLine, width * 2, height);
            scanlines.push_back(scanline);
            scanline->rotate(currentRotation, 0.0f, 0.0f, 1.0f);
            currentRotation += spreadDegree;
        }
    }

    void setHues(float startHue, float endHue) {
        for (ScanlinesIt it = scanlines.begin(); it != scanlines.end(); ++it) {
            RadarScanline *scanline = *it;
            for (int i = 0; i < scanline->getNumParticles(); ++i) {
                float hue = RadarMapQuasdEaseIn(i, 0, scanline->getNumParticles(), startHue, endHue);
                scanline->setParticleHSVAColor(hue, 1.0f, 1.0f, 0.0f, i);
            }
        }
    }
    virtual ~RadarSweeper() {
        for (ScanlinesIt it = scanlines.begin(); it != scanlines.end(); ++it) {
            delete *it;
        }
        scanlines.clear();
    }
    
    float decayRate;
    unsigned int delayDecayForNumberOfDraws;
    void decay() {
        for (ScanlinesIt it = scanlines.begin(); it != scanlines.end(); ++it) {
            RadarScanline *scanline = *it;
            if (scanline->drawsSinceLastAlphaUpdate > delayDecayForNumberOfDraws) {
                for (int i = 0; i < scanline->getNumParticles(); ++i) {
                    scanline->decayAlpha(decayRate, i);
                }
            }
        }
    }
    
    void draw() {
        for (ScanlinesIt it = scanlines.begin(); it != scanlines.end(); ++it) {
            (*it)->draw();
        }
        if (drawsCurrentline) {
            currentline.draw();
        }
    }
    
    Scanlines scanlines;
    
    bool drawsCurrentline;
    RadarCurrentLine currentline;
private:
    unsigned int numScanlines;
};

