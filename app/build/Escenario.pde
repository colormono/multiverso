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
    animacion = loadImages(name+"/", ".png", 1); // nombre, extención, cantidad de frames
    fade = 0;
    fadeDuracion = 60;
  }

  // Constructor completo
  Escenario( String _name, int _id ) {
    name = _name;
    estado = "esperando";
    animacion = loadImages(name+"/", ".png", 1); // nombre, extención, cantidad de frames
  }

  // Esperando (si no hay nadie durante x tiempo)
  void esperar( float _x, float _y ) {
    // Si detecta blob, enciende
    if ( _y > 10 && _y < height-10 ) {
      fade = 0;
      estado = "encendiendo";
    }
  }

  // Encender (si está esperando y detacta movimiento)
  void encender() {
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
  void prendido() {    
    // fadeOut Blanco
    if ( fade < fadeDuracion ) {
      float _fade = map(fade, 0, fadeDuracion, 255, 0);
      fill(255, _fade);
      rect(0, 0, width, height);
      fade ++;
    }
  }

  // Apagar
  void apagar() {
    estado = "esperando";
  }

  // Dibujar
  void dibujar() {
    image(cielo, mouse.x*0.05, -125); // Cielo
    image(nubes, mouse.x*0.1, -125); // Nubes
    image(montanas, mouse.x*0.2, 100); // Montañas
    image(peces, mouse.x*0.3+400, 0, peces.width*0.3, peces.height*0.3); // Peces chicos
    image(peces, mouse.x*0.3-500, -100); // Peces
    image(piso, mouse.x*0.4, 270); // Piso
    image(dragon, mouse.x*0.5-400, 120); // Dragon

    // Ejemplo
    image(hueco, mouse.x*0.6+900, 200); // Hueco
    println( mouse.x + " - " + (mouse.x-hueco.width/2) + " - " + hueco.width);
    if ( xColision>mouse.x && xColision<mouse.x-hueco.width/2 ) {
      fill(0, 0, 255, 150);
      rect(mouse.x*0.6+900, 200, hueco.width, hueco.height);
    }
    image(puertaCerrada, mouse.x*0.8+300, 180); // Puerta
    image(flor, mouse.x*0.9-1024, 300); // Flor
  }
}

