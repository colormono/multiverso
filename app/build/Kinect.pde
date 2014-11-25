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

void dibujarCuerpo( int userId ) {
  // Crear un vector para obtener la posición
  PVector cuerpo = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_TORSO, cuerpo );
  // Crear un vector para proyectar en 2D
  PVector cuerpo_2d = new PVector(); 
  // Convertir la posición 3D al 2D de la pantalla
  context.convertRealWorldToProjective(cuerpo, cuerpo_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1cuerpo, cuerpo_2d.x, cuerpo_2d.y);
  }  else {
    image(p2cuerpo, cuerpo_2d.x, cuerpo_2d.y);
  }
}

//---------------------------------------------------------------

void dibujarCabeza( int userId ) {
  // Crear un vector para obtener la posición
  PVector cabeza = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_HEAD, cabeza );
  // Crear un vector para proyectar en 2D
  PVector cabeza_2d = new PVector(); 
  // Convertir la posición 3D al 2D de la pantalla
  context.convertRealWorldToProjective(cabeza, cabeza_2d);
  // a 200 pixel diameter head
  //float headsize = 500; 
  // create a distance scalar related to the depth (z dimension)
  //float distanceScalar = (525/cabeza_2d.z);
  // Dibujar
  if( userId == 1 ){
    //image(p1cabeza, cabeza_2d.x, cabeza_2d.y, distanceScalar*headsize, distanceScalar*headsize );
    image(p1cabeza, cabeza_2d.x, cabeza_2d.y-70 );
  }  else {
    //image(p2cabeza, cabeza_2d.x, cabeza_2d.y, distanceScalar*headsize, distanceScalar*headsize );
    image(p2cabeza, cabeza_2d.x, cabeza_2d.y-50 );
  }
  // Si está la llave activa
  if( pasarNivel ){
    image(llavePrendida, cabeza_2d.x, p2cabeza.height-llavePrendida.height*2);
  }
}

//---------------------------------------------------------------

void dibujarManoIzquierda( int userId ) {
  // Crear un vector para obtener la posición

  PVector manoIzquierda = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_LEFT_ELBOW, manoIzquierda );
  // Crear un vector para proyectar en 2D
  PVector manoIzquierda_2d = new PVector(); 
  // Convertir la posición 3D al 2D de la pantalla
  context.convertRealWorldToProjective(manoIzquierda, manoIzquierda_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1manoi, manoIzquierda_2d.x, manoIzquierda_2d.y);
  }  else {
    image(p2manoi, manoIzquierda_2d.x, manoIzquierda_2d.y);
  }
}

//---------------------------------------------------------------

void dibujarManoDerecha( int userId ) {
  // Crear un vector para obtener la posición
  PVector manoDerecha = new PVector();
  context.getJointPositionSkeleton( userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, manoDerecha );
  // Crear un vector para proyectar en 2D
  PVector manoDerecha_2d = new PVector(); 
  // Convertir la posición 3D al 2D de la pantalla
  context.convertRealWorldToProjective(manoDerecha, manoDerecha_2d);
  // Dibujar
  if( userId == 1 ){
    image(p1manoi, manoDerecha_2d.x, manoDerecha_2d.y);
  }  else {
    image(p2manoi, manoDerecha_2d.x, manoDerecha_2d.y);
  }
}

//---------------------------------------------------------------
// Al detectar nuevo usuario

void onNewUser(SimpleOpenNI curContext, int userId) {
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");
  curContext.startTrackingSkeleton(userId);

  // Cambios de estado de la app
  if( estadoApp == 0 ){
    // Si detecta a un personaje, cambia la secuencia
    estadoApp = 1;
    intro.jump(0);
    intro.play();
  }

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
