class Objeto {

  //.h
  PVector posicion; // Posición X, Y, Z
  float x, y; // Posiciones absolutas
  int w, h; // Ancho y Alto
  boolean interactive; // Es interactivo?
  String name; // Nombre (ruta de carpeta)
  String estado; // Estados ["reposo","hover","playing","special"] // ["reposo","in","hover","out","special"]
  PImage [] reposo, hover, playing, special; // Animaciones
  int framesReposo, framesHover, framesPlaying, framesSpecial; // Contador de frames
  int frame; // Contador de frames

  // Constructor
  Objeto ( float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name, int _reposo, int _hover, int _playing, int _special ) {
    posicion = new PVector( _x, _y, _z );
    w = _w;
    h = _h;
    interactive = _interactive;
    name = _name;
    estado = "reposo";
    framesReposo  = _reposo;
    framesHover = _hover;
    framesPlaying = _playing;
    framesSpecial = _special;
    frame = 0;

    // loadImages( String nombre, String extensión, int cantidad_de_frames );
    reposo = loadImages(escenarios[escenarioActual].name+"/"+name+"/reposo_", ".png", _reposo);
    hover = loadImages(escenarios[escenarioActual].name+"/"+name+"/hover_", ".png", _hover);
    playing = loadImages(escenarios[escenarioActual].name+"/"+name+"/playing_", ".png", _playing);
    special = loadImages(escenarios[escenarioActual].name+"/"+name+"/special_", ".png", _special);
  }

  // Actualizar
  void update() {
    x = width/2+posicion.x+tracker.x*posicion.z;
    y = height/2+posicion.y;

    dibujar();

    if( interactive ){
      colisionar();
    }
  }

  // Detectar colisiones
  void colisionar() {
    for(int i=0; i<personajes.length; i++ ){
      if( 
        personajes[i].posicion.x >= x-w/2 && 
        personajes[i].posicion.x <= x+w/2 
      ) {
        // Cambiar estado
        estado = "hover";
        // Disparar sonido
        if(debug){
          fill(0,0,255,100);
          rect(x, y, w, h);
        }
      } else {
        // Reiniciar estado
        estado = "reposo";
      }
    }
  }

  // Dibujar
  void dibujar() {
    pushMatrix();
    translate(x, y); // 2D
    //translate(x, y, tracker.y); // 3D
    if( estado.equals("reposo") ){
      if( frame < framesReposo ){
        image(reposo[frame], 0, 0, w, h);
        frame ++;
      } else {
        frame = 0;
        image(reposo[frame], 0, 0, w, h);
      }
    } 
    else if( estado.equals("hover") && hover.length>0 ){
      if( frame < framesHover ){
        image(hover[frame], 0, 0, w, h);
        frame ++;
      } else {
        frame = 0;
        image(hover[frame], 0, 0, w, h);
      }
    }
    popMatrix();
  }
}