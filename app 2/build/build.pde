// MULTIVERSO
// App v02: Colisión de objetos

// Objetos
Personaje personajes[]; // Personajes
Escenario escenarios[]; // Escenarios
Objeto objetos[]; // Objetos

// Configuración
boolean debug = true; // Debug
PVector tracker; // Tracking
int personajeActual = 0; // Personaje inicial
int escenarioActual = 2; // Escenario inicial

void setup() {
  size(1024, 768, P3D);
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

}

void draw() {
  // Limpiar fondo
  background(100);
  rectMode(CENTER);
  imageMode(CENTER);

  // Tracker
  tracker = new PVector( mouseX, mouseY );
  tracker.x = map( mouseX, 0, width, width, -width );
  tracker.y = map( mouseY, 0, height, 0, 10 );

  // Escenario: Esperando
  // Si detecta un usuario, enciende la aplicación
  if ( escenarios[escenarioActual].estado.equals( "esperando" ) ) {
    escenarios[escenarioActual].esperar( tracker.y, tracker.x );
  }

  // Escenario: Encendiendo
  // Animación de entrada del escenario, crear universo
  if ( escenarios[escenarioActual].estado.equals( "encendiendo" ) ) {
    escenarios[escenarioActual].encender();
  }

  // Escenario: Prendido
  // Habilita la interacción del usuario con los objetos
  if ( escenarios[escenarioActual].estado.equals( "prendido" ) ) {
    escenarios[escenarioActual].dibujar(); // Escenario
    personajes[personajeActual].update(); // Players    
    escenarios[escenarioActual].prendido(); // Fade
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

  // Controlar secuencias
  if (key == '1') escenarioActual = 0;
  if (key == '2') escenarioActual = 1;
  if (key == '3') escenarioActual = 2;
}
