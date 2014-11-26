// MULTIVERSO
// App v05: Contenidos e interacciones
//---------------------------------------------------------------

// Kinect
import SimpleOpenNI.*;
SimpleOpenNI context;

// Video
import processing.video.*;

// OSC
import oscP5.*;
import netP5.*;

// Objetos y controles
Personaje personajes[]; // Personajes
Escenario escenarios[]; // Escenarios
Objeto objetos[]; // Objetos
OscP5 oscP5; // Objeto OSC
NetAddress direccionRemota; // Dirección remota
int puerto; // Puerto de salida OSC
boolean llave = false; // Llave para pasar de nivel
boolean pasarNivel = false; // Llave para pasar de nivel
int frame = 0;
int timer = 0;
int timerCreditos = 800;

// Configuración
boolean debug = false; // Debug
boolean debugCamera = false; // Debug Camara
boolean kinect = false; // Using kinect
PVector tracker; // Tracking
int estadoApp = 2; // Arrancar desde la intro (LoopIntro=0, 1=Video, 2=Nivel, 3=VideoLlave, 4=VideoCierre)
int personajeActual = 0; // Personaje inicial (Pepe = 0)
int escenarioActual = 0; // Escenario inicial (Sotano = 0)
boolean iniciar = false; // Botón para iniciar (temporal)

// Imagenes y videos
PImage p1cabeza, p1cuerpo, p1manod, p1manoi;
PImage p2cabeza, p2cuerpo, p2manod, p2manoi;
PImage llaveApagada, llavePrendida, ojo, creditos;
Movie bucle, intro, cofre, cierre;
Eye ojo1;

//---------------------------------------------------------------

void setup() {
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
  creditos = loadImage("ui/creditos.png");

  // Llaves
  llaveApagada = loadImage("ui/llaveOFF.png");
  llavePrendida = loadImage("ui/llaveON.png");

  // Videos
  bucle = new Movie(this, "intro/loop.mov");
  intro = new Movie(this, "intro/intro.mov");
  cofre = new Movie(this, "intro/cofre.mov");
  cierre = new Movie(this, "intro/cierre.mov");
  bucle.loop();

  // Crear Universos de Objetos
  // Objeto ( int _universo, float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name, int _reposo, int _hover, int _playing, int _special, int _sonido );
  escenarios = new Escenario[0];

  // Escenario: Sótano
  Escenario e1 = new Escenario( "sotano" );
  escenarios = (Escenario[]) append(escenarios, e1);
  escenarios[0].objetos = (Objeto[]) append(escenarios[0].objetos, new Objeto( 0, 0, 0, 0.2, 1365, 768, false, "fondo", 1, 0, 0, 0, 0 ));
  escenarios[0].objetos = (Objeto[]) append(escenarios[0].objetos, new Objeto( 0, -400, 200, 0.2, 200, 200, true, "cofre", 1, 23, 0, 0, 0 ));
  escenarios[0].objetos = (Objeto[]) append(escenarios[0].objetos, new Objeto( 0, 400, 0, 0.2, 215, 491, true, "llaveSotano", 1, 1, 0, 1, 0 ));
  ojo1 = new Eye( 100,  180, 40);

  // Escenario: Puertas
  Escenario e2 = new Escenario( "fighter" );
  escenarios = (Escenario[]) append(escenarios, e2);
  escenarios[1].objetos = (Objeto[]) append(escenarios[1].objetos, new Objeto( 1, 0, 0, 0.2, 1498, 768, false, "fondo", 1, 0, 0, 0, 0 ));
  escenarios[1].objetos = (Objeto[]) append(escenarios[1].objetos, new Objeto( 1, 350, 140, 0.8, 300, 450, true, "porton", 1, 24, 0, 24, 5 ));

  // Escenario: Montaña
  Escenario e3 = new Escenario( "montana" );
  escenarios = (Escenario[]) append(escenarios, e3);
  escenarios[2].objetos = (Objeto[]) append(escenarios[2].objetos, new Objeto( 2, 0, -125, 0.05, 1365, 527, false, "cielo", 1, 0, 0, 0, 0 ));
  escenarios[2].objetos = (Objeto[]) append(escenarios[2].objetos, new Objeto( 2, 0, -125, 0.1, 1068, 119, false, "nubes", 1, 0, 0, 0, 0 ));
  escenarios[2].objetos = (Objeto[]) append(escenarios[2].objetos, new Objeto( 2, 0, 100, 0.2, 1498, 269, false, "montanas", 1, 0, 0, 0, 0 ));
  escenarios[2].objetos = (Objeto[]) append(escenarios[2].objetos, new Objeto( 2, 0, 270, 0.4, 2048, 281, false, "piso", 1, 0, 0, 0, 0 ));
  escenarios[2].objetos = (Objeto[]) append(escenarios[2].objetos, new Objeto( 2, -400, 120, 0.5, 533, 233, true, "dragon", 50, 46, 0, 25, 4 ));
  escenarios[2].objetos = (Objeto[]) append(escenarios[2].objetos, new Objeto( 2, 400, 0, 0.3, 102, 60, true, "peces", 24, 24, 0, 0, 2 ));
  escenarios[2].objetos = (Objeto[]) append(escenarios[2].objetos, new Objeto( 2, -500, -100, 0.3, 205, 120, true, "peces", 24, 24, 0, 0, 2 ));
  escenarios[2].objetos = (Objeto[]) append(escenarios[2].objetos, new Objeto( 2, 700, 200, 0.9, 168, 246, true, "hueco", 1, 89, 0, 0, 8 ));
  escenarios[2].objetos = (Objeto[]) append(escenarios[2].objetos, new Objeto( 2, 350, 140, 0.8, 300, 450, true, "puerta", 1, 24, 0, 24, 5 ));
  escenarios[2].objetos = (Objeto[]) append(escenarios[2].objetos, new Objeto( 2, 0, 200, 0.9, 200, 200, true, "flor", 1, 32, 0, 0, 9 ));
  // Iniciar sonido ambiente
  OscMessage _audio = new OscMessage("/audio");
  _audio.add(1);
  oscP5.send(_audio, direccionRemota);

  // Escenario: Bosque
  Escenario e4 = new Escenario( "bosque" );
  escenarios = (Escenario[]) append(escenarios, e4);
  escenarios[3].objetos = (Objeto[]) append(escenarios[3].objetos, new Objeto( 3, 0, 0, 0.2, 1498, 768, false, "fondo", 1, 0, 0, 0, 0 ));
  escenarios[3].objetos = (Objeto[]) append(escenarios[3].objetos, new Objeto( 3, -125, 140, 0.8, 300, 450, true, "portal", 1, 24, 0, 24, 5 ));

  // Si se está utilizando la Kinect
  if ( kinect ) {

    // Inicializar un nuevo objeto contexto
    context = new SimpleOpenNI(this);
    context.setMirror(true);

    // Habilitar la carga de imagen de profundidad 
    context.enableDepth();

    // Habilitar detección de esqueleto para todas las juntas
    context.enableUser();

    // Test Kinect
    if( context.isInit() == false ){
      println("La cámara Kinect se encuentra conectada?");
      exit();
      return;
    }

  }
  tracker = new PVector( 0, 0 );
}

