#include "RadarSweeper.h"
#include <OpenGLES/EAGL.h>
#include <GLKit/GLKit.h>

void RadarShapeSquare::draw() {
    // positions
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    // color
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, colors);
    // draw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    // disable
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribColor);
};

RadarShapeSquare RadarShapeSquareMake(float x, float y, float width, float height) {
    RadarShapeSquare squareShape;
    
    squareShape.position = RadarPosition(x,y);
    squareShape.size = RadarSize(width,height);
    
    float vertices[8] = {
        x - (width/2.0f), y - (height/2.0f),
        x + (width/2.0f), y - (height/2.0f),
        x - (width/2.0f), y + (height/2.0f),
        x + (width/2.0f), y + (height/2.0f),
    };
    std::memcpy(squareShape.vertices, vertices, sizeof(vertices));
    
    return squareShape;
};

float RadarMapFloat(float input, float inputMin, float inputMax, float outputMin, float outputMax) {
    float output = ((input-inputMin)/(inputMax-inputMin)*(outputMax-outputMin)+outputMin);
    if (outputMax < outputMin) {
        if (output < outputMax) {
            output = outputMax;
        }
        else if (output > outputMin) {
            output = outputMin;
        }
    } else {
        if (output > outputMax) {
            output = outputMax;
        }
        else if (output < outputMin) {
            output = outputMin;
        }
    }
    return output;
};


void RadarScanline::draw() {
    // positions
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    // color
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, colors);
    // draw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, numParticles * 2);
    // disable
    glDisableVertexAttribArray(GLKVertexAttribColor);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
}

void RadarScanline::rotate(float degrees, float x, float y, float z) {
    degrees = degrees * M_PI/180.0f;
    GLKMatrix4 rotationMatrix = GLKMatrix4MakeRotation(degrees, x, y, z);
    for (int i=0; i < numParticles*4; i += 2) {
        GLKVector3 rotatedVector = GLKMatrix4MultiplyVector3(rotationMatrix, GLKVector3Make(vertices[i], vertices[i+1], 0.0f));
        vertices[i] = rotatedVector.x;
        vertices[i+1] = rotatedVector.y;
    }
}