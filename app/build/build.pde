// MULTIVERSO
// App v03: Personajes con Kinect

//---------------------------------------------------------------

// Kinect
import SimpleOpenNI.*;
SimpleOpenNI context;

// Objetos
Personaje personajes[]; // Personajes
Escenario escenarios[]; // Escenarios
Objeto objetos[]; // Objetos

// Configuración
boolean debug = true; // Debug
boolean debugCamera = true; // Debug Camara
boolean kinect = true; // Use kinect or mouse
PVector tracker; // Tracking
int personajeActual = 0; // Personaje inicial
int escenarioActual = 2; // Escenario inicial
boolean iniciar = false; // Botón para iniciar (temporal)

// Imagenes temp kinect
PImage p1cabeza, p1cuerpo, p1manod, p1manoi;
PImage p2cabeza, p2cuerpo, p2manod, p2manoi;

//---------------------------------------------------------------

void setup() {
  // Lienzo
  size(1024, 768, P3D);
  //frameRate(30);
  noStroke();

  // Arreglos
  personajes = new Personaje[0];
  escenarios = new Escenario[0];

  // Personaje ( float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name );
  Personaje p1 = new Personaje( 0, 600, mouseY, 235, 240, true, "pepe" );
  personajes = (Personaje[]) append(personajes, p1);

  // Escenario: Introducción
  Escenario e1 = new Escenario( "intro" );
  escenarios = (Escenario[]) append(escenarios, e1);

  // Escenario: Sótano
  Escenario e2 = new Escenario( "sotano" );
  escenarios = (Escenario[]) append(escenarios, e2);

  // Escenario: Montaña
  Escenario e3 = new Escenario( "montana" );
  escenarios = (Escenario[]) append(escenarios, e3);

  // Inicializar un nuevo objeto contexto
  context = new SimpleOpenNI(this);

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

void draw() {
  // Limpiar fondo
  background(100);
  rectMode(CENTER);
  imageMode(CENTER);

  // Actualizar imagen de cámara
  context.update();

  // Tracker
  float _xt, _yt;
  if ( kinect ) {
    _xt = personajes[personajeActual].posicion.x;
    _yt = personajes[personajeActual].posicion.y;
  } else {
    _xt = mouseX;
    _yt = mouseY;
  }
  tracker.x = map( _xt, 0, width, width, -width );
  tracker.y = map( _yt, 0, height, 0, 10 );

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
        dibujarCuerpo( userList[i], personajes[personajeActual].posicion.y );
        dibujarCabeza( userList[i], personajes[personajeActual].posicion.y );
        dibujarManoIzquierda( userList[i], personajes[personajeActual].posicion.y );
        dibujarManoDerecha( userList[i], personajes[personajeActual].posicion.y );

        //personajes[personajeActual].update(); // Players
        personajes[personajeActual].update(cuerpo_2d.x);
      }
    }

    // Fade
    escenarios[escenarioActual].prendido();
  }

  // Escenario: Apagando
  // Animación de salida del escenario
  if ( escenarios[escenarioActual].estado.equals( "apagando" ) ) {
    escenarios[escenarioActual].apagar();
  }

  // Imágen de cámara
  if ( debugCamera ) {
    image(context.userImage(), width-160, 120, 320, 240);
  }

  // Mostrar información para debug
  if ( debug ) {
    // Información relativa
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

void keyPressed() {
  // Debug
  if (key == 'd' || key == 'D') debug = !debug;
  if (key == 'c' || key == 'C') debugCamera = !debugCamera;
  if (key == 'k' || key == 'K') kinect = !kinect;

  // Controlar secuencias
  if (key == '1') escenarioActual = 0;
  if (key == '2') escenarioActual = 1;
  if (key == '3') escenarioActual = 2;
}
