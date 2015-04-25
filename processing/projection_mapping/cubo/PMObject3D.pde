/*
This library supports rotating video projection mapping

It requires a cubic projection screen. The library will enable users to map any Processing content on each face of this cube

The output (camera view) can be rotated, zoomed in and out and can also have its perspective changed, in order to adjust the projected cube into the vertices of the real-world cube (The projection screen)

The cube can be rotated only on Y axis. Camera can be rotated only on X axis.

In order to add your own content, extend the class PMObject3D on your sketch, and create your own implementation of the following method. It will be called on every 'draw' loop. 
    public void drawSurface(int surfaceId,PGraphics screen)

-------------------------------------------------------------------------------------------------------
Author: Alex Porto
Date: 19-Mar-2015
-------------------------------------------------------------------------------------------------------
*/

import deadpixel.keystone.*;

class PMSurface {
    float[][]vertices3D = { 
        {
            -1.0, -1.0, -1.0
        }
        , {
            -1.0, 1.0, -1.0
        }
        , {
            1.0, 1.0, -1.0
        }
        , {
            1.0, -1.0, -1.0
        }
    };
    float[][]vertices2D = { 
        {
            -1.0, -1.0
        }
        , {
            -1.0, 1.0
        }
        , {
            1.0, 1.0
        }
        , {
            1.0, -1.0
        }
    };
    Boolean visibility;
    CornerPinSurface ksSurface;
    PGraphics screen;
    float [][]oldMeshXY = { {0,0},{800,0},{800,800},{0,800} };
    //Boolean meshInitialized = false;
}  


class PMObject3D { 
    ArrayList<PMSurface> surfaces;
    Boolean calibrating = true;
    Keystone ks;
    float perspective = 0.0;
    float [] angle3d = {15, 0, 0};
    float zoom = 311;
    float zoomDisc = 2;
    float centerx =749;
    float centery = 591;
    
    public PMObject3D (PApplet myparent) {  
        float[][][] cubo = 
        {
            {    // face de baixo
                {
                    -1.0, 1.0, -1.0
                }
                , {
                    1.0, 1.0, -1.0
                }
                , {
                    1.0, 1.0, 1.0
                }
                , {
                    -1.0, 1.0, 1.0
                }
            },           
             
            { // face topo
                {
                    -1.0, -1.0, -1.0
                }
                , {
                    1.0, -1.0, -1.0
                }
                , {
                    1.0, -1.0, 1.0
                }
                , {
                    -1.0, -1.0, 1.0                    
                }
            },
            { // face frontal
                {
                    -1.0, -1.0, 1.0
                }
                , {
                    1.0, -1.0, 1.0
                }
                , {
                    1.0, 1.0, 1.0
                }
                , {
                    -1.0, 1.0, 1.0
                }
            }
            , 
            { // face esquerda
                {
                    -1.0, -1.0, -1.0
                }
                , {
                    -1.0, -1.0, 1.0
                }
                , {
                    -1.0, 1.0, 1.0                    
                }
                , {
                    -1.0, 1.0, -1.0
                }
            }
            , 
            {
                { // face direita
                    1.0, -1.0, 1.0
                }
                , {
                    1.0, -1.0, -1.0   
                }
                , {
                    1.0, 1.0, -1.0                                        
                }
                , {                    
                    1.0, 1.0, 1.0
                }
            }
            , 
            {
                { // face do fundo
                    1.0, -1.0, -1.0
                }
                , {
                    -1.0, -1.0, -1.0
                }
                , {
                    -1.0, 1.0, -1.0
                }
                , {
                    1.0, 1.0, -1.0                    
                }
            }
        };

        //centerx = width / 2;
        //centery = height / 2;
        
        ks = new Keystone(myparent);
        surfaces = new ArrayList<PMSurface>();
        for (int s=0; s < cubo.length; s++) {            
            PMSurface surface = new PMSurface();
            surface.ksSurface = ks.createCornerPinSurface(800, 800, 20);
            surface.screen = createGraphics(800, 800, P3D); 
            for (int v=0; v < 4; v++) {
                for (int p=0; p < 3; p++) {
                    surface.vertices3D[v][p] = cubo[s][v][p];
                }
            }
            surfaces.add(surface);
        }
    } // Constructor

