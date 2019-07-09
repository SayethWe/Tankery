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

void addAlert(float x, float y, color col){
  alerts.add(new Alert(x,y,col));
}

class Alert{
  public static final color ALERT_ORANGE = #FF6700;
  public static final color ALERT_BLUE = #83DBF5;
  public static final color ALERT_PINK = #FF36EB;
  
  private static final int DURATION = 90;
  private static final int FLASH_ON=5;
  private static final int FLASH_OFF=7;
  
  private final PShape render;
  private final float x,y;
  private int durationTimer;
  private int flashTimer = 0;
  private boolean flash = false;
  
  public Alert(float x, float y, color col) {
    this.x = x;
    this.y = y;
    this.render=createShape();
    this.durationTimer=DURATION;
    
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
    render.setFill(col);
  }
  
  public void update() {
    durationTimer--;
    flashTimer--;
    if(durationTimer<=0) markToRemove();
    if(flashTimer<=0) {
      flash=!flash;
      if(flash) {
        flashTimer=FLASH_ON;
      } else {
        flashTimer=FLASH_OFF;
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
