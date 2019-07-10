import java.util.List;

public class AI extends Entity {
  private final float ANGLE_EPSILON = PI/100;
  private final float ANGLE_TURN = PI/4;
  private final float ANGLE_DRIVE = PI/8;
  
  private final float DIST_SLOW = 30;
  
  private final Tank vehicle;
  private final Route route;
  private Node target;
  private int delay=0;
  
  public AI(Tank vehicle, Route route) {
    super(vehicle);
    this.vehicle=vehicle;
    this.route=route;
    target = route.first();
  }
  
  public void render() {
    noFill();
    stroke(0);
    ellipseMode(RADIUS);
    ellipse(target.x,target.y,sqrt(target.tolerance),sqrt(target.tolerance));
    rectMode(CORNERS);
    line(x,y,target.x,target.y);
  }
  
  public void update() {
    if(vehicle.isDead()) markToRemove();
    this.moveTo(vehicle);
    this.turnTo(vehicle);
    
    if(delay<=0) {
      float dist = findSquareDist(x,y,target.x,target.y)-target.tolerance;
      println("distance: " + dist);
      if(dist<=0) {
        delay=target.delay;
        target=route.next();
        return;
      } else {
        float targetAngle=atan2(target.y-y,target.x-x);
        stroke(255,0,0);
        rectMode(CORNER);
        line(x,y,x+20*cos(targetAngle),y+20*sin(targetAngle));
        float angleDel = lessMassive((facing-targetAngle),(targetAngle-facing));
        println("Angle difference: "+angleDel+"="+facing+" - "+targetAngle);
        if (angleDel < -ANGLE_TURN) {
          vehicle.turn(-1);
        } else if (angleDel>ANGLE_TURN) {
          vehicle.turn(1);
        } else if(angleDel<-ANGLE_EPSILON) {
          vehicle.turn(-0.5);
        } else if (angleDel>ANGLE_EPSILON) {
          vehicle.turn(0.5);
        }
        if (abs(angleDel) < ANGLE_DRIVE) {
          if(dist>DIST_SLOW) {
            vehicle.drive(1);
          } else {
            vehicle.drive(0.5);
          }
        }
      }
    } else {
      delay--;
    }
  }
  
  private void moveTo(Entity e) {
    moveTo(e.getX(), e.getY());
  }
  
  private void turnTo(Entity e) {
    facing = e.getFacing()%TWO_PI;
  }
  
}

public class Route {
  
  private final List<Node> path;
  private final int nodes;
  private final boolean loop; //if true, go directly to first node when finished. if false, reverse along path
  private int node = 0;
  private boolean back=false; //are we going backwards along the loop
  
  public Route(List<Node> path, boolean loop) {
    this.path=path;
    nodes=path.size();
    this.loop=loop;
  }
  
  public Node next() {
    if(back) {
      node--;
    } else {
      node++;
    }
    if(node==nodes) {
      if(loop) {
        node = 0;
      } else {
        back=true;
        node-=2;
      }
    } else if (node < 0) {
      back=false;
    }
    return path.get(node);
  }
  
  public Node first() {
    node = 0;
    return path.get(0);
  }
  
}

static Route testRoute() {
  List<Node> path = new ArrayList<Node>(5);
  path.add(instance.new Node(475,350,5,18));
  path.add(instance.new Node(400,450,5,10));
  path.add(instance.new Node(300,425,5,13));
  path.add(instance.new Node(300,325,5,20));
  path.add(instance.new Node(400,275,5,20));
  return instance.new Route(path, true);
}

public class Node {
  
  final float x;
  final float y;
  final int delay;
  final float tolerance; //the radius of the node, squared.
  
  public Node(float x, float y, int delay, float tolerance) {
    this.x=x;
    this.y=y;
    this.delay=delay;
    this.tolerance = tolerance*tolerance;
  }
  
}
