import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import SimpleOpenNI.*; 
import processing.video.*; 
import oscP5.*; 
import netP5.*; 

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


// OSC



// Objetos y controles
Personaje personajes[]; // Personajes
Escenario escenarios[]; // Escenarios
Objeto objetos[]; // Objetos
OscP5 oscP5; // Objeto OSC
NetAddress direccionRemota; // Direcci\u00f3n remota
int puerto; // Puerto de salida OSC
boolean llave = false; // Llave para pasar de nivel
boolean pasarNivel = false; // Llave para pasar de nivel
int frame = 0;
int timer = 0;

// Configuraci\u00f3n
boolean debug = false; // Debug
boolean debugCamera = false; // Debug Camara
boolean kinect = true; // Using kinect
PVector tracker; // Tracking
int estadoApp = 0; // Arrancar desde la intro (LoopIntro=0, 1=Video, 2=Nivel, 3=VideoLlave)
int personajeActual = 0; // Personaje inicial (Pepe = 0)
int escenarioActual = 0; // Escenario inicial (Sotano = 0)
boolean iniciar = false; // Bot\u00f3n para iniciar (temporal)

// Imagenes y videos
PImage p1cabeza, p1cuerpo, p1manod, p1manoi;
PImage p2cabeza, p2cuerpo, p2manod, p2manoi;
PImage llaveApagada, llavePrendida, ojo;
Movie bucle, intro, cofre;
Eye ojo1;

//---------------------------------------------------------------