    public void rotate3D (float[] angle3d)
    {    
       /* float ax=0;
        float ay=0;
        float az=0;
        float bx=0;
        float by=0;
        float bz=0;
        
        float []xp= {0,0,0,0};
        */
        for (int s=0; s < surfaces.size(); s++) {            
            PMSurface surface = surfaces.get(s);
            for (int vertice=0; vertice < 4; vertice++) {                
                float x3d = surface.vertices3D[vertice][0];
                float y3d = surface.vertices3D[vertice][1];   
                float z3d = surface.vertices3D[vertice][2];
                
                if (s == 0) {
                    // permitindo o ajuste do tamanho de baixo (disco) pode ser calibrada
                    x3d = x3d * zoomDisc;
                    z3d = z3d * zoomDisc;
                }
    
                float x2d = 0;
                float y2d = 0;
                float z2d = 0;
    
                float xaxis = 0;
                float yaxis = 0;   
                float zaxis = 0;
    
                float [][] matrix = {
                    {
                        0, 0, 0
                    }
                    , {
                        0, 0, 0
                    }
                    , {
                        0, 0, 0
                    }
                };    
                for (int axis = 1; axis < 3; axis++) { // x, y, z        
                    if (axis == 1) {
                        xaxis = 0;
                        yaxis = 1;
                    } else {
                        if (axis == 2) {
                            yaxis = 0;
                            zaxis = 1;
                        }
                    }
    
                    float sn = sin(angle3d[axis] * 3.1415 / 180.0);
                    float cs = cos(angle3d[axis] * 3.1415 / 180.0);
    
                    float xSin = xaxis * sn;
                    float ySin = yaxis * sn;
                    float zSin = zaxis * sn;  
                    float oneMinusCS = 1.0f - cs;
                    float xym = xaxis * yaxis * oneMinusCS;
                    float xzm = xaxis * zaxis * oneMinusCS;
                    float yzm = yaxis * zaxis * oneMinusCS;
    
                    matrix[0][0] = (xaxis * xaxis) * oneMinusCS + cs;
                    matrix[0][1] = xym + zSin;
                    matrix[0][2] = xzm - ySin;
                    matrix[1][0] = xym - zSin;
                    matrix[1][1] = (yaxis * yaxis) * oneMinusCS + cs;
                    matrix[1][2] = yzm + xSin;
                    matrix[2][0] = xzm + ySin;
                    matrix[2][1] = yzm - xSin;
                    matrix[2][2] = (zaxis * zaxis) * oneMinusCS + cs;
    
                    x2d = matrix[0][0] * x3d + matrix[0][1] * y3d + matrix[0][2] * z3d;
                    y2d = matrix[1][0] * x3d + matrix[1][1] * y3d + matrix[1][2] * z3d;
                    z2d = matrix[2][0] * x3d + matrix[2][1] * y3d + matrix[2][2] * z3d;
                    
                    
                    //x2d = x2d * (0.05 * z2d + 0.95);
                    //y2d = y2d * (0.05 * z2d + 0.95);
                    x2d = x2d * (perspective * z2d + (1-perspective));
                    y2d = y2d * (perspective * z2d + (1-perspective));
    
                    x3d = x2d; 
                    y3d = y2d; 
                    z3d = z2d;
                }
                
                /*if (vertice == 0) {
                    ax = x3d; ay = y3d; az = z3d;
                    bx = x3d; by = y3d; bz = z3d;                    
                }                 
                if (vertice == 1) {
                    ax = x3d - ax; ay = y3d - ay; az = z3d - az;                    
                }
                if (vertice == 3) {
                    bx = x3d - bx; by = y3d - by; bz = z3d - bz;                    
                }*/
    
                // No eixo x rotacionamos a camera, nao o objeto
    
                float sn = sin(angle3d[0] * 3.1415 / 180.0);
                float cs = cos(angle3d[0] * 3.1415 / 180.0);
    
                xaxis = 1;
                yaxis = 0;   
                zaxis = 0;
    
                float xSin = xaxis * sn;
                float ySin = yaxis * sn;
                float zSin = zaxis * sn;  
                float oneMinusCS = 1.0f - cs;
                float xym = xaxis * yaxis * oneMinusCS;
                float xzm = xaxis * zaxis * oneMinusCS;
                float yzm = yaxis * zaxis * oneMinusCS;    
    
                matrix[0][0] = (xaxis * xaxis) * oneMinusCS + cs;
                matrix[0][1] = xym + zSin;
                matrix[0][2] = xzm - ySin;
                matrix[1][0] = xym - zSin;
                matrix[1][1] = (yaxis * yaxis) * oneMinusCS + cs;
                matrix[1][2] = yzm + xSin;
                matrix[2][0] = xzm + ySin;
                matrix[2][1] = yzm - xSin;
                matrix[2][2] = (zaxis * zaxis) * oneMinusCS + cs;
    
                x2d = matrix[0][0] * x3d + matrix[0][1] * y3d + matrix[0][2] * z3d;
                y2d = matrix[1][0] * x3d + matrix[1][1] * y3d + matrix[1][2] * z3d;
                z2d = matrix[2][0] * x3d + matrix[2][1] * y3d + matrix[2][2] * z3d;
                
                x2d = x2d * (perspective * z2d + (1-perspective));
                y2d = y2d * (perspective * z2d + (1-perspective));
                
                //xp[vertice]= x2d;
                //x2d = x2d * (z2d / perspective);
                //y2d = y2d * (z2d / perspective);
                
                
                //----
                
              
    
                //----
    
                //x2d = centerx + x2d * (zoom + z2d * perspective);
                //y2d = centery + y2d * (zoom+ z2d * perspective);  
                x2d = centerx + x2d * (zoom);
                y2d = centery + y2d * (zoom);
                surface.vertices2D[vertice][0] = x2d;
                surface.vertices2D[vertice][1] = y2d;
            } // vertices
            
            // calcula a normal da superficie
            /*float nx = ay*bz - az*by;
            //float ny = ax*bz - az*bx;
            float ny = az*bx - ax*bz;
            float nz = ax*by - ay*bx;
            
            // ponto de origem da camera (vetor da camera)
            float cx = 0;
            float cy = angle3d[0];
            float cz = 100;
            
            // calcula N.C (produto escalar entre normal e camera)
            float dot = cx * nx + cy * ny + cz * nz;
            
            // calcula modulo de vetor camera e modulo de vetor normal
            float mc = sqrt(cx*cx + cy*cy + cz*cz);
            float mn = sqrt(nx*nx + ny*ny + nz*nz);
            
            // calcula a visibilidade usando o angulo entre a normal da superficie e o vetor da camera
            surface.visibility = dot / (mc*mn);*/
            
            if (s < 2) {
                surface.visibility = true;
            } else {
                surface.visibility = (surface.vertices2D[0][0] < surface.vertices2D[1][0]) && (surface.vertices2D[0][0] < surface.vertices2D[2][0]); 
                //surface.visibility = (xp[0] <= xp[1]) && (xp[0] <= xp[2]);
            }
                        
            // Ajusta os 4 cantos do warped meshsurface.ksSurface.moveMeshPointBy(CornerPinSurface.TL, surface.vertices2D[0][0] - surface.oldMeshXY[0][0], surface.vertices2D[0][1] - surface.oldMeshXY[0][1]);
	    surface.ksSurface.moveMeshPointBy(CornerPinSurface.TL, surface.vertices2D[0][0] - surface.oldMeshXY[0][0], surface.vertices2D[0][1] - surface.oldMeshXY[0][1]);
            surface.ksSurface.moveMeshPointBy(CornerPinSurface.TR, surface.vertices2D[1][0] - surface.oldMeshXY[1][0], surface.vertices2D[1][1] - surface.oldMeshXY[1][1]);
            surface.ksSurface.moveMeshPointBy(CornerPinSurface.BR, surface.vertices2D[2][0] - surface.oldMeshXY[2][0], surface.vertices2D[2][1] - surface.oldMeshXY[2][1]);
            surface.ksSurface.moveMeshPointBy(CornerPinSurface.BL, surface.vertices2D[3][0] - surface.oldMeshXY[3][0], surface.vertices2D[3][1] - surface.oldMeshXY[3][1]);
            
            for (int i=0; i < 4; i++) {
                for (int j=0; j < 2; j++) {
                    surface.oldMeshXY[i][j] = surface.vertices2D[i][j];
                }
            }
            
            surfaces.set(s, surface);
        } // for surfaces
        //return ret;
    } //rotate3D
    
