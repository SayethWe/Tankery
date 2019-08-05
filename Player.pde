//the bit what does the thinky-stuff for the person behind the keyboard
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
  
  public Shape getViewPoly() {
    return viewFields[selectedView].createViewPolygon(x,y,facing);
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
    //stroke(255, 50, 70);
    //float viewLength = viewFields[selectedView].getViewDistance();
    //line(x, y, x+cos(facing)*viewLength, y+sin(facing)*viewLength);
    //if(this.equals(testPlayer)) viewFields[selectedView].render(x,y,facing);
  }

  public void update() {
    if(vehicle.isDead()) this.markToRemove();
    //moveTo(vehicle);
    viewCoolDown--;
  }

  abstract public void handleKeyInput(Keybind kb);
}

//A multi-tasking role for testing purposes
public class TestPlayer extends Player {
  public TestPlayer() {
    this(playerTank);
  }
  
  public TestPlayer(Tank vehicle) {
     super(vehicle, new ViewField(5*TWO_PI/6, 200, 3));
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
      vehicle.fireMain();
      vehicle.fireMachine();
      break;
      
      case AUXILIARY:
      vehicle.brake();
      break;
      
      case UNKNOWN:
      break;
      
      default:
      throw new IllegalArgumentException("TestPlayer: Unimplemented Keybind: " + kb);
    }
  }
  
  public void update() {
    super.update();
    moveTo(vehicle);
    turnTo(playerTank.getTurretDirection());
  }
}

//Spots things, gives alerts.
public class Commander extends Player {
  private static final float TURN_RATE = PI/15;
  //private static final int ALERT_COOLDOWN = 50;
  
  private int alertTimer;
  private int artilleryTimer;
  
  public Commander(Tank vehicle) {
    super(vehicle, new ViewField(3*PI/4, 120,2),new ViewField(3*PI/7,200,3),new ViewField(PI/6,300,5));
  }
  
  public void update() {
    super.update();
    moveTo(vehicle.getTurretPivotX(),vehicle.getTurretPivotY());
    alertTimer--;
    artilleryTimer--;
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
      
      case AUXILIARY:
      //TODO
      if(artilleryTimer<=0&&isInView(mouseX,mouseY)) {
        explosion(mouseX,mouseY,5,100,team);
       artilleryTimer=10; 
      }
      break;
      
      case UNKNOWN:
      break;
      
      default:
      throw new IllegalArgumentException("Commander: Unimplemented Keybind: " + kb);
    }
  }
}

//moves the tank
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
      
      case AUXILIARY:
      vehicle.fireMachine();
      break;
      
      default:
      throw new IllegalArgumentException("Driver: Unimplemented Keybind: " + kb);
    }
  }
  
  public void update() {
    super.update();
    moveTo(vehicle);
    turnTo(vehicle.getFacing());
  }
}

//spins the turret, shoots at bad guys
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
      vehicle.fireMain();
      break;
      
      case AUXILIARY:
      //undecided
      break;
      
      case UNKNOWN:
      break;
      
      default:
      throw new IllegalArgumentException("Gunner: Unimplemented Keybind: " + kb);
    }
  }
  
  public void update() {
    super.update();
    moveTo(vehicle.getTurretPivotX(),vehicle.getTurretPivotY());
    turnTo(vehicle.getTurretDirection());
  }
}
