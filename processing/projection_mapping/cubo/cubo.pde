import processing.video.*;

Movie movFace0, movFace1, movFace2, movFace3, movFace4, movFace5;

PImage discMask;


//plasma
int pal []=new int [128];
int[] cls;

class Cubo extends PMObject3D {
    float a = 0.0;
    public Cubo (PApplet myparent) {
        super(myparent);
    }
    
    public void drawSurface(int surfaceId,PGraphics screen)
    {   
        screen.beginDraw();
        if (surfaceId == 0) {
            //screen.image(movFace0, 0, 0,  800, 800);
            screen.image(discMask, 0, 0);
        } else if (surfaceId == 1) {
            //screen.image(movFace1, 0, 0,  800, 800);
        } else if (surfaceId == 2) {            
            screen.image(movFace0, 0, 0,  800, 800);
          //  screen.image(movFace2, 0, 0,  800, 800);
            /*screen.background(0);
            screen.lights();
            
            screen.stroke(0,255,0);
            screen.pushMatrix();
            //screen.translate(width/2, height/2, 0);
            
            cubo.angle3d[0] = 0;
            //cubo.angle3d[1] = 30;
            a = cubo.angle3d[1];
            
            //a = a + 1;
            a = -a * 3.1415 / 180.0;
            screen.translate(400, 400, -100);
            
            screen.rotateY(a);
            
            //screen.rotateX(-0.4);
            //screen.rotateY(1.25);
            
            screen.box(200);
            screen.popMatrix();
            */

        } else if (surfaceId == 3) {
            screen.image(movFace1, 0, 0,  800, 800);
        } else if (surfaceId == 4) {
            screen.image(movFace2, 0, 0,  800, 800);
        } else if (surfaceId == 5) {
            //screen.image(movFace2, 0, 0,  800, 800);
        }  
        screen.endDraw();
    }
}

Cubo cubo;

void setup() {
    size(1600, 1000, P3D);
    cubo = new Cubo(this);
    
    discMask = loadImage("disc_mask.png");
    discMask.resize(800, 800);
    
    //plasma
    movFace0 = new Movie(this, "video.mov");
    movFace0.loop();
    movFace0.volume(0);
    movFace0.jump(random(movFace0.duration()));
    
    movFace1 = new Movie(this, "video.mov");
    movFace1.loop();
    movFace1.volume(0);
    movFace1.jump(random(movFace1.duration()));
    
    movFace2 = new Movie(this, "video.mov");
    movFace2.loop();
    movFace2.volume(0);
    movFace2.jump(random(movFace2.duration()));
    
   /* movFace3 = new Movie(this, "video.mov");
    movFace3.loop();
    movFace3.volume(0);
    movFace3.jump(random(movFace3.duration()));
    
    movFace4 = new Movie(this, "video.mov");
    movFace4.loop();
    movFace4.volume(0);
    movFace4.jump(random(movFace4.duration()));
    
    movFace5 = new Movie(this, "video.mov");
    movFace5.loop();
    movFace5.volume(0);
    movFace5.jump(random(movFace5.duration()));*/
}

float step = 1;

void draw() {    
    cubo.rotate3D(cubo.angle3d);   
    cubo.draw(); 

    //cubo.angle3d[1] += step;
}

void movieEvent(Movie m) {
  m.read();
}


void keyPressed() {
    //println(key);
    switch(key) {
    case 'w':
        if (cubo.zoom < 1000) {
            cubo.zoom += 1;
        } 
        break;        
    case 'q':
        if (cubo.zoom > 10) {
            cubo.zoom -= 1;
        } 
        break;

    case '-':
        if (cubo.perspective > -0.2) {
            cubo.perspective -= 0.001;
        } 
        break;
    case '=':
        if (cubo.perspective < 0.2) {
            cubo.perspective += 0.001;
        } 
        break;    

    case 'z':
        if (cubo.angle3d[0] < 60) {
            cubo.angle3d[0] += 1;
            cubo.angle3d[0] = cubo.angle3d[0] % 360;
        }            
        break;
    case 'a':
        if (cubo.angle3d[0] > -15) {
            cubo.angle3d[0] -= 1;
            cubo.angle3d[0] = cubo.angle3d[0] % 360;
        } 
        break;

    case 'x':
        cubo.angle3d[1] += 1;
        cubo.angle3d[1] = cubo.angle3d[1] % 360;                
        break;
    case 's':
        cubo.angle3d[1] -= 1;
        cubo.angle3d[1] = cubo.angle3d[1] % 360; 
        break;

    case 'c':
        cubo.angle3d[2] += 1;
        cubo.angle3d[2] = cubo.angle3d[2] % 360;                
        break;
    case 'd':
        cubo.angle3d[2] -= 1;
        cubo.angle3d[2] = cubo.angle3d[2] % 360; 
        break;
    
    case 'f':
        if (cubo.zoomDisc > 1.0) {
            cubo.zoomDisc -= 0.01;
        }            
        break;
    case 'v':
        if (cubo.zoomDisc < 5.0) {
            cubo.zoomDisc += 0.01;
        } 
        break;
 
    case 'b':
        if (cubo.centerx > -2000) {
            cubo.centerx -= 1;
        }            
        break;
    case 'g':
        if (cubo.centerx < 2000) {
            cubo.centerx += 1;
        } 
        break;
 
    case 'n':
        if (cubo.centery > -2000) {
            cubo.centery -= 1;
        }            
        break;
    case 'h':
        if (cubo.centery < 2000) {
            cubo.centery += 1;
        } 
        break;
 
    
    case ' ':
        cubo.calibrating = !cubo.calibrating;
                        
        break;
    }
    
     println(" ");
     println("cx: " + cubo.centerx + ", cy: " + cubo.centery);
     println("zoom: " + cubo.zoom + ", persective: " + cubo.perspective);
     println("ax: " + cubo.angle3d[0] + ", ay: " + cubo.angle3d[1]);
     //println("cx:" + cubo.centerx + ", cy:" + cubo.centery);
     //println("cx:" + cubo.centerx + ", cy:" + cubo.centery);
     //println("cx:" + cubo.centerx + ", cy:" + cubo.centery); 
      
}

