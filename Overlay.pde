//final int FOG_SCALE_FACTOR=2;

Set<Alert> alerts = new HashSet<Alert>();
Set<Alert> deadAlerts = new HashSet<Alert>();

public void drawUI() {
    float healthWidth=width*playerTank.getHealth()/playerTank.maxHealth;
    int healthHeight = 15;
    rectMode(CORNER);
    noStroke();
    fill(255,0,0);
    rect(0,height-healthHeight,width,healthHeight);
    fill(0,255,0);
    rect(0,height-healthHeight,healthWidth,healthHeight);
    handleAlerts();
}

void handleAlerts() {
  for(Alert a: alerts) {
    a.update();
    a.render();
  }
  alerts.removeAll(deadAlerts);
  deadAlerts.clear();
}

void handleFog() {
  int fogScale=testPlayer.getFogScale();
  int tpx=int(testPlayer.getX());
  int tpy=int(testPlayer.getY());
  int tpv=int(testPlayer.getViewDist());

  stroke(128);
  fill(128);
  rectMode(CORNER);
  for(int i = -tpv;i<=tpv;i+=fogScale){
    for(int j = -tpv;j<=tpv;j+=fogScale){
      int x=tpx+i;
      int y=tpy+j;
      if ((x>=0&&x<=width)&&(y>=0&&y<=height)){
        if (!testPlayer.isInView(x,y)) {
        //if(!playerTank.contains(x,y)) {
          rect(x,y,fogScale,fogScale);
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

int addAlert(float x, float y, AlertLevel level){
  alerts.add(new Alert(x,y,level));
  logger.log(level + " alert spawned at " +x+","+y);
  return level.duration/3;
}

class Alert{
  
  //private static final int DURATION = 90;
  //private static final int FLASH_ON=5;
  //private static final int FLASH_OFF=7;
  
  private final int flashOn;
  private final int flashOff;
  
  private final PShape render;
  private final float x,y;
  private int durationTimer;
  private int flashTimer = 0;
  private boolean flash = false;
  
  public Alert(float x, float y, AlertLevel level) {
    this.x = x;
    this.y = y;
    this.flashOn=level.on;
    this.flashOff=level.off;
    this.durationTimer=level.duration;
    
    this.render=createShape();
    render.beginShape();
    render.vertex(0,0);
    render.vertex(3,-3);
    render.vertex(0,-6);
    render.vertex(6,-23);
    render.vertex(0,-27);
    render.vertex(-6,-23);
    render.vertex(0,-6);
    render.vertex(-3,-3);
    render.endShape(CLOSE);
    render.setStroke(false);
    render.setFill(level.col);
  }
  
  public void update() {
    durationTimer--;
    flashTimer--;
    if(durationTimer<=0) markToRemove();
    if(flashTimer<=0) {
      flash=!flash;
      if(flash) {
        flashTimer=flashOn;
      } else {
        flashTimer=flashOff;
      }
    }
  }
  
  public void markToRemove() {
    deadAlerts.add(this);
  }
  
  public void render() {
    if(flash) {
    pushMatrix();
    translate(x,y);
    shape(render);
    popMatrix();
    }
  }
}

enum AlertLevel {
  ORANGE(#FF6700,90,5,7),
  BLUE(#83DBF5,60,10,16),
  PINK(#FF36EB,45,15,15);
  
  public final color col;
  public final int duration,on,off;
  
  private AlertLevel(color col, int duration, int on, int off) {
    this.col=col;
    this.duration=duration;
    this.on=on;
    this.off=off;
  }
  
}