//---------------------------------------------------------------

void draw() {

  // Limpiar fondo
  background(0);
  rectMode(CENTER);
  imageMode(CENTER);

  // Tracker
  float _xt, _yt;
  if ( kinect ) {
    context.update(); // Actualizar imagen de cámara
    _xt = personajes[personajeActual].posicion.x;
    _yt = personajes[personajeActual].posicion.y;
    tracker.x = constrain( map( _xt, 0, 640, width/2, -width/2 ), -width/2, width/2);
    tracker.y = map( _yt, 0, height, 0, 10 );
    println("_xt: "+_xt + "| .x: "+tracker.x);
  } else {
    _xt = mouseX;
    _yt = mouseY;
    tracker.x = map( _xt, 0, width, width/2, -width/2 );
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
    // Si detecta un usuario, enciende la aplicación
    if ( escenarios[escenarioActual].estado.equals( "esperando" ) ) {
      escenarios[escenarioActual].esperar( iniciar );
    }

    // Escenario: Encendiendo
    // Animación de entrada del escenario, crear universo
    if ( escenarios[escenarioActual].estado.equals( "encendiendo" ) ) {
      escenarios[escenarioActual].encender();
    }

    // Escenario: Prendido
    // Habilita la interacción del usuario con los objetos
    if ( escenarios[escenarioActual].estado.equals( "prendido" ) ) {

      // Escenario
      escenarios[escenarioActual].dibujar();
      
      if( escenarioActual == 0 ){
        ojo1.x = int( escenarios[0].objetos[0].x - 330 );
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
    // Animación de salida del escenario
    if ( escenarios[escenarioActual].estado.equals( "apagando" ) ) {
      escenarios[escenarioActual].apagar();
    }

  } else if( estadoApp == 3 ){
    // Video cuando abren el cofre
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
  } else if( estadoApp == 4 ){
    // Video de salida
    pushStyle();
    imageMode(CORNER);
    cierre.read();
    image(cierre, 0, 0);
    popStyle();
    float md = cierre.duration();
    float mt = cierre.time();
    if (mt >= md) {
      estadoApp = 5;
      iniciar = false;
      timerCreditos = 800;
    }
  } else if( estadoApp == 5 ){
    // Placa de cierre
    pushStyle();
    imageMode(CORNER);
    image(creditos, 0, 0);
    popStyle();
    timerCreditos --;
    if (timerCreditos <= 1) {
      estadoApp = 0;
    }
  } 

  // Imágen de cámara
  if ( debugCamera && kinect ) {
    image(context.userImage(), width-160, 120, 320, 240);
  }

  // Mostrar información para debug
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

void keyPressed() {
  // Debug
  if (key == 'd' || key == 'D') debug = !debug;
  if (key == 'c' || key == 'C') debugCamera = !debugCamera;
  if (key == 's' || key == 'S') iniciar = true;
}
