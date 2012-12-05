#pragma once
//#include <iostream>
#include <vector>
//#include <Foundation/Foundation.h>
//#include <OpenGLES/EAGL.h>
//#include <GLKit/GLKit.h>

////
/// Basic Properties

struct RadarColor {
    RadarColor(){}
    RadarColor(float r, float g, float b, float a=0):r(r),g(g),b(b),a(a){}
    float r;
    float g;
    float b;
    float a;
    void copyToArray(float *array){
        array[0] = r;
        array[1] = g;
        array[2] = b;
        array[3] = a;
    }
};

struct RadarPosition {
    RadarPosition(){};
    RadarPosition(float x, float y):x(x),y(y){};
    float x;
    float y;
};

struct RadarSize {
    RadarSize(){};
    RadarSize(float width, float height):width(width),height(height){};
    float width;
    float height;
};


////
/// Shape

class RadarShapeSquare {
public:
    RadarShapeSquare(){};
    RadarPosition   position;
    RadarSize       size;
    float           vertices[8];
    float           numVertices;
    float           colors[16];
    void            draw();
    void            setTopColor(RadarColor color) {
        topColor = color;
        topColor.copyToArray(&colors[0]);
        topColor.copyToArray(&colors[4]);
    }
    void            setBottomColor(RadarColor color) {
        bottomColor = color;
        bottomColor.copyToArray(&colors[8]);
        bottomColor.copyToArray(&colors[12]);
    }
private:
    RadarColor      topColor;
    RadarColor      bottomColor;
};

RadarShapeSquare RadarShapeSquareMake(float x, float y, float width, float height);


typedef struct {
    RadarColor      color;
} RadarParticle;

//class RadarScanline {
//    std::vector<RadarParticle> particles;
//    double          angle;
//    double          time;
//    bool            isDead;
//};

float RadarMapFloat(float input, float inputMin, float inputMax, float outputMin, float outputMax);

class RadarScanline {
public:
//    RadarScanline(){
//        numParticles = 2;
//        vertices    = new float[numParticles * 4];
//        colors      = new float[numParticles * 8];
//    };
    RadarScanline(unsigned int numberOfParticles, float width, float height):numParticles(numberOfParticles),_height(height),_width(width){
        vertices    = new float[numParticles * 4];
        colors      = new float[numParticles * 8];
        setHeight(_height);
    };
    //  copy constructor
    RadarScanline(const RadarScanline& that):numParticles(that.numParticles),_height(that._height),_width(that._width){
        NSLog(@"Error broken!");
        NSLog(@"numb %d",numParticles);
        vertices    = new float[numParticles * 4];
        colors      = new float[numParticles * 8];
        for (int i=0; i < numParticles * 4; ++i) {
            vertices[i] = that.vertices[i];
        }
        for (int i=0; i < numParticles * 8; ++i) {
            colors[i] = that.colors[i];
            NSLog(@"%f", that.colors[i]);
        }
    }
    // 2. copy assignment operator
    RadarScanline& operator=(const RadarScanline& that) {
        NSLog(@"copy assing");
        numParticles = that.numParticles;
        _height = that._height;
        _width = that._width;
        vertices    = new float[numParticles * 4];
        colors      = new float[numParticles * 8];
        for (int i=0; i < numParticles * 4; ++i) {
            vertices[i] = that.vertices[i];
        }
        for (int i=0; i < numParticles * 8; ++i) {
            colors[i] = that.colors[i];
        }
        return *this;
    }
    virtual ~RadarScanline() {
        delete [] colors;
        delete [] vertices;
    }
    
    void    draw();
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
            if (i==numParticles-1) {
                NSLog(@"width at top: %f", width);
            }
            vertices[++needle] = -width;
            vertices[++needle] = newHeight;
            vertices[++needle] = width;
            vertices[++needle] = newHeight;
        }
    }
    void rotate(float degree, float x, float y, float z);
private:
    float   _height;
    float   _width;
    float   *colors;
    float   *vertices;
    unsigned int  numParticles;
};

class RadarSweeper {
public:
    typedef std::vector<RadarScanline *> Scanlines;
    typedef std::vector<RadarScanline *>::iterator ScanlinesIt;
    
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