public void setup() {
  // Lienzo
  size(1024, 768, OPENGL);
  noStroke();

  // OSC
  puerto = 11112;
  oscP5 = new OscP5(this, puerto);
  direccionRemota = new NetAddress("127.0.0.1", puerto);

  // Crear Personajes
  // Personaje ( float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name );
  personajes = new Personaje[0];
  Personaje p1 = new Personaje( 0, 500, mouseY, 235, 240, true, "pepe" );
  personajes = (Personaje[]) append(personajes, p1);
  p1cabeza = loadImage("personajes/p1-cabeza.png");
  p1cuerpo = loadImage("personajes/p1-cuerpo.png");
  p1manod = loadImage("personajes/p1-mano-d.png");
  p1manoi = loadImage("personajes/p1-mano-i.png");
  p2cabeza = loadImage("personajes/p2-cabeza.png");
  p2cuerpo = loadImage("personajes/p2-cuerpo.png");
  p2manod = loadImage("personajes/p2-mano-d.png");
  p2manoi = loadImage("personajes/p2-mano-i.png");
  ojo = loadImage("sotano/ojo.png");

  // Llaves
  llaveApagada = loadImage("ui/llaveOFF.png");
  llavePrendida = loadImage("ui/llaveON.png");

  // Videos
  bucle = new Movie(this, "intro/loop.mov");
  intro = new Movie(this, "intro/intro.mov");
  cofre = new Movie(this, "intro/cofre.mov");
  bucle.loop();

  // Crear Universos de Objetos
  // Objeto ( int _universo, float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name, int _reposo, int _hover, int _playing, int _special, int _sonido );
  escenarios = new Escenario[0];

  // Escenario: S\u00f3tano
  Escenario e1 = new Escenario( "sotano" );
  escenarios = (Escenario[]) append(escenarios, e1);
  escenarios[0].objetos = (Objeto[]) append(escenarios[0].objetos, new Objeto( 0, 0, 0, 0.1f, 1365, 768, false, "fondo", 1, 0, 0, 0, 0 ));
  escenarios[0].objetos = (Objeto[]) append(escenarios[0].objetos, new Objeto( 0, -400, 200, 0.2f, 200, 200, true, "cofre", 1, 23, 0, 0, 0 ));
  escenarios[0].objetos = (Objeto[]) append(escenarios[0].objetos, new Objeto( 0, 300, 0, 0.1f, 215, 491, true, "llaveSotano", 1, 1, 0, 0, 0 ));
  ojo1 = new Eye( 100,  180, 40);

  // Escenario: Monta\u00f1a
  Escenario e2 = new Escenario( "montana" );
  escenarios = (Escenario[]) append(escenarios, e2);
  escenarios[1].objetos = (Objeto[]) append(escenarios[1].objetos, new Objeto( 1, 0, -125, 0.05f, 1365, 527, false, "cielo", 1, 0, 0, 0, 0 ));
  escenarios[1].objetos = (Objeto[]) append(escenarios[1].objetos, new Objeto( 1, 0, -125, 0.1f, 1068, 119, false, "nubes", 1, 0, 0, 0, 0 ));
  escenarios[1].objetos = (Objeto[]) append(escenarios[1].objetos, new Objeto( 1, 0, 100, 0.2f, 1498, 269, false, "montanas", 1, 0, 0, 0, 0 ));
  escenarios[1].objetos = (Objeto[]) append(escenarios[1].objetos, new Objeto( 1, 0, 270, 0.4f, 2048, 281, false, "piso", 1, 0, 0, 0, 0 ));
  escenarios[1].objetos = (Objeto[]) append(escenarios[1].objetos, new Objeto( 1, -400, 120, 0.5f, 533, 233, true, "dragon", 50, 46, 0, 25, 4 ));
  escenarios[1].objetos = (Objeto[]) append(escenarios[1].objetos, new Objeto( 1, 400, 0, 0.3f, 102, 60, true, "peces", 24, 24, 0, 0, 2 ));
  escenarios[1].objetos = (Objeto[]) append(escenarios[1].objetos, new Objeto( 1, -500, -100, 0.3f, 205, 120, true, "peces", 24, 24, 0, 0, 2 ));
  escenarios[1].objetos = (Objeto[]) append(escenarios[1].objetos, new Objeto( 1, 700, 200, 0.6f, 168, 246, true, "hueco", 1, 89, 0, 0, 8 ));
  escenarios[1].objetos = (Objeto[]) append(escenarios[1].objetos, new Objeto( 1, 350, 140, 0.8f, 300, 450, true, "puerta", 1, 24, 0, 24, 5 ));
  escenarios[1].objetos = (Objeto[]) append(escenarios[1].objetos, new Objeto( 1, -500, 160, 0.9f, 200, 200, true, "flor", 1, 32, 0, 0, 9 ));
  // Iniciar sonido ambiente
  OscMessage _audio = new OscMessage("/audio");
  _audio.add(1);
  oscP5.send(_audio, direccionRemota);

  // Escenario: Street Fighter
  Escenario e3 = new Escenario( "fighter" );
  escenarios = (Escenario[]) append(escenarios, e3);
  escenarios[2].objetos = (Objeto[]) append(escenarios[2].objetos, new Objeto( 2, 0, 0, 0.2f, 2600, 768, false, "fondo", 1, 0, 0, 0, 0 ));


  // Si se est\u00e1 utilizando la Kinect
  if ( kinect ) {

    // Inicializar un nuevo objeto contexto
    context = new SimpleOpenNI(this);
    context.setMirror(true);

    // Habilitar la carga de imagen de profundidad 
    context.enableDepth();

    // Habilitar detecci\u00f3n de esqueleto para todas las juntas
    context.enableUser();

    // Test Kinect
    if( context.isInit() == false ){
      println("La c\u00e1mara Kinect se encuentra conectada?");
      exit();
      return;
    }

  }
  tracker = new PVector( 0, 0 );
}

//---------------------------------------------------------------

