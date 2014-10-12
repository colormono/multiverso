import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

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
// App v01: Simple parallax

// Configuraci\u00f3n
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

public void setup() {
  size(1024, 768, P3D);
  noStroke();

  // Arreglo de personajes Personaje( String _name );
  personajes = new Personaje[0];
  Personaje p1 = new Personaje( "pepe" );
  personajes = (Personaje[]) append(personajes, p1);

  // Arreglo de objetos Escenario( String _name );
  escenarios = new Escenario[0];

  // Arreglo de objetos Escenario Completo( String _name, Arreglo de objetos[Cielo, Nubes] );

  // Escenario: Introducci\u00f3n
  Escenario e1 = new Escenario( "intro" );
  escenarios = (Escenario[]) append(escenarios, e1);

  // Escenario: S\u00f3tano
  Escenario e2 = new Escenario( "sotano" );
  escenarios = (Escenario[]) append(escenarios, e2);

  // Escenario: Monta\u00f1a
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

public void draw() {
  // Limpiar fondo
  background(100);

  // Tracker
  mouse = new PVector(mouseX, mouseY);
  mouse.x = map(mouseX, 0, width, width, -width);
  mouse.y = map(mouseY, 0, height, 0, -300);
  xColision = map(mouseX, 0, width, -1024, 1024)*-1;

  // Escenario: Esperando
  // Si detecta un usuario, enciende la aplicaci\u00f3n
  if ( escenarios[escenarioActual].estado.equals( "esperando" ) ) {
    escenarios[escenarioActual].esperar( mouse.y, mouse.x );
  }

  // Escenario: Encendiendo
  // Animaci\u00f3n de entrada del escenario
  if ( escenarios[escenarioActual].estado.equals( "encendiendo" ) ) {
    escenarios[escenarioActual].encender();
  }

  // Escenario: Prendido
  // Habilita la interacci\u00f3n del usuario con los objetos
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
  // Animaci\u00f3n de salida del escenario
  if ( escenarios[escenarioActual].estado.equals( "apagando" ) ) {
    escenarios[escenarioActual].apagar();
  }

  // Mostrar informaci\u00f3n para debug
  if ( debug ) {
    // Informaci\u00f3n relativa
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

public void keyPressed() {

  // Debug
  if (key == 'd' || key == 'D') debug = !debug;

  // Controlar secuencias
  if (key == ' ') {
    escenarioActual = PApplet.parseInt( random(0, escenarios.length) );
  }
  if (key == '1') escenarioActual = 0;
  if (key == '2') escenarioActual = 1;
  if (key == '3') escenarioActual = 2;
  if (key == '4') escenarioActual = 3;
}

//---------------------------------------------------------------

public boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

class Escenario {

  //.h
  String name; // Nombre del escenario (ruta de carpeta)
  String estado; // Estado inicial
  PImage [] animacion;  // Animaciones
  int fade, fadeDuracion; // Fade

  // Constructor simple
  Escenario( String _name ) {
    name = _name;
    estado = "esperando";
    animacion = loadImages(name+"/", ".png", 1); // nombre, extenci\u00f3n, cantidad de frames
    fade = 0;
    fadeDuracion = 60;
  }

  // Constructor completo
  Escenario( String _name, int _id ) {
    name = _name;
    estado = "esperando";
    animacion = loadImages(name+"/", ".png", 1); // nombre, extenci\u00f3n, cantidad de frames
  }

  // Esperando (si no hay nadie durante x tiempo)
  public void esperar( float _x, float _y ) {
    // Si detecta blob, enciende
    if ( _y > 10 && _y < height-10 ) {
      fade = 0;
      estado = "encendiendo";
    }
  }

  // Encender (si est\u00e1 esperando y detacta movimiento)
  public void encender() {
    // fadeIn Blanco
    if ( fade < fadeDuracion ) {
      float _fade = map(fade, 0, fadeDuracion, 0, 255);
      fill(255, _fade);
      rect(0, 0, width, height);
      fade ++;
    } else {
      fade = 0;
      estado = "prendido";
    }
  }

  // Prendido (mientras hay movimiento)
  public void prendido() {    
    // fadeOut Blanco
    if ( fade < fadeDuracion ) {
      float _fade = map(fade, 0, fadeDuracion, 255, 0);
      fill(255, _fade);
      rect(0, 0, width, height);
      fade ++;
    }
  }

  // Apagar
  public void apagar() {
    estado = "esperando";
  }

  // Dibujar
  public void dibujar() {
    image(cielo, mouse.x*0.05f, -125); // Cielo
    image(nubes, mouse.x*0.1f, -125); // Nubes
    image(montanas, mouse.x*0.2f, 100); // Monta\u00f1as
    image(peces, mouse.x*0.3f+400, 0, peces.width*0.3f, peces.height*0.3f); // Peces chicos
    image(peces, mouse.x*0.3f-500, -100); // Peces
    image(piso, mouse.x*0.4f, 270); // Piso
    image(dragon, mouse.x*0.5f-400, 120); // Dragon

    // Ejemplo
    image(hueco, mouse.x*0.6f+900, 200); // Hueco
    println( mouse.x + " - " + (mouse.x-hueco.width/2) + " - " + hueco.width);
    if ( xColision>mouse.x && xColision<mouse.x-hueco.width/2 ) {
      fill(0, 0, 255, 150);
      rect(mouse.x*0.6f+900, 200, hueco.width, hueco.height);
    }
    image(puertaCerrada, mouse.x*0.8f+300, 180); // Puerta
    image(flor, mouse.x*0.9f-1024, 300); // Flor
  }
}
class Personaje {

  //.h
  String name; // Nombre del personaje (ruta de carpeta)
  String estado; // Estado inicial
  PImage [] animacion;  // Animaciones

  // Constructor simple
  Personaje( String _name ) {
    name = _name;
    estado = "esperando";
    animacion = loadImages(name+"/", ".png", 2); // nombre, extenci\u00f3n, cantidad de frames
  }

  // Esperando
  public void esperar() {
  }

  // Dibujar
  public void dibujar() {
    image(animacion[0], mouseX, 220);
  }
}

//The MIT License (MIT)
//Copyright (c) 2013 Mick Grierson, Matthew Yee-King, Marco Gillies
//Permission is hereby granted, free of charge, to any person obtaining a copy\u2028of this software and associated documentation files (the "Software"), to deal\u2028in the Software without restriction, including without limitation the rights\u2028to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\u2028copies of the Software, and to permit persons to whom the Software is\u2028furnished to do so, subject to the following conditions:
//The above copyright notice and this permission notice shall be included in\u2028all copies or substantial portions of the Software.
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\u2028IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\u2028FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\u2028AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\u2028LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\u2028OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\u2028THE SOFTWARE.

public PImage [] loadImages(String stub, String extension, int numImages) {
  PImage [] images = new PImage[0];
  for (int i =0; i < numImages; i++) {
    PImage img = loadImage(stub+i+extension);
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
