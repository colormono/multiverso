import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import SimpleOpenNI.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class build extends PApplet {

// MULTIVERSO
// App v04: Animaciones al pasar sobre

//---------------------------------------------------------------

// Kinect

SimpleOpenNI context;

// Objetos
Personaje personajes[]; // Personajes
Escenario escenarios[]; // Escenarios
Objeto objetos[]; // Objetos

// Configuraci\u00f3n
boolean debug = true; // Debug
boolean debugCamera = true; // Debug Camara
PVector tracker; // Tracking
int personajeActual = 0; // Personaje inicial
int escenarioActual = 2; // Escenario inicial
boolean iniciar = false; // Bot\u00f3n para iniciar (temporal)

// Imagenes temp kinect
PImage p1cabeza, p1cuerpo, p1manod, p1manoi;
PImage p2cabeza, p2cuerpo, p2manod, p2manoi;

PVector last_vector = new PVector();
PVector user_velocity = new PVector();

//---------------------------------------------------------------

public void setup() {
  // Lienzo
  size(1024, 768, OPENGL);
  //frameRate(30);
  noStroke();

  // Arreglos
  personajes = new Personaje[0];
  escenarios = new Escenario[0];

  // Personaje ( float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name );
  Personaje p1 = new Personaje( 0, 600, mouseY, 235, 240, true, "pepe" );
  personajes = (Personaje[]) append(personajes, p1);

  // Escenario: Introducci\u00f3n
  Escenario e1 = new Escenario( "intro" );
  escenarios = (Escenario[]) append(escenarios, e1);

  // Escenario: S\u00f3tano
  Escenario e2 = new Escenario( "sotano" );
  escenarios = (Escenario[]) append(escenarios, e2);

  // Escenario: Monta\u00f1a
  Escenario e3 = new Escenario( "montana" );
  escenarios = (Escenario[]) append(escenarios, e3);

  // Inicializar un nuevo objeto contexto
  context = new SimpleOpenNI(this);

  // Habilitar la carga de imagen de profundidad 
  context.enableDepth();

  // Habilitar detecci\u00f3n de esqueleto para todas las juntas
  context.enableUser();
  context.setMirror(true);

  // Test Kinect
  if( context.isInit() == false ){
    println("La c\u00e1mara Kinect se encuentra conectada?");
    exit();
    return;
  }
  tracker = new PVector( 0, 0 );

  // Imagenes temp kinect  
  p1cabeza = loadImage("p1-cabeza.png");
  p1cuerpo = loadImage("p1-cuerpo.png");
  p1manod = loadImage("p1-mano-d.png");
  p1manoi = loadImage("p1-mano-i.png");
  
  p2cabeza = loadImage("p2-cabeza.png");
  p2cuerpo = loadImage("p2-cuerpo.png");
  p2manod = loadImage("p2-mano-d.png");
  p2manoi = loadImage("p2-mano-i.png");
}

//---------------------------------------------------------------

public void draw() {
  // Limpiar fondo
  background(100);
  rectMode(CENTER);
  imageMode(CENTER);

  // Actualizar imagen de c\u00e1mara
  context.update();

  // Tracker
  float _xt, _yt;
  _xt = personajes[personajeActual].posicion.x;
  _yt = personajes[personajeActual].posicion.y;
  tracker.x = map( _xt, 0, 600, width, -width );
  tracker.y = map( _yt, 0, height, 0, 10 );

  // Escenario: Esperando
  // Si detecta un usuario, enciende la aplicaci\u00f3n
  if ( escenarios[escenarioActual].estado.equals( "esperando" ) ) {
    escenarios[escenarioActual].esperar( iniciar );
  }

  // Escenario: Encendiendo
  // Animaci\u00f3n de entrada del escenario, crear universo
  if ( escenarios[escenarioActual].estado.equals( "encendiendo" ) ) {
    escenarios[escenarioActual].encender();
  }

  // Escenario: Prendido
  // Habilita la interacci\u00f3n del usuario con los objetos
  if ( escenarios[escenarioActual].estado.equals( "prendido" ) ) {

    // Escenario
    escenarios[escenarioActual].dibujar();
    
    // Detectar jugadores
    int [] userList = context.getUsers();
    for ( int i=0; i<userList.length; i++ ) {
      // Consultar si el esqueleto existe
      if (context.isTrackingSkeleton(userList[i])) {

        // Punto central
        PVector cuerpo = new PVector();
        context.getJointPositionSkeleton( userList[i], SimpleOpenNI.SKEL_TORSO, cuerpo );
        PVector cuerpo_2d = new PVector(); 
        context.convertRealWorldToProjective(cuerpo, cuerpo_2d);

        // Dibujar
        //drawSkeleton( userList[i] );
        dibujarCuerpo( userList[i], personajes[personajeActual].posicion.y );
        dibujarCabeza( userList[i], personajes[personajeActual].posicion.y );
        dibujarManoIzquierda( userList[i], personajes[personajeActual].posicion.y );
        dibujarManoDerecha( userList[i], personajes[personajeActual].posicion.y );

        //personajes[personajeActual].update(); // Players
        personajes[personajeActual].update(cuerpo_2d.x);
      }

      PVector world_pos = new PVector();
      PVector proj_pos = new PVector();
      context.getCoM(userList[i], world_pos);
      context.convertRealWorldToProjective(world_pos, proj_pos);
      
      user_velocity.x = proj_pos.x - last_vector.x;
      user_velocity.y = proj_pos.y - last_vector.y;
      
      pushMatrix();
      translate(proj_pos.x, proj_pos.y, 0);
      fill(255, 0, 100);
      ellipse(0, 0, 20, 20);
      fill(255);
      text(userList[i], 0, 0);
      popMatrix();
      
      last_vector = proj_pos;
    
    }

    // Fade
    escenarios[escenarioActual].prendido();
  }

  // Escenario: Apagando
  // Animaci\u00f3n de salida del escenario
  if ( escenarios[escenarioActual].estado.equals( "apagando" ) ) {
    escenarios[escenarioActual].apagar();
  }

  // Im\u00e1gen de c\u00e1mara
  if ( debugCamera ) {
    image(context.userImage(), width-160, 120, 320, 240);
  }

  // Mostrar informaci\u00f3n para debug
  if ( debug ) {
    // Informaci\u00f3n relativa
    pushStyle();
    rectMode(CORNER);
    fill(0, 200);
    rect(0, height-80, width, 80);
    fill( 0, 255, 0 );
    text("Escenario "+ escenarioActual + " - Estado: " + escenarios[escenarioActual].estado, 10, height-60 );
    text("Personaje "+ personajeActual + " - x=" + personajes[personajeActual].posicion.x, 10, height-40 );
    text("Tracker: x="+tracker.x+" - y="+tracker.y+" - z="+ tracker.z + " - Framerate: " + (int)frameRate, 10, height-20 );
    popStyle();
  }
}

//---------------------------------------------------------------

public void keyPressed() {
  // Debug
  if (key == 'd' || key == 'D') debug = !debug;
  if (key == 'c' || key == 'C') debugCamera = !debugCamera;

  // Controlar secuencias
  if (key == '1') escenarioActual = 0;
  if (key == '2') escenarioActual = 1;
  if (key == '3') escenarioActual = 2;
}
class Escenario {

  //.h
  String name; // Nombre (ruta de carpeta)
  String estado; // Estado inicial
  Objeto objetos[]; // Objetos
  int fade, fadeDuracion; // Fade

  // Constructor
  Escenario( String _name ) {
    name = _name;
    estado = "esperando";
    fade = 0;
    fadeDuracion = 60;
    objetos = new Objeto[0];
  }

  // Esperando usuario
  public void esperar( boolean _iniciar ) {
    // Si detecta blob, enciende
    if ( _iniciar ) {
      fade = 0;
      estado = "encendiendo";
    }
  }

  // Encender
  public void encender() {

    // Crear universo
    // Si name = "montana"...
    if( fade == 0 ){
      // Objeto ( float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name, int _reposo, int _hover, int _playing, int _special );
      objetos = (Objeto[]) append(objetos, new Objeto( 0, -125, 0.05f, 1365, 527, false, "cielo", 1, 0, 0, 0 ));
      objetos = (Objeto[]) append(objetos, new Objeto( 0, -125, 0.1f, 1068, 119, false, "nubes", 1, 0, 0, 0 ));
      objetos = (Objeto[]) append(objetos, new Objeto( 0, 100, 0.2f, 1498, 269, false, "montanas", 1, 0, 0, 0 ));
      objetos = (Objeto[]) append(objetos, new Objeto( 0, 270, 0.4f, 2048, 281, false, "piso", 1, 0, 0, 0 ));
      objetos = (Objeto[]) append(objetos, new Objeto( -400, 120, 0.5f, 533, 233, true, "dragon", 50, 25, 25, 25 ));
      objetos = (Objeto[]) append(objetos, new Objeto( 400, 0, 0.3f, 102, 60, true, "peceschicos", 1, 1, 0, 0 ));
      objetos = (Objeto[]) append(objetos, new Objeto( -500, -100, 0.3f, 205, 120, true, "peces", 1, 1, 0, 0 ));
      objetos = (Objeto[]) append(objetos, new Objeto( 900, 200, 0.6f, 168, 246, true, "hueco", 1, 1, 0, 0 ));
      objetos = (Objeto[]) append(objetos, new Objeto( 300, 180, 0.8f, 456, 480, true, "puerta", 1, 1, 0, 0 ));
      objetos = (Objeto[]) append(objetos, new Objeto( -1024, 300, 0.9f, 273, 98, true, "flor", 1, 1, 0, 0 ));
    }

    // fadeIn Blanco
    if ( fade < fadeDuracion ) {
      float _fade = map(fade, 0, fadeDuracion, 0, 255);
      fill(255, _fade);
      rect(width/2, height/2, width, height);
      fade ++;
    } else {
      fade = 0;
      estado = "prendido";
    }
  }

  // Prendido
  public void prendido() {    
    // fadeOut Blanco
    if ( fade < fadeDuracion ) {
      float _fade = map(fade, 0, fadeDuracion, 255, 0);
      fill(255, _fade);
      rect(width/2, height/2, width, height);
      fade ++;
    }
  }

  // Apagar
  public void apagar() {
    estado = "esperando";
  }

  // Dibujar
  public void dibujar() {
    for (int i = 0; i < objetos.length; i++) {
      objetos[i].update();
    }
  }
}
public void drawSkeleton(int userId) {
  pushStyle();
  stroke(0, 0, 255);
  strokeWeight(3);

  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);

  popStyle();
}