    public void drawSurface(int surfaceId,PGraphics screen)
    {   
   
    }
    
    public void draw() 
    {
        if (calibrating) {
            background(0, 0, 100);  
            strokeWeight(1);
            stroke(0, 0, 150);
            for (int y=0; y < 20; y++) {
                line(0, height / 20 * y, width, height / 20 * y);
            }
            for (int x=0; x < 20; x++) {
                line(width / 20 * x, 0, width / 20 * x, height);
            }
        } else {        
            background(0);
        }
        for (int s=0; s < surfaces.size(); s++) {
            if (surfaces.get(s).visibility) {
                //if (s == 2) {
                    drawSurface(s, surfaces.get(s).screen);
                    surfaces.get(s).ksSurface.render(surfaces.get(s).screen);
                //}
            }
        }
        if (calibrating) {       

            strokeWeight(1);
            stroke(255, 0, 0);
            for (int s=0; s < surfaces.size(); s++) {
                if (s == 2) {
                    if (surfaces.get(s).visibility) {
                        noFill();
                        //fill(150, 0, 0, 100);
                    } else {
                        noFill();
                    }
                } else {
                    noFill();
                }
        
                beginShape();         
                for (int v=0; v < 4; v++) {            
                    float x2d = surfaces.get(s).vertices2D[v][0];
                    float y2d = surfaces.get(s).vertices2D[v][1];
                    vertex(x2d, y2d);
                }
                // repete o primeiro vertice pra fechar o shape
                float x2d = surfaces.get(s).vertices2D[0][0];
                float y2d = surfaces.get(s).vertices2D[0][1];
                vertex(x2d, y2d);
                endShape();
                           
                if (surfaces.get(s).visibility) {    
                                        
                    float x2d1 = surfaces.get(s).vertices2D[2][0];
                    float y2d1 = surfaces.get(s).vertices2D[2][1];
                    line(x2d, y2d, x2d1, y2d1);
                    
                    x2d = surfaces.get(s).vertices2D[1][0];
                    y2d = surfaces.get(s).vertices2D[1][1];                
                    x2d1 = surfaces.get(s).vertices2D[3][0];
                    y2d1 = surfaces.get(s).vertices2D[3][1];                    
                    line(x2d, y2d, x2d1, y2d1);                    
                }
            }
        } // draw wireframe if calibratin       
    } 
    
} // class   