public void draw() {

  // Limpiar fondo
  background(0);
  rectMode(CENTER);
  imageMode(CENTER);

  // Tracker
  float _xt, _yt;
  if ( kinect ) {
    context.update(); // Actualizar imagen de c\u00e1mara
    _xt = personajes[personajeActual].posicion.x;
    _yt = personajes[personajeActual].posicion.y;
    tracker.x = constrain( map( _xt, 0, 500, width, -width ), -1024, 1024);
    tracker.y = map( _yt, 0, height, 0, 10 );
  } else {
    _xt = mouseX;
    _yt = mouseY;
    tracker.x = map( _xt, 0, width, width, -width );
    tracker.y = map( _yt, 0, height, 0, 10 );
  }

  // Estado
  if( estadoApp == 0 ){
    // Loop
    pushStyle();
    imageMode(CORNER);
    bucle.read();
    image(bucle, 0, 0);
    popStyle();
  } 
  else if( estadoApp == 1 ){
    // Loop
    pushStyle();
    imageMode(CORNER);
    intro.read();
    image(intro, 0, 0);
    popStyle();
    float md = intro.duration();
    float mt = intro.time();
    if (mt >= md) {
      estadoApp = 2;
      iniciar = true;
    }
  }
  else if( estadoApp == 2 ) {
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
      
      if( escenarioActual == 0 ){
        ojo1.x = PApplet.parseInt( escenarios[0].objetos[0].x - 330 );
        ojo1.update(mouseX, mouseY);
        ojo1.display();
      }
      if ( kinect ) {
        // Detectar jugadores
        int [] userList = context.getUsers();
        for ( int i=0; i<userList.length; i++ ) {
          // Consultar si el esqueleto existe
          if (context.isTrackingSkeleton(userList[i])) {

            // Probar con translate?

            // Punto central
            PVector cuerpo = new PVector();
            context.getJointPositionSkeleton( userList[i], SimpleOpenNI.SKEL_TORSO, cuerpo );
            PVector cuerpo_2d = new PVector(); 
            context.convertRealWorldToProjective(cuerpo, cuerpo_2d);

            // Dibujar
            pushMatrix();
            translate( 0, personajes[personajeActual].posicion.y-90 );
            //drawSkeleton( userList[i] );
            dibujarCuerpo( userList[i] );
            dibujarCabeza( userList[i] );
            translate( -20, -20 );
            dibujarManoIzquierda( userList[i] );
            translate( 40, 0 );
            dibujarManoDerecha( userList[i] );
            popMatrix();

            //personajes[personajeActual].update(); // Players
            personajes[personajeActual].update(cuerpo_2d.x);
          }
        }
      } else {
        personajes[personajeActual].update(); // Players
      }

      // Fade
      escenarios[escenarioActual].prendido();
    }

    // Escenario: Apagando
    // Animaci\u00f3n de salida del escenario
    if ( escenarios[escenarioActual].estado.equals( "apagando" ) ) {
      escenarios[escenarioActual].apagar();
    }

  } else if( estadoApp == 3 ){
    // Loop
    pushStyle();
    imageMode(CORNER);
    cofre.read();
    image(cofre, 0, 0);
    popStyle();
    float md = cofre.duration();
    float mt = cofre.time();
    if (mt >= md) {
      estadoApp = 2;
      iniciar = true;
    }
  } 

  // Im\u00e1gen de c\u00e1mara
  if ( debugCamera && kinect ) {
    image(context.userImage(), width-160, 120, 320, 240);
  }

  // Mostrar informaci\u00f3n para debug
  if ( debug ) {
    pushStyle();
    rectMode(CORNER);
    fill(0, 200);
    rect(0, height-80, width, 80);
    fill( 0, 255, 0 );
    text("Estado App: "+ estadoApp + " - Escenario: "+ escenarioActual + " - Estado: " + escenarios[escenarioActual].estado, 10, height-60 );
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
  if (key == 's' || key == 'S') iniciar = true;
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
    // fadeIn Negro
    if ( fade < fadeDuracion ) {
      float _fade = map(fade, 0, fadeDuracion, 0, 255);
      fill(0, _fade);
      rect(width/2, height/2, width, height);
      fade ++;
    } else {
      fade = 0;
      estado = "prendido";
    }
  }

  // Prendido
  public void prendido() {    
    // fadeOut Negro
    if ( fade < fadeDuracion ) {
      float _fade = map(fade, 0, fadeDuracion, 255, 0);
      fill(0, _fade);
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
class Eye {
  int x, y;
  int size;
  float angle = 0.0f;
  
  Eye(int tx, int ty, int ts) {
    x = tx;
    y = ty;
    size = ts;
 }

  public void update(int mx, int my) {
    angle = atan2(my-y, mx-x);
  }
  
  public void display() {
    pushMatrix();
    translate(x, y);
    rotate(angle);
    image(ojo, 0, 0, size, size);
    popMatrix();
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

public void dibujarCuerpo( int userId ) {
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
  }  else {
    image(p2cuerpo, cuerpo_2d.x, cuerpo_2d.y);
  }
}

//---------------------------------------------------------------

public void dibujarCabeza( int userId ) {
  // Crear un vector para obtener la posici\u00f3n
  PVector cabeza = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_HEAD, cabeza );
  // Crear un vector para proyectar en 2D
  PVector cabeza_2d = new PVector(); 
  // Convertir la posici\u00f3n 3D al 2D de la pantalla
  context.convertRealWorldToProjective(cabeza, cabeza_2d);
  // a 200 pixel diameter head
  //float headsize = 500; 
  // create a distance scalar related to the depth (z dimension)
  //float distanceScalar = (525/cabeza_2d.z);
  // Dibujar
  if( userId == 1 ){
    //image(p1cabeza, cabeza_2d.x, cabeza_2d.y, distanceScalar*headsize, distanceScalar*headsize );
    image(p1cabeza, cabeza_2d.x, cabeza_2d.y-70 );
  }  else {
    //image(p2cabeza, cabeza_2d.x, cabeza_2d.y, distanceScalar*headsize, distanceScalar*headsize );
    image(p2cabeza, cabeza_2d.x, cabeza_2d.y-50 );
  }
  // Si est\u00e1 la llave activa
  if( pasarNivel ){
    image(llavePrendida, cabeza_2d.x, p2cabeza.height-llavePrendida.height*2);
  }
}

//---------------------------------------------------------------

public void dibujarManoIzquierda( int userId ) {
  // Crear un vector para obtener la posici\u00f3n

  PVector manoIzquierda = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_LEFT_ELBOW, manoIzquierda );
  // Crear un vector para proyectar en 2D
  PVector manoIzquierda_2d = new PVector(); 
  // Convertir la posici\u00f3n 3D al 2D de la pantalla
  context.convertRealWorldToProjective(manoIzquierda, manoIzquierda_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1manoi, manoIzquierda_2d.x, manoIzquierda_2d.y);
  }  else {
    image(p2manoi, manoIzquierda_2d.x, manoIzquierda_2d.y);
  }
}