//---------------------------------------------------------------

public void dibujarCuerpo( int userId, float _y ) {
  // Crear un vector para obtener la posici\u00f3n
  PVector cuerpo = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_TORSO, cuerpo );
  // Crear un vector para proyectar en 2D
  PVector cuerpo_2d = new PVector(); 
  // Convertir la posici\u00f3n 3D al 2D de la pantalla
  context.convertRealWorldToProjective(cuerpo, cuerpo_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1cuerpo, cuerpo_2d.x, cuerpo_2d.y);
  }  else if ( userId == 2 ){
    image(p2cuerpo, cuerpo_2d.x, cuerpo_2d.y);
  }
}

//---------------------------------------------------------------

public void dibujarCabeza( int userId, float _y ) {
  // Crear un vector para obtener la posici\u00f3n
  PVector cabeza = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_HEAD, cabeza );
  // Crear un vector para proyectar en 2D
  PVector cabeza_2d = new PVector(); 
  // Convertir la posici\u00f3n 3D al 2D de la pantalla
  context.convertRealWorldToProjective(cabeza, cabeza_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1cabeza, cabeza_2d.x, _y-145);
  }  else if ( userId == 2 ){
    image(p2cabeza, cabeza_2d.x, _y-125);
  }
}

//---------------------------------------------------------------

