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
  void esperar( boolean _iniciar ) {
    // Si detecta blob, enciende
    if ( _iniciar ) {
      fade = 0;
      estado = "encendiendo";
    }
  }

  // Encender
  void encender() {

    // Crear universo
    // Si name = "montana"...
    if( fade == 0 ){
      // Objeto ( float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name, int _reposo, int _hover, int _playing, int _special );
      Objeto o7 = new Objeto( 0, -125, 0.05, 1365, 527, false, "cielo", 1, 0, 0, 0 );
      objetos = (Objeto[]) append(objetos, o7);
      Objeto o8 = new Objeto( 0, -125, 0.1, 1068, 119, false, "nubes", 1, 0, 0, 0 );
      objetos = (Objeto[]) append(objetos, o8);
      Objeto o9 = new Objeto( 0, 100, 0.2, 1498, 269, false, "montanas", 1, 0, 0, 0 );
      objetos = (Objeto[]) append(objetos, o9);
      Objeto o10 = new Objeto( 0, 270, 0.4, 2048, 281, false, "piso", 1, 0, 0, 0 );
      objetos = (Objeto[]) append(objetos, o10);

      Objeto o1 = new Objeto( -400, 120, 0.5, 533, 233, true, "dragon", 150, 25, 0, 0 );
      objetos = (Objeto[]) append(objetos, o1);
      Objeto o2 = new Objeto( 400, 0, 0.3, 102, 60, true, "peceschicos", 1, 1, 0, 0 );
      objetos = (Objeto[]) append(objetos, o2);
      Objeto o3 = new Objeto( -500, -100, 0.3, 205, 120, true, "peces", 1, 1, 0, 0 );
      objetos = (Objeto[]) append(objetos, o3);
      Objeto o4 = new Objeto( 900, 200, 0.6, 168, 246, true, "hueco", 1, 1, 0, 0 );
      objetos = (Objeto[]) append(objetos, o4);
      Objeto o5 = new Objeto( 300, 180, 0.8, 456, 480, true, "puerta", 1, 1, 0, 0 );
      objetos = (Objeto[]) append(objetos, o5);
      Objeto o6 = new Objeto( -1024, 300, 0.9, 273, 98, true, "flor", 1, 1, 0, 0 );
      objetos = (Objeto[]) append(objetos, o6);
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
  void prendido() {    
    // fadeOut Blanco
    if ( fade < fadeDuracion ) {
      float _fade = map(fade, 0, fadeDuracion, 255, 0);
      fill(255, _fade);
      rect(width/2, height/2, width, height);
      fade ++;
    }
  }

  // Apagar
  void apagar() {
    estado = "esperando";
  }

  // Dibujar
  void dibujar() {
    for (int i = 0; i < objetos.length; i++) {
      objetos[i].update();
    }
  }
}