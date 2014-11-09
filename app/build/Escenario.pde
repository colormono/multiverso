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
  void prendido() {    
    // fadeOut Negro
    if ( fade < fadeDuracion ) {
      float _fade = map(fade, 0, fadeDuracion, 255, 0);
      fill(0, _fade);
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