public void dibujarManoIzquierda( int userId, float _y ) {
  // Crear un vector para obtener la posici\u00f3n
  PVector manoIzquierda = new PVector();
  PVector hombroIzquierdo = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_LEFT_HAND, manoIzquierda );
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, hombroIzquierdo );
  // Crear un vector para proyectar en 2D
  PVector manoIzquierda_2d = new PVector(); 
  PVector hombroIzquierdo_2d = new PVector(); 
  // Convertir la posici\u00f3n 3D al 2D de la pantalla
  context.convertRealWorldToProjective(manoIzquierda, manoIzquierda_2d);
  context.convertRealWorldToProjective(hombroIzquierdo, hombroIzquierdo_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1manoi, hombroIzquierdo_2d.x+manoIzquierda_2d.x*0.2f, _y-120-manoIzquierda_2d.y*0.3f);
  }  else if ( userId == 2 ){
    image(p2manoi, hombroIzquierdo_2d.x+manoIzquierda_2d.x*0.2f, _y-120-manoIzquierda_2d.y*0.3f);
  }
}

//---------------------------------------------------------------

public void dibujarManoDerecha( int userId, float _y ) {
  // Crear un vector para obtener la posici\u00f3n
  PVector manoDerecha = new PVector();
  PVector hombroDerecho = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_LEFT_HAND, manoDerecha );
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, hombroDerecho );
  // Crear un vector para proyectar en 2D
  PVector manoDerecha_2d = new PVector(); 
  PVector hombroDerecho_2d = new PVector(); 
  // Convertir la posici\u00f3n 3D al 2D de la pantalla
  context.convertRealWorldToProjective(manoDerecha, manoDerecha_2d);
  context.convertRealWorldToProjective(hombroDerecho, hombroDerecho_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1manoi, hombroDerecho_2d.x-manoDerecha_2d.x*0.2f, _y-120-manoDerecha_2d.y*0.3f);
  }  else if ( userId == 2 ){
    image(p2manoi, hombroDerecho_2d.x-manoDerecha_2d.x*0.2f, _y-120-manoDerecha_2d.y*0.3f);
  }
}

