#include "RadarSweeper.h"
#include <OpenGLES/EAGL.h>
#include <GLKit/GLKit.h>

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

// http://beesbuzz.biz/code/hsv_color_transforms.php
template<class Color>
Color TransformHSV(
                   const Color &in,  // color to transform
                   float H,          // hue shift (in degrees)
                   float S,          // saturation multiplier (scalar)
                   float V           // value multiplier (scalar)
                   )
{
    float VSU = V*S*cos(H*M_PI/180);
    float VSW = V*S*sin(H*M_PI/180);
    
    Color ret;
    ret.r = (.299*V+.701*VSU+.168*VSW)*in.r
    + (.587*V-.587*VSU+.330*VSW)*in.g
    + (.114*V-.114*VSU-.497*VSW)*in.b;
    ret.g = (.299*V-.299*VSU-.328*VSW)*in.r
    + (.587*V+.413*VSU+.035*VSW)*in.g
    + (.114*V-.114*VSU+.292*VSW)*in.b;
    ret.b = (.299*V-.3*VSU+1.25*VSW)*in.r
    + (.587*V-.588*VSU-1.05*VSW)*in.g
    + (.114*V+.886*VSU-.203*VSW)*in.b;
    return ret;
}

void RadarScanline::hsvTransformColor(float hueDegrees, float saturation, float value, float alpha, unsigned int which) {
    RadarColor color = colorForParticle(which);
    color = TransformHSV(color, hueDegrees, saturation, value);
    setParticleRGBAColor(color.r, color.g, color.b, alpha, which);
}

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