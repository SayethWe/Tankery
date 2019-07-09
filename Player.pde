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
    super(vehicle.getX(), vehicle.getY(), vehicle.getFacing());
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
    moveTo(vehicle);
    viewCoolDown--;
  }

  abstract public void handleKeyInput(Map<Keybind, Boolean> keys);
}

public class TestPlayer extends Player {
  public TestPlayer() {
    this(playerTank);
  }
  
  public TestPlayer(Tank vehicle) {
     super(vehicle, new ViewField(TWO_PI, 200, 3));
  }
  
  public void handleKeyInput(Map<Keybind, Boolean> keys) {
    if (keys.getOrDefault(Keybind.FRONT, false)) {
      playerTank.drive(1);
    } else if (keys.getOrDefault(Keybind.BACK, false)) {
      playerTank.drive(-0.5);
    }

    if (keys.getOrDefault(Keybind.LEFT, false)) {
      playerTank.turn(-1);
    } else if (keys.getOrDefault(Keybind.RIGHT, false)) {
      playerTank.turn(1);
    }

    if (keys.getOrDefault(Keybind.SLOW_LEFT, false)) {
      playerTank.aimTurret(-1);
    } else if (keys.getOrDefault(Keybind.SLOW_RIGHT, false)) {
      playerTank.aimTurret(1);
    }

    if (keys.getOrDefault(Keybind.ACTION, false)) {
      playerTank.fire();
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
  
  public void handleKeyInput(Map<Keybind, Boolean> keys) {
    if (keys.getOrDefault(Keybind.LEFT, false)) {
      turnBy(-TURN_RATE);
    } else if (keys.getOrDefault(Keybind.RIGHT, false)) {
      turnBy(TURN_RATE);
    } else if (keys.getOrDefault(Keybind.SLOW_LEFT, false)) {
      turnBy(-TURN_RATE/2);
    } else if (keys.getOrDefault(Keybind.SLOW_RIGHT, false)) {
      turnBy(TURN_RATE/2);
    }
    
    if (keys.getOrDefault(Keybind.FRONT, false)) {
      changeView(1);
    } else if (keys.getOrDefault(Keybind.BACK, false)) {
      changeView(-1);
    }
    
    if (keys.getOrDefault(Keybind.ACTION, false)) {
      alert();
    }
  }
}

public class Driver extends Player {
  public Driver(Tank vehicle) {
    super(vehicle, new ViewField(PI/2, 160, 2));
  }
  
  public void handleKeyInput(Map<Keybind, Boolean> keys) {
  if (keys.getOrDefault(Keybind.FRONT, false)) {
      vehicle.drive(1);
    } else if (keys.getOrDefault(Keybind.BACK, false)) {
      vehicle.drive(-0.5);
    }
    
    if (keys.getOrDefault(Keybind.SLOW_LEFT, false)) {
      vehicle.turn(-0.5);
    } else if (keys.getOrDefault(Keybind.SLOW_RIGHT, false)) {
      vehicle.turn(0.5);
    } else if (keys.getOrDefault(Keybind.LEFT, false)) {
      vehicle.turn(-1);
    } else if (keys.getOrDefault(Keybind.RIGHT, false)) {
      vehicle.turn(1);
    }
    
    //kind of want a spacebar action here
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
  
  public void handleKeyInput(Map<Keybind, Boolean> keys) {
     if (keys.getOrDefault(Keybind.LEFT, false)) {
      vehicle.aimTurret(-1);
    } else if (keys.getOrDefault(Keybind.RIGHT, false)) {
      vehicle.aimTurret(1);
    } else if (keys.getOrDefault(Keybind.SLOW_LEFT, false)) {
      vehicle.aimTurret(-0.5);
    } else if (keys.getOrDefault(Keybind.SLOW_RIGHT, false)) {
      vehicle.aimTurret(0.5);
    }
    
    if (keys.getOrDefault(Keybind.FRONT, false)) {
      changeView(1);
    } else if (keys.getOrDefault(Keybind.BACK, false)) {
      changeView(-1);
    }
    
    if (keys.getOrDefault(Keybind.ACTION, false)) {
      playerTank.fire();
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
    float seperation = abs(facing-angle)%TWO_PI;
    return (seperation<=viewArc||seperation>=TWO_PI-viewArc);
  }
  
  public float getViewDistance() {
    return viewDistance;
  }
  
  public int getFogScale() {
    return fogScale;
  }
  
}