//---------------------------------------------------------------
// Al detectar nuevo usuario

public void onNewUser(SimpleOpenNI curContext, int userId) {
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  curContext.startTrackingSkeleton(userId);

  // Activar bot\u00f3n de iniciar
  iniciar = true;
}

//---------------------------------------------------------------
// Al perder usuario

public void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

//---------------------------------------------------------------
// Al ver usuario

public void onVisibleUser(SimpleOpenNI curContext, int userId) {
  //println("onVisibleUser - userId: " + userId);
}
class Objeto {

  //.h
  PVector posicion; // Posici\u00f3n X, Y, Z
  float x, y; // Posiciones absolutas
  int w, h; // Ancho y Alto
  boolean interactive; // Es interactivo?
  String name; // Nombre (ruta de carpeta)
  String estado; // Estados ["reposo","hover","playing","special"] // ["reposo","in","hover","out","special"]
  PImage [] reposo, hover, playing, special; // Animaciones
  int framesReposo, framesHover, framesPlaying, framesSpecial; // Contador de frames
  int frame; // Contador de frames

  // Constructor
  Objeto ( float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name, int _reposo, int _hover, int _playing, int _special ) {
    posicion = new PVector( _x, _y, _z );
    w = _w;
    h = _h;
    interactive = _interactive;
    name = _name;
    estado = "reposo";
    framesReposo  = _reposo;
    framesHover = _hover;
    framesPlaying = _playing;
    framesSpecial = _special;
    frame = 0;

    // loadImages( String nombre, String extensi\u00f3n, int cantidad_de_frames );
    reposo = loadImages(escenarios[escenarioActual].name+"/"+name+"/reposo_", ".png", _reposo);
    hover = loadImages(escenarios[escenarioActual].name+"/"+name+"/hover_", ".png", _hover);
    playing = loadImages(escenarios[escenarioActual].name+"/"+name+"/playing_", ".png", _playing);
    special = loadImages(escenarios[escenarioActual].name+"/"+name+"/special_", ".png", _special);
  }

