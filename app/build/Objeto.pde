class Objeto {

  //.h
  int universo; // Universo
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
  int k;

  // Constructor
  Objeto ( int _universo, float _x, float _y, float _z, int _w, int _h, boolean _interactive, String _name, int _reposo, int _hover, int _playing, int _special, int _sonido) {
    universo = _universo;
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
    k=1;

    // Imagen
    // loadImages( String nombre, String extensión, int cantidad_de_frames );
    reposo = loadImages(escenarios[universo].name+"/"+name+"/reposo_", ".png", _reposo);
    hover = loadImages(escenarios[universo].name+"/"+name+"/hover_", ".png", _hover);
    playing = loadImages(escenarios[universo].name+"/"+name+"/playing_", ".png", _playing);
    special = loadImages(escenarios[universo].name+"/"+name+"/special_", ".png", _special);

    // Audio
    sonido = _sonido;
    _audio = new OscMessage("/audio");
    _audio.add(sonido);
  }

  // Actualizar
  void update() {
    x = width/2+posicion.x+tracker.x*posicion.z; 
    y = height/2+posicion.y;

    if( name == "peces" ){
      x = width/2+posicion.x+k+tracker.x*posicion.z;
    }
    if( name == "nubes" ){
      x = width/2+posicion.x+k*0.1+tracker.x*posicion.z;
    }
    if( k > 1500 ){
      k = -1500;
    } else {
      k += random(0,2);
    }

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
      // Si es el perchero con la llave
      if( name == "llaveSotano" && pasarNivel == true ){
        estado = "special";
      }
      else if( frame < framesReposo ){
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

      // Si es la cajita musical y no tiene la llave
      if( name == "hueco" && llave == false ){
        llave = true;
        estado = "hover";
      }

      // Si es el dragon y suena la cajita
      else if( name == "dragon" && llave == true && pasarNivel == false ){
        estado = "special";
      }

      // Si es la puerta y tenes la llave
      else if( name == "puerta" && pasarNivel == true ){
        if( escenarioActual == 1 ){
          pasarNivel = false;
          escenarioActual = 2; 
        }
        estado = "encendiendo";
      }

      // Si es el perchero sin la llave
      else if( name == "llaveSotano" && pasarNivel == false ){
        pasarNivel = true;
      }

      // Si es el perchero con la llave
      else if( name == "llaveSotano" && pasarNivel == true ){
        estado = "special";
      }

      // Si es el cofre y tenes la llave
      else if( name == "cofre" && pasarNivel == true ){
        // Pasajes de universos
        if( escenarioActual == 0 ){ 
          // Si detecta a un personaje, cambia la secuencia
          pasarNivel = false;
          escenarioActual = 1;
          estadoApp = 3;
          cofre.jump(0);
          cofre.play();
        }
        estado = "encendiendo";
      }

      // Si no pasa nada de esto
      else {
        estado = "hover";
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
        
        // Si es el dragon, suena la cajita, y no tiene agarro la llave
        if( name == "dragon" && pasarNivel == false){
          pasarNivel = true;
        }
      }
    }

    popMatrix();
  }
}