//---------------------------------------------------------------

public void dibujarManoDerecha( int userId ) {
  // Crear un vector para obtener la posici\u00f3n
  PVector manoDerecha = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, manoDerecha );
  // Crear un vector para proyectar en 2D
  PVector manoDerecha_2d = new PVector(); 
  // Convertir la posici\u00f3n 3D al 2D de la pantalla
  context.convertRealWorldToProjective(manoDerecha, manoDerecha_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1manoi, manoDerecha_2d.x, manoDerecha_2d.y);
  }  else {
    image(p2manoi, manoDerecha_2d.x, manoDerecha_2d.y);
  }
}

//---------------------------------------------------------------
// Al detectar nuevo usuario

public void onNewUser(SimpleOpenNI curContext, int userId) {
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  curContext.startTrackingSkeleton(userId);

  // Cambios de estado de la app
  if( estadoApp == 0 ){
    // Si detecta a un personaje, cambia la secuencia
    estadoApp = 1;
    intro.jump(0);
    intro.play();
  }

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
  int universo; // Universo
  PVector posicion; // Posici\u00f3n X, Y, Z
  float x, y; // Posiciones absolutas
  int w, h; // Ancho y Alto
  boolean interactive; // Es interactivo?
  String name; // Nombre (ruta de carpeta)
  String estado; // Estados ["reposo","hover","playing","special"] // ["reposo","in","hover","out","special"]
  PImage [] reposo, hover, playing, special; // Animaciones
  int framesReposo, framesHover, framesPlaying, framesSpecial; // Contador de frames
  int frame; // Contador de frames
  int sonido; // Contador de frames
  OscMessage _audio;
  int timer;
  int k;

  // Constructor
  Objeto ( int _universo, float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name, int _reposo, int _hover, int _playing, int _special, int _sonido) {
    universo = _universo;
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
    timer = 0;
    k=1;

    // Imagen
    // loadImages( String nombre, String extensi\u00f3n, int cantidad_de_frames );
    reposo = loadImages(escenarios[universo].name+"/"+name+"/reposo_", ".png", _reposo);
    hover = loadImages(escenarios[universo].name+"/"+name+"/hover_", ".png", _hover);
    playing = loadImages(escenarios[universo].name+"/"+name+"/playing_", ".png", _playing);
    special = loadImages(escenarios[universo].name+"/"+name+"/special_", ".png", _special);

    // Audio
    sonido = _sonido;
    _audio = new OscMessage("/audio");
    _audio.add(sonido);
  }

  // Actualizar
  public void update() {
    x = width/2+posicion.x+tracker.x*posicion.z; 
    y = height/2+posicion.y;

    if( name == "peces" ){
      x = width/2+posicion.x+k+tracker.x*posicion.z;
    }
    if( name == "nubes" ){
      x = width/2+posicion.x+k*0.1f+tracker.x*posicion.z;
    }
    if( k > 1500 ){
      k = -1500;
    } else {
      k += random(0,10);
    }

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
        if( estado.equals("hover") ){
          // Ya est\u00e1 activo
        } else {
          estado = "activar";
        }
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
        if( millis()-timer >= 100 ){          
          frame ++;
          timer = millis();
        }
      } else {
        frame = 0;
        image(reposo[frame], 0, 0, w, h);
      }
    } 
    
    if( estado.equals("activar") ){

      // Disparar sonido
      oscP5.send(_audio, direccionRemota);

      // Si es la cajita musical
      if( name == "hueco" ){
        llave = true;
      }

      // Si es el dragon y suena la cajita
      if( name == "dragon" && llave == true ){
        estado = "special";
        pasarNivel = true;
      } else {
        estado = "hover";
      }

      // Si es la puerta y tenes la llave
      if( name == "puerta" && pasarNivel == true ){
        println("Pasaste de nivel");
        if( escenarioActual == 1 ){
          pasarNivel = false;
          escenarioActual = 2; 
        }
        estado = "encendiendo";
      }


      // Si es el dragon y suena la cajita
      if( name == "llaveSotano" ){
        pasarNivel = true;
      }

      // Si es el cofre y tenes la llave
      if( name == "cofre" && pasarNivel == true ){
        // Pasajes de universos
        if( escenarioActual == 0 ){ 
          // Si detecta a un personaje, cambia la secuencia
          pasarNivel = false;
          escenarioActual = 1;
          estadoApp = 3;
          cofre.jump(0);
          cofre.play();
        }
        estado = "encendiendo";
      }

    }
    
    if( estado.equals("hover") && hover.length>0 ){
      if( frame < framesHover ){
        image(hover[frame], 0, 0, w, h);
        if( millis()-timer >= 100 ){
          frame ++;
          timer = millis();
        }
      } else {
        frame = 0;
        image(hover[frame], 0, 0, w, h);
      }
    }
    
    if( estado.equals("special") && hover.length>0 ){
      if( frame < framesSpecial ){
        image(special[frame], 0, 0, w, h);
        if( millis()-timer >= 100 ){
          frame ++;
          timer = millis();
        }
      } else {
        frame = 0;
        image(special[frame], 0, 0, w, h);
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

  // Actualizar Kinect
  public void update(float _x) {
    posicion.x = _x;
  }

  // Actualizar Mouse
  public void update() {
    posicion.x = mouseX;
    dibujar();
  }

  // Esperando
  public void esperar() {
  }

  // Dibujar
  public void dibujar() {
    image(animacion[0], posicion.x, posicion.y);
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
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#171616", "--stop-color=#cccccc", "build" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
