final int FOG_SCALE_FACTOR=2;

public void drawUI() {
    float healthWidth=width*playerTank.getHealth()/playerTank.maxHealth;
    int healthHeight = 15;
    rectMode(CORNER);
    noStroke();
    fill(255,0,0);
    rect(0,height-healthHeight,width,healthHeight);
    fill(0,255,0);
    rect(0,height-healthHeight,healthWidth,healthHeight);
}

void handleFog() {
  int tpx=int(testPlayer.getX());
  int tpy=int(testPlayer.getY());
  int tpv=int(testPlayer.getViewDist());

  stroke(128);
  fill(128);
  rectMode(CORNER);
  for(int i = -tpv;i<=tpv;i+=FOG_SCALE_FACTOR){
    for(int j = -tpv;j<=tpv;j+=FOG_SCALE_FACTOR){
      int x=tpx+i;
      int y=tpy+j;
      if ((x>=0&&x<=width)&&(y>=0&&y<=height)){
        if (!testPlayer.isInView(x,y)) {
        //if(!playerTank.contains(x,y)) {
          rect(x,y,FOG_SCALE_FACTOR,FOG_SCALE_FACTOR);
        }
      }
    }
  }
  rectMode(CORNERS);
  rect(0,0,tpx-tpv,tpy+tpv);
  rect(tpx-tpv,0,width,tpy-tpv);
  rect(tpx+tpv,tpy-tpv,width,height);
  rect(0,tpy+tpv,tpx+tpv, height);
}
