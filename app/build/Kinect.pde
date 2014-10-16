void drawSkeleton(int userId) {
  pushStyle();
  stroke(0, 0, 255);
  strokeWeight(3);

  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);

  popStyle();
}

//---------------------------------------------------------------

void dibujarCuerpo( int userId, float _y ) {
  // Crear un vector para obtener la posición
  PVector cuerpo = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_TORSO, cuerpo );
  // Crear un vector para proyectar en 2D
  PVector cuerpo_2d = new PVector(); 
  // Convertir la posición 3D al 2D de la pantalla
  context.convertRealWorldToProjective(cuerpo, cuerpo_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1cuerpo, cuerpo_2d.x, _y);
  }  else if ( userId == 2 ){
    image(p2cuerpo, cuerpo_2d.x, _y);
  }
}

//---------------------------------------------------------------

void dibujarCabeza( int userId, float _y ) {
  // Crear un vector para obtener la posición
  PVector cabeza = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_HEAD, cabeza );
  // Crear un vector para proyectar en 2D
  PVector cabeza_2d = new PVector(); 
  // Convertir la posición 3D al 2D de la pantalla
  context.convertRealWorldToProjective(cabeza, cabeza_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1cabeza, cabeza_2d.x, _y-145);
  }  else if ( userId == 2 ){
    image(p2cabeza, cabeza_2d.x, _y-145);
  }
}

//---------------------------------------------------------------

void dibujarManoIzquierda( int userId, float _y ) {
  // Crear un vector para obtener la posición
  PVector manoIzquierda = new PVector();
  PVector hombroIzquierdo = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_LEFT_HAND, manoIzquierda );
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, hombroIzquierdo );
  // Crear un vector para proyectar en 2D
  PVector manoIzquierda_2d = new PVector(); 
  PVector hombroIzquierdo_2d = new PVector(); 
  // Convertir la posición 3D al 2D de la pantalla
  context.convertRealWorldToProjective(manoIzquierda, manoIzquierda_2d);
  context.convertRealWorldToProjective(hombroIzquierdo, hombroIzquierdo_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1manoi, hombroIzquierdo_2d.x+manoIzquierda_2d.x*0.2, _y-120-manoIzquierda_2d.y*0.3);
  }  else if ( userId == 2 ){
    image(p2manoi, hombroIzquierdo_2d.x+manoIzquierda_2d.x*0.2, _y-120-manoIzquierda_2d.y*0.3);
  }
}

//---------------------------------------------------------------

void dibujarManoDerecha( int userId, float _y ) {
  // Crear un vector para obtener la posición
  PVector manoDerecha = new PVector();
  PVector hombroDerecho = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_LEFT_HAND, manoDerecha );
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, hombroDerecho );
  // Crear un vector para proyectar en 2D
  PVector manoDerecha_2d = new PVector(); 
  PVector hombroDerecho_2d = new PVector(); 
  // Convertir la posición 3D al 2D de la pantalla
  context.convertRealWorldToProjective(manoDerecha, manoDerecha_2d);
  context.convertRealWorldToProjective(hombroDerecho, hombroDerecho_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1manoi, hombroDerecho_2d.x-manoDerecha_2d.x*0.2, _y-120-manoDerecha_2d.y*0.3);
  }  else if ( userId == 2 ){
    image(p2manoi, hombroDerecho_2d.x-manoDerecha_2d.x*0.2, _y-120-manoDerecha_2d.y*0.3);
  }
}

//---------------------------------------------------------------
// Al detectar nuevo usuario

void onNewUser(SimpleOpenNI curContext, int userId) {
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  curContext.startTrackingSkeleton(userId);

  // Activar botón de iniciar
  iniciar = true;
}

//---------------------------------------------------------------
// Al perder usuario

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("onLostUser - userId: " + userId);
}

//---------------------------------------------------------------
// Al ver usuario

void onVisibleUser(SimpleOpenNI curContext, int userId) {
  //println("onVisibleUser - userId: " + userId);
}
