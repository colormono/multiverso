class Personaje {

  //.h
  String name; // Nombre del personaje (ruta de carpeta)
  String estado; // Estado inicial
  PImage [] animacion;  // Animaciones

  // Constructor simple
  Personaje( String _name ) {
    name = _name;
    estado = "esperando";
    animacion = loadImages(name+"/", ".png", 2); // nombre, extención, cantidad de frames
  }

  // Esperando
  void esperar() {
  }

  // Dibujar
  void dibujar() {
    image(animacion[0], mouseX, 220);
  }
}

