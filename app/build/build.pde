// MULTIVERSO
// App 01

// Configuración
boolean debug = true; // Debug
PVector mouse; // Tracking
PImage player1, cielo, nubes, montanas, peces, piso, dragon, hueco, puertaCerrada, flor; // UI
float xColision;

// Personjajes
Personaje personajes[]; // Objetos para los personajes
int personajeActual = 0; // Personajes inicial

// Escenarios
Escenario escenarios[]; // Objetos para los escenarios
int escenarioActual = 0; // Escenario inicial

void setup() {
  size(1024, 768, P3D);
  noStroke();

  // Arreglo de personajes Personaje( String _name );
  personajes = new Personaje[0];
  Personaje p1 = new Personaje( "pepe" );
  personajes = (Personaje[]) append(personajes, p1);

  // Arreglo de objetos Escenario( String _name );
  escenarios = new Escenario[0];

  // Arreglo de objetos Escenario Completo( String _name, Arreglo de objetos[Cielo, Nubes] );

  // Escenario: Introducción
  Escenario e1 = new Escenario( "intro" );
  escenarios = (Escenario[]) append(escenarios, e1);

  // Escenario: Sótano
  Escenario e2 = new Escenario( "sotano" );
  escenarios = (Escenario[]) append(escenarios, e2);

  // Escenario: Montaña
  Escenario e3 = new Escenario( "montana" );
  escenarios = (Escenario[]) append(escenarios, e3);

  // Escenario: Bosque
  Escenario e4 = new Escenario( "bosque" );
  escenarios = (Escenario[]) append(escenarios, e4);  

  // Imagenes Escenario
  cielo = loadImage("montana/cielo.png");
  nubes = loadImage("montana/nubes.png");
  montanas = loadImage("montana/montanas.png");
  peces = loadImage("montana/peces.png");
  piso = loadImage("montana/piso.png");
  dragon = loadImage("montana/dragon.png");
  hueco = loadImage("montana/hueco.png");
  puertaCerrada = loadImage("montana/puerta.png");
  flor = loadImage("montana/flor.png");
}

void draw() {
  // Limpiar fondo
  background(100);

  // Tracker
  mouse = new PVector(mouseX, mouseY);
  mouse.x = map(mouseX, 0, width, width, -width);
  mouse.y = map(mouseY, 0, height, 0, -300);
  xColision = map(mouseX, 0, width, -1024, 1024)*-1;

  // Escenario: Esperando
  // Si detecta un usuario, enciende la aplicación
  if ( escenarios[escenarioActual].estado.equals( "esperando" ) ) {
    escenarios[escenarioActual].esperar( mouse.y, mouse.x );
  }

  // Escenario: Encendiendo
  // Animación de entrada del escenario
  if ( escenarios[escenarioActual].estado.equals( "encendiendo" ) ) {
    escenarios[escenarioActual].encender();
  }

  // Escenario: Prendido
  // Habilita la interacción del usuario con los objetos
  if ( escenarios[escenarioActual].estado.equals( "prendido" ) ) {
    pushStyle();
    rectMode(CENTER);
    imageMode(CENTER);

    // Escenario
    pushMatrix();
    translate(width/2, height/2);
    //translate(width/2, height/2, mouse.y); // 3D
    escenarios[escenarioActual].dibujar();
    popMatrix();
    
    // Player
    pushMatrix();
    translate(0, height/2);
    personajes[personajeActual].dibujar();
    popMatrix();

    popStyle();

    // Fade
    escenarios[escenarioActual].prendido();
  }

  // Escenario: Apagando
  // Animación de salida del escenario
  if ( escenarios[escenarioActual].estado.equals( "apagando" ) ) {
    escenarios[escenarioActual].apagar();
  }

  // Mostrar información para debug
  if ( debug ) {
    // Información relativa
    pushStyle();
    fill(0, 200);
    rect(0, height-80, width, 80);
    fill( 0, 255, 0 );
    text("Escenario "+escenarioActual + " - Estado: " + escenarios[escenarioActual].estado, 10, height-60 );
    text("Personaje "+personajeActual + " - x: " + mouseX + " - z: ? - xColision: "+ xColision, 10, height-40 );
    text("x: "+mouse.x+" - y: "+mouse.y+ " - Framerate: " + (int)frameRate, 10, height-20 );
    popStyle();
  }
}

//---------------------------------------------------------------

void keyPressed() {

  // Debug
  if (key == 'd' || key == 'D') debug = !debug;

  // Controlar secuencias
  if (key == ' ') {
    escenarioActual = int( random(0, escenarios.length) );
  }
  if (key == '1') escenarioActual = 0;
  if (key == '2') escenarioActual = 1;
  if (key == '3') escenarioActual = 2;
  if (key == '4') escenarioActual = 3;
}

//---------------------------------------------------------------

boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

