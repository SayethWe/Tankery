import java.util.List;

public class PatrolAI extends Tank {
  private final float ANGLE_EPSILON = PI/100;
  private final float ANGLE_TURN = PI/4;
  private final float ANGLE_DRIVE = PI/8;
  
  private final float DIST_SLOW = 50*50;
  
  private final Route route;
  private Node target;
  private int delay=0;
  
  public PatrolAI(float x, float y, float facing, float turretFacing, int team, Route route) {
    super(x,y,facing,turretFacing,team);
    this.route=route;
    target = route.first();
  }
  
  public PatrolAI(float x, float y, float facing, float turretFacing, int team, Hull hull, Turret turret, Cannon cannon, Engine engine, Route route) {
    super(x,y,facing,turretFacing,hull,turret,cannon,engine,team);
    this.route=route;
    //target = route.first();
    target=route.near(x,y);
  }
  
  //debug render
  public void render() {
    super.render();
    noFill();
    stroke(0);
    ellipseMode(RADIUS);
    ellipse(target.x,target.y,sqrt(target.tolerance),sqrt(target.tolerance));
    rectMode(CORNERS);
    line(x,y,target.x,target.y);
  }
  
  public void update() {
    super.update();
    //this.moveTo(vehicle);
    //this.turnTo(vehicle);
    
    if(delay<=0) {
      float dist = findSquareDist(x,y,target.x,target.y)-target.tolerance;
      //println("distance: " + dist);
      if(dist<=0) {
        brake();
        delay=target.delay;
        logger.log(this+" reached target node at:"+x+","+y+", proceeding to next node");
        target=route.next();
        return;
      } else {
        float targetAngle=(atan2(target.y-y,target.x-x)+TWO_PI)%TWO_PI;
        //stroke(255,0,0);
        //line(x,y,x+20*cos(targetAngle),y+20*sin(targetAngle));
        
        //float angleDel = lessMassive((facing-targetAngle),(targetAngle-facing));
        float angleDel=angleBetween(facing,targetAngle);
        //println("Angle difference: "+angleDel+"="+facing+" - "+targetAngle);
        if (angleDel < -ANGLE_TURN) {
          turn(1);
        } else if (angleDel>ANGLE_TURN) {
          turn(-1);
        } else if(angleDel<-ANGLE_EPSILON) {
          turn(0.5);
        } else if (angleDel>ANGLE_EPSILON) {
          turn(-0.5);
        }
        if (abs(angleDel) < ANGLE_DRIVE) {
          drive(1);
        }
      }
    } else {
      brake();
      delay--;
    }
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
      node=0;
    }
    return path.get(node);
  }
  
  public Node first() {
    node = 0;
    return path.get(0);
  }
  
  public Node near(float x, float y) {
    float nearest=Float.MAX_VALUE;
    int nearestInd=0;
    for(int i = 0; i<nodes; i++){
      Node n = path.get(i);
      float dist=n.distTo(x,y);
      if(dist<nearest) {
        nearestInd=i;
        nearest=dist;
      }
    }
    node=nearestInd;
    return path.get(node);
  }
  
}

static Route testRoute() {
  List<Node> path = new ArrayList<Node>(7);
  path.add(instance.new Node(625,350,5,18));
  path.add(instance.new Node(450,600,5,10));
  path.add(instance.new Node(175,525,5,13));
  path.add(instance.new Node(325,375,20,5));
  path.add(instance.new Node(100,100,5,20));
  path.add(instance.new Node(450,150,5,20));
  return instance.new Route(path, true);
}

static Route testBack() {
  List<Node> path = new ArrayList<Node>(7);
  path.add(instance.new Node(625,350,5,18));
  path.add(instance.new Node(450,150,5,20));
  path.add(instance.new Node(100,100,5,20));
  path.add(instance.new Node(325,375,20,5));
  path.add(instance.new Node(175,525,5,13));
  path.add(instance.new Node(450,600,5,10));
  return instance.new Route(path, false);
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
  
  public float distTo(float x, float y) {
    return findSquareDist(x,y,this.x,this.y);
  }
  
}
