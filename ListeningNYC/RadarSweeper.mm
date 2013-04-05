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


float RadarMapQuasdEaseIn(float input, float inputMin, float inputMax, float outputMin, float outputMax) {
    input = (input-inputMin)/(inputMax-inputMin);
    input = input * input;
    float output = (input*(outputMax-outputMin)+outputMin);
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


// from SO: 
template<class Color>
void hsv2rgb(double inH, double inS, double inV, Color &out){
    double      hh, p, q, t, ff;
    long        i;
    
    if(inS <= 0.0) {       // < is bogus, just shuts up warnings
        if(isnan(inH)) {   // inH == NAN
            out.r = inV;
            out.g = inV;
            out.b = inV;
            return;
        }
        // error - should never happen
        out.r = 0.0;
        out.g = 0.0;
        out.b = 0.0;
        return;
    }
    hh = inH;
    if(hh >= 360.0) hh = 0.0;
    hh /= 60.0;
    i = (long)hh;
    ff = hh - i;
    p = inV * (1.0 - inS);
    q = inV * (1.0 - (inS * ff));
    t = inV * (1.0 - (inS * (1.0 - ff)));
    
    switch(i) {
        case 0:
            out.r = inV;
            out.g = t;
            out.b = p;
            break;
        case 1:
            out.r = q;
            out.g = inV;
            out.b = p;
            break;
        case 2:
            out.r = p;
            out.g = inV;
            out.b = t;
            break;
            
        case 3:
            out.r = p;
            out.g = q;
            out.b = inV;
            break;
        case 4:
            out.r = t;
            out.g = p;
            out.b = inV;
            break;
        case 5:
        default:
            out.r = inV;
            out.g = p;
            out.b = q;
            break;
    }
    return;     
}

void RadarScanline::setParticleHSVAColor(float h, float s, float v, float a, unsigned int which) {
    RadarColor color;
    hsv2rgb(h,s,v,color);
    setParticleRGBAColor(color.r, color.g, color.b, a, which);
}

void RadarScanline::draw() {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA_SATURATE, GL_ONE);
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
    glDisable(GL_BLEND);
    drawsSinceLastAlphaUpdate++;
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

void RadarCurrentLine::draw() {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ZERO);
    // positions
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    // color
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, 0, colors);
    // draw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    // disable
    glDisableVertexAttribArray(GLKVertexAttribColor);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisable(GL_BLEND);
}

void RadarCurrentLine::setRotate(float degrees) {
    float delta = degrees - currentRotation;
    float radians = (delta) * M_PI/180.0f;
    GLKMatrix4 rotationMatrix = GLKMatrix4MakeRotation(radians, 0.0, 0.0, 1.0);
    for (int i=0; i < 8; i += 2) {
        GLKVector3 rotatedVector = GLKMatrix4MultiplyVector3(rotationMatrix, GLKVector3Make(vertices[i], vertices[i+1], 0.0f));
        vertices[i] = rotatedVector.x;
        vertices[i+1] = rotatedVector.y;
    }
    currentRotation += delta;
}


