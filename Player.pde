abstract class Player extends Entity {
  private final float viewAngle;
  private final float viewDistance;
  private final float viewDistSquare;

  //private float facing;
  //private float x;
  //private float y;

  public Player(float viewAngle, float viewDistance) {
    super(0, 0, 0);
    this.viewAngle=viewAngle;
    this.viewDistance=viewDistance;
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

  public void update() {
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
    super(TWO_PI, 200);
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
    } else if (keys.getOrDefault('e', false)) {
      playerTank.turn(1);
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
  public Commander() {
    super(TWO_PI, 100);
  }
  
  public void handleKeyInput(Map<Character, Boolean> keys) {};
}

public class Driver extends Player {
  public Driver() {
    super(PI/2, 160);
  }
  
  public void handleKeyInput(Map<Character, Boolean> keys) {};
}

public class Gunner extends Player {
  public Gunner() {
    super(PI/6, 70);
  }
  
  public void handleKeyInput(Map<Character, Boolean> keys) {};
}
