abstract class Player extends Entity {
  //private final float viewAngle;
  //private final float viewDistance;
  //private final float viewDistSquare;
  private final ViewField[] viewFields;
  private final int viewFieldMax;

  private int selectedView=0;  
  final Tank vehicle;

  //private float facing;
  //private float x;
  //private float y;

  public Player(ViewField[] viewFields, Tank vehicle) {
    super(vehicle.getX(), vehicle.getY(), vehicle.getFacing());
    this.viewFields=viewFields;
    this.viewFieldMax=viewFields.length-1;
    this.vehicle=vehicle;
  }

  public boolean isInView(float checkX, float checkY) {
    return viewFields[selectedView].isInView(x,y,facing,checkX,checkY);
  }
  
  public void changeView(int del) {
    selectedView+=del;
    selectedView=constrain(selectedView,0,viewFieldMax);
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
  }

  public boolean contains(float x, float y) {
    return false;
  }
  public void damage(int damage) {
  }
  
  public float getThickness() {
    return 0;
  }

  abstract public void handleKeyInput(Map<Character, Boolean> keys);
}

public class TestPlayer extends Player {
  public TestPlayer() {
    this(playerTank);
  }
  
  public TestPlayer(Tank vehicle) {
     super(new ViewField[]{new ViewField(TWO_PI, 200, 3)},vehicle);
  }
  
  public void handleKeyInput(Map<Character, Boolean> keys) {
    if (keys.getOrDefault(',', false)) {
      playerTank.drive(1);
    } else if (keys.getOrDefault('o', false)) {
      playerTank.drive(-0.5);
    }

    if (keys.getOrDefault('a', false)) {
      playerTank.turn(-1);
    } else if (keys.getOrDefault('e', false)) {
      playerTank.turn(1);
    }

    if (keys.getOrDefault('\'', false)) {
      playerTank.aimTurret(-1);
    } else if (keys.getOrDefault('.', false)) {
      playerTank.aimTurret(1);
    }

    if (keys.getOrDefault(' ', false)) {
      playerTank.fire();
    }

    if (keys.getOrDefault('d', false)) {
      playerTank.damage(1);
    } else if (keys.getOrDefault('h', false)) {
      playerTank.damage(-5);
    }
  }
  
  public void update() {
    super.update();
    turnTo(playerTank.getTurretFacing());
  }
}

public class Commander extends Player {
  private static final float TURN_RATE = PI/15;
  
  public Commander(Tank vehicle) {
    super(new ViewField[]{new ViewField(3*PI/4, 120,2),new ViewField(3*PI/5,200,3)}, vehicle);
  }
  
  public void handleKeyInput(Map<Character, Boolean> keys) {
    if (keys.getOrDefault('a', false)) {
      turnBy(-TURN_RATE);
    } else if (keys.getOrDefault('e', false)) {
      turnBy(TURN_RATE);
    }
    
    if (keys.getOrDefault('\'', false)) {
      turnBy(-TURN_RATE/2);
    } else if (keys.getOrDefault('.', false)) {
      turnBy(TURN_RATE/2);
    }
    
    if (keys.getOrDefault(',', false)) {
      changeView(1);
    } else if (keys.getOrDefault('o', false)) {
      changeView(-1);
    }
  }
}

public class Driver extends Player {
  public Driver(Tank vehicle) {
    super(new ViewField[]{new ViewField(PI/2, 160, 2)}, vehicle);
  }
  
  public void handleKeyInput(Map<Character, Boolean> keys) {
  if (keys.getOrDefault(',', false)) {
      vehicle.drive(1);
    } else if (keys.getOrDefault('o', false)) {
      vehicle.drive(-0.5);
    }
    
    if (keys.getOrDefault('\'', false)) {
      vehicle.turn(-0.5);
    } else if (keys.getOrDefault('.', false)) {
      vehicle.turn(0.5);
    }
    
    if (keys.getOrDefault('a', false)) {
      vehicle.turn(-1);
    } else if (keys.getOrDefault('e', false)) {
      vehicle.turn(1);
    }
  }
  
  public void update() {
    super.update();
    turnTo(vehicle.getFacing());
  }
}

public class Gunner extends Player {
  public Gunner(Tank vehicle) {
    super(new ViewField[]{new ViewField(PI/6, 70, 1),new ViewField(PI/10,140,2)}, vehicle);
  }
  
  public void handleKeyInput(Map<Character, Boolean> keys) {
     if (keys.getOrDefault('a', false)) {
      vehicle.aimTurret(-1);
    } else if (keys.getOrDefault('e', false)) {
      vehicle.aimTurret(1);
    }
    
    if (keys.getOrDefault('\'', false)) {
      vehicle.aimTurret(-0.5);
    } else if (keys.getOrDefault('.', false)) {
      vehicle.aimTurret(0.5);
    }
    
    if (keys.getOrDefault(',', false)) {
      changeView(1);
    } else if (keys.getOrDefault('o', false)) {
      changeView(-1);
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
