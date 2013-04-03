#pragma once

void GLToolTest() {
    NSLog(@"drawing");
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // draw a basic triangle
    float vertices[] = {-1, -1,
        1, -1,
        0,  1};
    
    GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
    [effect prepareToDraw];
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
}

void GLToolProjectionMatrixEffectWithFrame(GLKBaseEffect *effect, const CGRect frame) {
    float left = -frame.size.width/2;
    float right = frame.size.width/2;
    float top = frame.size.height/2;
    float bottom = -frame.size.height/2;
    effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(left, right, top, bottom, 1.0f, -1.0f);
}

void GLToolTestTriangle(float width, float height) {
    float vertices[] = {
            -width, -height,
            width, -height,
            0,  height
    };
    
//    GLKBaseEffect *effect = [[GLKBaseEffect alloc] init];
//    [effect prepareToDraw];
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
}