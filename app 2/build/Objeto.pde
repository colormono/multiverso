class Objeto {

  //.h
  PVector posicion; // Posición X, Y, Z
  int w, h; // Ancho y Alto
  boolean interactive; // Es interactivo?
  String name; // Nombre (ruta de carpeta)
  String estado; // Estado inicial ["reposo","hover","playing"]
  PImage [] animacion; // Animaciones
  float x, y;

  Objeto ( float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name ) {
    posicion = new PVector( _x, _y, _z );
    w = _w;
    h = _h;
    interactive = _interactive;
    name = _name;
    estado = "reposo";
    animacion = loadImages(escenarios[escenarioActual].name+"/"+name+"/", ".png", 1); // nombre, extención, cantidad de frames
  }

  // Actualizar
  void update() {
    x = width/2+posicion.x+tracker.x*posicion.z;
    y = height/2+posicion.y;

    dibujar();

    if( interactive ){
      colision();
    }
  }

  // Detectar colisiones
  void colision() {
    for(int i=0; i<personajes.length; i++ ){
      if( 
        personajes[i].posicion.x >= x-w/2 && 
        personajes[i].posicion.x <= x+w/2 
      ) {
        fill(0,0,255,100);
        rect(x, y, w, h);
      }
    }
  }

  // Dibujar
  void dibujar() {
    pushMatrix();
    translate(x, y); // 2D
    //translate(width/2, height/2, tracker.y); // 3D
    image(animacion[0], 0, 0, w, h);
    if ( debug ) {
      pushStyle();
      fill(255);
      text(x, 0, 0 );
      popStyle();
    }
    popMatrix();

  }
}