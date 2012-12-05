#pragma once
#include <vector>

typedef struct {
    float r;
    float g;
    float b;
    float a;
} RadarColor;

float RadarMapFloat(float input, float inputMin, float inputMax, float outputMin, float outputMax);

class RadarScanline {
public:
    RadarScanline(unsigned int numberOfParticles, float width, float height):numParticles(numberOfParticles),_height(height),_width(width){
        vertices    = new float[numParticles * 4];
        colors      = new float[numParticles * 8];
        setHeight(_height);
    };
    virtual ~RadarScanline() {
        delete [] colors;
        delete [] vertices;
    }
    void    draw();
    void    hsvTransformColor(float hueDegrees, float saturation, float value, float alpha, unsigned int which);
    void    setParticleRGBAColor(float r, float g, float b, float a, unsigned int which) {
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
    void    colorizeRandom() {
        for (int i=0; i<numParticles * 8; ++i) {
            colors[i] = (float)rand()/(float)RAND_MAX;
        }
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
private:
    float   _height;
    float   _width;
    float   *colors;
    float   *vertices;
    unsigned int  numParticles;
};

typedef std::vector<RadarScanline *> Scanlines;
typedef std::vector<RadarScanline *>::iterator ScanlinesIt;

class RadarSweeper {
public:
    
    RadarSweeper(unsigned int numScanlines, unsigned int particlesPerScanLine, float radius):numScanlines(numScanlines){
        scanlines.reserve(numScanlines);
        float spreadDegree = 360.0f / float(numScanlines);
        float width = radius * sinf( (spreadDegree / 2.0f) * M_PI/180.0f );
        float height = sqrt( (radius * radius) - (width * width) );
        float currentRotation = 0.0f;
        for (int i=0; i < numScanlines; ++i) {
            RadarScanline *scanline = new RadarScanline(particlesPerScanLine, width * 2, height);
            scanlines.push_back(scanline);
            scanline->rotate(currentRotation, 0.0f, 0.0f, 1.0f);
            scanline->colorizeRandom();
            currentRotation += spreadDegree;
        }
    }
    virtual ~RadarSweeper() {
        for (ScanlinesIt it = scanlines.begin(); it != scanlines.end(); ++it) {
            delete *it;
        }
        scanlines.clear();
    }
    void draw() {
        for (ScanlinesIt it = scanlines.begin(); it != scanlines.end(); ++it) {
            (*it)->draw();
        }
    }
    Scanlines scanlines;
private:
    unsigned int numScanlines;
};

