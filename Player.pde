abstract class Player extends Entity {
  //private final float viewAngle;
  //private final float viewDistance;
  //private final float viewDistSquare;
  private final static int VIEW_COOL_DOWN = 15;
  
  private final ViewField[] viewFields;
  private final int viewFieldMax;

  private int selectedView=0;
  private int viewCoolDown=0;
  final Tank vehicle;

  //private float facing;
  //private float x;
  //private float y;

  public Player(Tank vehicle, ViewField... viewFields) {
    super(vehicle.getX(), vehicle.getY(), vehicle.getFacing(), vehicle.team);
    this.viewFields=viewFields;
    this.viewFieldMax=viewFields.length-1;
    this.vehicle=vehicle;
  }

  public boolean isInView(float checkX, float checkY) {
    return viewFields[selectedView].isInView(x,y,facing,checkX,checkY);
  }
  
  public void changeView(int del) {
    if(viewCoolDown<=0) {
      selectedView+=del;
      selectedView=constrain(selectedView,0,viewFieldMax);
      viewCoolDown=VIEW_COOL_DOWN;
    }
  }

  public void moveTo(Entity e) {
    moveTo(e.getX(), e.getY());
  }

  public float getViewDist() {
    return viewFields[selectedView].getViewDistance();
  }
  
  public int getFogScale() {
    return viewFields[selectedView].getFogScale();
  }

  public void render() {
    stroke(255, 50, 70);
    float viewLength = viewFields[selectedView].getViewDistance();
    line(x, y, x+cos(facing)*viewLength, y+sin(facing)*viewLength);
  }

  public void update() {
    if(vehicle.isDead()) this.markToRemove();
    moveTo(vehicle);
    viewCoolDown--;
  }

  abstract public void handleKeyInput(Keybind kb);
}

public class TestPlayer extends Player {
  public TestPlayer() {
    this(playerTank);
  }
  
  public TestPlayer(Tank vehicle) {
     super(vehicle, new ViewField(TWO_PI, 200, 3));
  }
  
  public void handleKeyInput(Keybind kb) {
    switch (kb) {
      case FRONT:
      vehicle.drive(1);
      break;
      case BACK:
      vehicle.drive(-0.5);
      break;
      
      case LEFT:
      vehicle.turn(-1);
      break;
      case RIGHT:
      vehicle.turn(1);
      break;
      
      case SLOW_LEFT:
      vehicle.aimTurret(-1);
      break;
      case SLOW_RIGHT:
      vehicle.aimTurret(1);
      break;
      
      case ACTION:
      vehicle.fire();
      break;
      
      case UNKNOWN:
      //baaaad implementation
      vehicle.brake();
      break;
      
      default:
      throw new IllegalArgumentException("TestPlayer: Unimplemented Keybind");
    }
  }
  
  public void update() {
    super.update();
    turnTo(playerTank.getTurretFacing());
  }
}

public class Commander extends Player {
  private static final float TURN_RATE = PI/15;
  //private static final int ALERT_COOLDOWN = 50;
  
  private int alertTimer;
  
  public Commander(Tank vehicle) {
    super(vehicle, new ViewField(3*PI/4, 120,2),new ViewField(3*PI/7,200,3),new ViewField(PI/6,300,5));
  }
  
  public void update() {
    super.update();
    alertTimer--;
  }
  
  private void alert() {
    if(alertTimer<=0) {
      float alertX = x+getViewDist()*cos(facing);
      float alertY = y+getViewDist()*sin(facing);
      alertTimer=addAlert(alertX, alertY, AlertLevel.ORANGE);
    }
  }
  
  public void handleKeyInput(Keybind kb) {
    switch(kb) {
      case FRONT:
      changeView(1);
      break;
      case BACK:
      changeView(-1);
      break;
      
      case LEFT:
      turnBy(-3*TURN_RATE/4);
      break;
      case RIGHT:
      turnBy(3*TURN_RATE/4);
      break;
      case SLOW_LEFT:
      turnBy(-TURN_RATE/4);
      break;
      case SLOW_RIGHT:
      turnBy(TURN_RATE/4);
      break;
      
      case ACTION:
      alert();
      break;
      
      case UNKNOWN:
      break;
      
      default:
      throw new IllegalArgumentException("Commander: Unimplemented Keybind");
    }
  }
}

public class Driver extends Player {
  public Driver(Tank vehicle) {
    super(vehicle, new ViewField(PI/2, 160, 2));
  }
  
  public void handleKeyInput(Keybind kb) {
    switch(kb) {
      case FRONT:
      vehicle.drive(1);
      break;
      case BACK:
      vehicle.drive(-0.5);
      break;
      
      case LEFT:
      vehicle.turn(-0.75);
      case SLOW_LEFT:
      vehicle.turn(-0.25);
      break;
      
      case RIGHT:
      vehicle.turn(0.75);
      case SLOW_RIGHT:
      vehicle.turn(0.25);
      break;
      
      case ACTION:
      vehicle.brake();
      case UNKNOWN:
      break;
      
      default:
      throw new IllegalArgumentException("Driver: Unimplemented Keybind");
    }
  }
  
  public void update() {
    super.update();
    turnTo(vehicle.getFacing());
  }
}

public class Gunner extends Player {
  public Gunner(Tank vehicle) {
    super(vehicle, new ViewField(PI/6, 70, 1), new ViewField(PI/10,140,2));
  }
  
  public void handleKeyInput(Keybind kb) {
    switch(kb) {
      case FRONT:
      changeView(1);
      break;
      case BACK:
      changeView(-1);
      break;
      
      case LEFT:
      vehicle.aimTurret(-0.75);
      case SLOW_LEFT:
      vehicle.aimTurret(-0.25);
      break;
      
      case RIGHT:
      vehicle.aimTurret(0.75);
      case SLOW_RIGHT:
      vehicle.aimTurret(0.25);
      break;
      
      case ACTION:
      vehicle.fire();
      break;
      
      case UNKNOWN:
      break;
      
      default:
      throw new IllegalArgumentException("Gunner: Unimplemented Keybind");
    }
  }
  
  public void update() {
    super.update();
    turnTo(vehicle.getTurretFacing());
  }
}

public class ViewField {
  
  private final float viewAngle;
  private final float viewDistance;
  private final float viewDistSquare;
  private final int fogScale;
  
  public ViewField(float viewAngle, float viewDistance, int resolution) {
    this.viewAngle = viewAngle;
    this.viewDistance = viewDistance;
    this.viewDistSquare = viewDistance*viewDistance;
    this.fogScale = resolution;
  }
  
  public boolean isInView(float x, float y, float facing, float checkX, float checkY) {
    float distSquare=findSquareDist(checkX, checkY, x, y);
    if (distSquare>=viewDistSquare)return false;

    float angle=atan2(checkY-y, checkX-x);
    angle=(angle+TWO_PI)%TWO_PI;
    float viewArc = viewAngle/2;
    //herein lies the problem
    float seperation = angleBetween(facing,angle);
    return (abs(seperation)<=viewArc);
  }
  
  public float getViewDistance() {
    return viewDistance;
  }
  
  public int getFogScale() {
    return fogScale;
  }
  
}
