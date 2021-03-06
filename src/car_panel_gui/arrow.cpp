#include "arrow.h"


Arrow::Arrow()
{
    resetValues();

    isFire = false;
}


void
Arrow::draw(void)
{
    if (isFire)
    {
        if (colorTime == 0)
        {
            colorG = colorG == 1.0f ? 0.1f : 1.0f;
            colorTime = timer;
        }
        colorTime--;
    }

    glColor3f(0.0f, colorG, 0.0f);
    glLineWidth(1.0f);

    glBegin(GL_POLYGON);
    {
        glVertex3f(-2.5, 80, 0);
        glVertex3f(-15, 80, 0);
        glVertex3f(0, 95, 0);
        glVertex3f(15, 80, 0);
        glVertex3f(2.5, 80, 0);
    }
    glEnd();
}


void
Arrow::blink(void)
{
    if (isFire)
    {
        resetValues();
    }

    isFire = !isFire;
}


void
Arrow::resetValues(void)
{
    colorG = 0.1f;
    colorTime = 0;
}
