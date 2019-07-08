abstract class Player extends Entity {
  private final float viewAngle;
  private final float viewDistance;
  private final float viewDistSquare;
  
  final Tank vehicle;

  //private float facing;
  //private float x;
  //private float y;

  public Player(float viewAngle, float viewDistance, Tank vehicle) {
    super(vehicle.getX(), vehicle.getY(), vehicle.getFacing());
    this.viewAngle=viewAngle;
    this.viewDistance=viewDistance;
    this.vehicle=vehicle;
    viewDistSquare=viewDistance*viewDistance;
  }

  public boolean isInView(float x, float y) {
    float distSquare=findSquareDist(x, y, this.x, this.y);
    if (distSquare>=viewDistSquare)return false;

    float angle=atan2(y-this.y, x-this.x);
    angle=(angle+TWO_PI)%TWO_PI;
    float viewArc = viewAngle/2;
    //herein lies the problem
    float seperation = abs(facing-angle)%TWO_PI;
    return (seperation<=viewArc||seperation>=TWO_PI-viewArc);
  }

  public void moveTo(Entity e) {
    moveTo(e.getX(), e.getY());
  }

  public float getViewDist() {
    return viewDistance;
  }

  public void render() {
    stroke(255, 50, 70);
    line(x, y, x+cos(facing)*viewDistance, y+sin(facing)*viewDistance);
  }

  public void update() {}

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
    super(TWO_PI, 200, playerTank);
  }
  
  public TestPlayer(Tank vehicle) {
     super(TWO_PI, 200, vehicle);
  }
  
  public void handleKeyInput(Map<Character, Boolean> keys) {
    if (keys.getOrDefault(',', false)) {
      playerTank.drive();
      testPlayer.moveTo(playerTank);
    } else if (keys.getOrDefault('o', false)) {
      playerTank.back();    
      testPlayer.moveTo(playerTank);
    }

    if (keys.getOrDefault('a', false)) {
      playerTank.turn(-1);
      turnTo(playerTank.getTurretFacing());
    } else if (keys.getOrDefault('e', false)) {
      playerTank.turn(1);
      turnTo(playerTank.getTurretFacing());
    }

    if (keys.getOrDefault('\'', false)) {
      playerTank.aimTurret(-1);
      testPlayer.turnTo(playerTank.getTurretFacing());
    } else if (keys.getOrDefault('.', false)) {
      playerTank.aimTurret(1);
      testPlayer.turnTo(playerTank.getTurretFacing());
    }

    if (keys.getOrDefault(' ', false)) {
      playerTank.fire();
    }

    if (keys.getOrDefault('s', false)) {
      stop();
    }

    if (keys.getOrDefault('d', false)) {
      playerTank.damage(1);
    } else if (keys.getOrDefault('h', false)) {
      playerTank.damage(-5);
    }
  }
}

public class Commander extends Player {
  private static final float TURN_RATE = PI/15;
  
  public Commander(Tank vehicle) {
    super(3*PI/4, 100, vehicle);
  }
  
  public void handleKeyInput(Map<Character, Boolean> keys) {
    if (keys.getOrDefault('a', false)) {
      turnBy(-TURN_RATE);
    } else if (keys.getOrDefault('e', false)) {
      turnBy(TURN_RATE);
    }
  };
}

public class Driver extends Player {
  public Driver(Tank vehicle) {
    super(PI/2, 160, vehicle);
  }
  
  public void handleKeyInput(Map<Character, Boolean> keys) {
  if (keys.getOrDefault(',', false)) {
      vehicle.drive();
      moveTo(vehicle);
    } else if (keys.getOrDefault('o', false)) {
      vehicle.back();    
      moveTo(vehicle);
    }
    
    if (keys.getOrDefault('a', false)) {
      vehicle.turn(-1);
      turnTo(vehicle.getFacing());
    } else if (keys.getOrDefault('e', false)) {
      vehicle.turn(1);
      turnTo(vehicle.getFacing());
    }
  };
}

public class Gunner extends Player {
  public Gunner(Tank vehicle) {
    super(PI/6, 70, vehicle);
  }
  
  public void handleKeyInput(Map<Character, Boolean> keys) {
     if (keys.getOrDefault('a', false)) {
      vehicle.aimTurret(-1);
      testPlayer.turnTo(vehicle.getTurretFacing());
    } else if (keys.getOrDefault('e', false)) {
      vehicle.aimTurret(1);
      testPlayer.turnTo(vehicle.getTurretFacing());
    }
    
    if (keys.getOrDefault('\'', false)) {
      vehicle.aimTurret(-0.5);
      testPlayer.turnTo(vehicle.getTurretFacing());
    } else if (keys.getOrDefault('.', false)) {
      vehicle.aimTurret(0.5);
      testPlayer.turnTo(vehicle.getTurretFacing());
    }
  };
}
