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
  int sonido; // Contador de frames
  OscMessage _audio;
  int timer;

  // Constructor
  Objeto ( float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name, int _reposo, int _hover, int _playing, int _special, int _sonido) {
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
    timer = 0;

    // Imagen
    // loadImages( String nombre, String extensión, int cantidad_de_frames );
    reposo = loadImages(escenarios[escenarioActual].name+"/"+name+"/reposo_", ".png", _reposo);
    hover = loadImages(escenarios[escenarioActual].name+"/"+name+"/hover_", ".png", _hover);
    playing = loadImages(escenarios[escenarioActual].name+"/"+name+"/playing_", ".png", _playing);
    special = loadImages(escenarios[escenarioActual].name+"/"+name+"/special_", ".png", _special);

    // Audio
    sonido = _sonido;
    _audio = new OscMessage("/audio");
    _audio.add(sonido);
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
        if( estado.equals("hover") ){
          // Ya está activo
        } else {
          estado = "activar";
        }
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
        if( millis()-timer >= 100 ){          
          frame ++;
          timer = millis();
        }
      } else {
        frame = 0;
        image(reposo[frame], 0, 0, w, h);
      }
    } 
    
    if( estado.equals("activar") ){

      // Disparar sonido
      oscP5.send(_audio, direccionRemota);

      // Si es la cajita musical
      if( name == "hueco" ){
        llave = true;
      }

      // Si es el dragon y suena la cajita
      if( name == "dragon" && llave == true ){
        estado = "special";
        pasarNivel = true;
      } else {
        estado = "hover";
      }

      // Si es la puerta y tenes la llave
      if( name == "puerta" && pasarNivel == true ){
        println("Pasaste de nivel");
        // Cambiar estado
        escenarioActual = 0;
        estado = "encendiendo";
      }

    }
    
    if( estado.equals("hover") && hover.length>0 ){
      if( frame < framesHover ){
        image(hover[frame], 0, 0, w, h);
        if( millis()-timer >= 100 ){
          frame ++;
          timer = millis();
        }
      } else {
        frame = 0;
        image(hover[frame], 0, 0, w, h);
      }
    }
    
    if( estado.equals("special") && hover.length>0 ){
      if( frame < framesSpecial ){
        image(special[frame], 0, 0, w, h);
        if( millis()-timer >= 100 ){
          frame ++;
          timer = millis();
        }
      } else {
        frame = 0;
        image(special[frame], 0, 0, w, h);
      }
    }

    popMatrix();
  }
}