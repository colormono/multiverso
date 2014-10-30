class Personaje {

  //.h
  PVector posicion; // Posición X, Y, Z
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
    animacion = loadImages(name+"/", ".png", 2); // nombre, extención, cantidad de frames
  }

  // Actualizar
  void update(float _x) {
    posicion.x = _x;
    //posicion.x = mouseX;
    //dibujar();
  }

  // Actualizar Mouse
  void update() {
    posicion.x = mouseX;
    dibujar();
  }

  // Esperando
  void esperar() {
  }

  // Dibujar
  void dibujar() {
    image(animacion[0], posicion.x, posicion.y);
  }
}