  // Actualizar
  public void update() {
    x = width/2+posicion.x+tracker.x*posicion.z;
    y = height/2+posicion.y;

    dibujar();

    if( interactive ){
      colisionar();
    }
  }

  // Detectar colisiones
  public void colisionar() {
    for(int i=0; i<personajes.length; i++ ){
      if( 
        personajes[i].posicion.x >= x-w/2 && 
        personajes[i].posicion.x <= x+w/2 
      ) {
        // Cambiar estado
        estado = "hover";
        // Disparar sonido
        if(debug){
          fill(0,0,255,100);
          rect(x, y, w, h);
        }
      } else {
        // Reiniciar estado
        estado = "reposo";
      }
    }
  }

  // Dibujar
  public void dibujar() {
    pushMatrix();
    translate(x, y); // 2D
    //translate(x, y, tracker.y); // 3D
    if( estado.equals("reposo") ){
      if( frame < framesReposo ){
        image(reposo[frame], 0, 0, w, h);
        frame ++;
      } else {
        frame = 0;
        image(reposo[frame], 0, 0, w, h);
      }
    } 
    else if( estado.equals("hover") && hover.length>0 ){
      if( frame < framesHover ){
        image(hover[frame], 0, 0, w, h);
        frame ++;
      } else {
        frame = 0;
        image(hover[frame], 0, 0, w, h);
      }
    }
    popMatrix();
  }
}
class Personaje {

  //.h
  PVector posicion; // Posici\u00f3n X, Y, Z
  int w, h; // Ancho y Alto
  boolean interactive; // Es interactivo?
  String name; // Nombre (ruta de carpeta)
  String estado; // Estado inicial
  PImage [] animacion;  // Animaciones

  Personaje ( float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name ) {
    posicion = new PVector( _x, _y, _z );
    w = _w;
    h = _h;
    interactive = _interactive;
    name = _name;
    estado = "esperando";
    animacion = loadImages(name+"/", ".png", 2); // nombre, extenci\u00f3n, cantidad de frames
  }

  // Actualizar
  public void update(float _x) {
    posicion.x = _x;
    //posicion.x = mouseX;
    //dibujar();
  }

  // Esperando
  public void esperar() {
  }

  // Dibujar
  public void dibujar() {
    //image(animacion[0], posicion.x, posicion.y);
  }
}
//The MIT License (MIT)
//Copyright (c) 2013 Mick Grierson, Matthew Yee-King, Marco Gillies
//Permission is hereby granted, free of charge, to any person obtaining a copy\u2028of this software and associated documentation files (the "Software"), to deal\u2028in the Software without restriction, including without limitation the rights\u2028to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\u2028copies of the Software, and to permit persons to whom the Software is\u2028furnished to do so, subject to the following conditions:
//The above copyright notice and this permission notice shall be included in\u2028all copies or substantial portions of the Software.
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\u2028IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\u2028FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\u2028AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\u2028LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\u2028OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\u2028THE SOFTWARE.

public PImage [] loadImages(String name, String extension, int frames) {
  PImage [] images = new PImage[0];
  for ( int i=0; i < frames; i++ ) {
    // Use nf() to number format 'i' into five digits
    PImage img = loadImage(name+nf(i, 5)+extension);
    if (img != null) {
      images = (PImage [])append(images, img);
    } else {
      break;
    }
  }
  return images;
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#FFFFFF", "--hide-stop", "build" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
