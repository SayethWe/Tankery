import java.util.List;
import java.util.LinkedList;


public abstract class AbstractAI extends Tank {
  
  //when to discard sightings. unused
  private static final long AGE_DISCARD = 10000;
  private static final int SIGHTINGS_STORAGE = 5;
  
  protected final float viewDist, spotPercent;
  protected final Map<Tank,List<Sighting>> memory;
  protected Tank target;
  
  public AbstractAI(float x, float y, float facing, float turretFacing, float viewDist, float spotPercent, int team) {
    super(x,y,facing,turretFacing,team);
    this.viewDist=viewDist*viewDist;
    this.spotPercent=spotPercent;
    memory=new HashMap<Tank,List<Sighting>>();
  }
  
  public AbstractAI(float x, float y, float facing, float turretFacing, float viewDist, float spotPercent, Prebuild build, int team) {
    super(x,y,facing,turretFacing,build,team);
    this.viewDist=viewDist*viewDist;
    this.spotPercent=spotPercent;
    memory=new HashMap<Tank,List<Sighting>>();
  }
  
  public AbstractAI(float x, float y, float facing, float turretFacing, float viewDist, float spotPercent, int team, Hull hull, Turret turret, Cannon cannon, Engine engine, MachineGun mg) {
    super(x,y,facing,turretFacing,hull,turret,cannon,engine,mg,team);
    this.viewDist=viewDist*viewDist;
    this.spotPercent=spotPercent;
    memory=new HashMap<Tank,List<Sighting>>();
  }
  
  public void addToTrackers() {
    super.addToTrackers();
    robots.add(this);
  }
  
  public boolean spot(float x, float y) {
    return (random(100)<=spotPercent&&findSquareDist(this.x,this.y,x,y)<viewDist);
  }
  
  public void spotted(Tank t) {
    println(this+" Spotted "+t);
    memory.putIfAbsent(t,new LinkedList<Sighting>());
    List sightings = memory.get(t);
    sightings.add(new Sighting(t));
    while(sightings.size() >= SIGHTINGS_STORAGE) sightings.remove(0);
  }
  
  public void update() {
    super.update();
    target = bestTarget();
    doMovement();
  }
  
  private Tank bestTarget() {
    Tank bestTank=null;
    int bestScore=0;
    for(Tank t:memory.keySet()) {
      int score = targetValue(t);
      if(score > bestScore) {
        bestScore=score;
        bestTank=t;
      }
    }
    return bestTank;
  }
  
  //negative values mean a bad target, one to not go after. positive values mean that it's valid, and desirable. the higher the value, the more desirable.
  protected abstract int targetValue(Tank t);
  protected abstract void doMovement();
  
}

//an AI that moves along a specific path
public class PatrolAI extends AbstractAI {


  private final float ANGLE_EPSILON = PI/100;
  private final float ANGLE_TURN = PI/4;
  private final float ANGLE_DRIVE = PI/8;
  
  private final float DIST_SLOW = 70*70;
  private final float DIST_BRAKE = 20*20;
  
  protected final Route route;
  
  protected Node targetNode;
  protected int delay=0;
  
  public PatrolAI(float x, float y, float facing, float turretFacing, float viewDist, float spotPercent, int team, Route route) {
    super(x,y,facing,turretFacing,viewDist,spotPercent,team);
    this.route=route;
    targetNode = route.first();
  }
  
  public PatrolAI(float x, float y, float facing, float turretFacing, float viewDist, float spotPercent, Prebuild build, int team, Route route) {
    super(x,y,facing,turretFacing,viewDist,spotPercent,build,team);
    this.route=route;
    targetNode = route.first();
  }
  
  public PatrolAI(float x, float y, float facing, float turretFacing, float viewDist, float spotPercent, int team, Hull hull, Turret turret, Cannon cannon, Engine engine, MachineGun mg, Route route) {
    super(x,y,facing,turretFacing,viewDist,spotPercent,team,hull,turret,cannon,engine,mg);
    this.route=route;
    //target = route.first();
    targetNode=route.near(x,y);
  }
  
  //debug render
  public void render() {
    super.render();
    noFill();
    stroke(0);
    ellipseMode(RADIUS);
    ellipse(targetNode.x,targetNode.y,sqrt(targetNode.tolerance),sqrt(targetNode.tolerance));
    rectMode(CORNERS);
    line(x,y,targetNode.x,targetNode.y);
  }
  
  protected void doMovement() {
    if(delay<=0) {
      float dist = findSquareDist(x,y,targetNode.x,targetNode.y)-targetNode.tolerance;
      //println("distance: " + dist);
      if(dist<=0) {
        delay=targetNode.delay;
        brake();
        logger.log(this+" reached target node at:"+x+","+y+", proceeding to next node");
        targetNode=route.next();
        return;
      } else {
        float targetAngle=atan2(targetNode.y-y,targetNode.x-x);
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
          if(dist>DIST_SLOW) {
            drive(1);
          } else if (dist>DIST_BRAKE) {
            drive(0.5);
          } else {
            brake();
          }
        }
      }
    } else {
      brake();
      delay--;
    }
    
    if(target!=null) {
      Sighting mostRecent = memory.get(target).get(memory.get(target).size()-1);
      float angleDel=angleBetween(getTurretDirection(),atan2(mostRecent.y-y,mostRecent.x-x));
      if (angleDel < -ANGLE_TURN) {
        aimTurret(1);
      } else if (angleDel>ANGLE_TURN) {
        aimTurret(-1);
      } else if(angleDel<-ANGLE_EPSILON) {
        aimTurret(0.5);
      } else if (angleDel>ANGLE_EPSILON) {
        aimTurret(-0.5);
      } else {
        fireMain();
      }
    }
  }
  
  protected int targetValue(Tank t) {
    if(t.getTeam() == team) { 
      return -1;
    } else {
      return 1; //TODO
    }
  }
  
}

public class PIDAI extends PatrolAI {
  private final float kpt, kit, kdt; //theta gains
  private final float kps, kis, kds; //position gains
  
  private float lastThetaErr, sumThetaErr;
  private float lastPosErr, sumPosErr;
  
  public PIDAI(float x, float y, float facing, float turretFacing, float viewDist, float spotPercent, int team, Route route, float[] gains) {
    super(x,y,facing,turretFacing,viewDist,spotPercent,team,route);
    if(gains.length!=6) throw new IllegalArgumentException("Improper gains");
    this.kps=gains[0];
    this.kis=gains[1];
    this.kds=gains[2];
    this.kpt=gains[3];
    this.kit=gains[4];
    this.kdt=gains[5];
  }
  
  public PIDAI(float x, float y, float facing, float turretFacing, float viewDist, float spotPercent, Prebuild build, int team, Route route, float[] gains) {
    super(x,y,facing,turretFacing,viewDist,spotPercent,build,team,route);
    if(gains.length!=6) throw new IllegalArgumentException("Improper gains");
    this.kps=gains[0];
    this.kis=gains[1];
    this.kds=gains[2];
    this.kpt=gains[3];
    this.kit=gains[4];
    this.kdt=gains[5];
  }
  
  public PIDAI(float x, float y, float facing, float turretFacing, float viewDist, float spotPercent, int team, Hull hull, Turret turret, Cannon cannon, Engine engine, MachineGun mg, Route route, float[] gains) {
    super(x,y,facing,turretFacing,viewDist,spotPercent,team,hull,turret,cannon,engine,mg,route);
    if(gains.length!=6) throw new IllegalArgumentException("Improper gains");
    this.kps=gains[0];
    this.kis=gains[1];
    this.kds=gains[2];
    this.kpt=gains[3];
    this.kit=gains[4];
    this.kdt=gains[5];
  }
  
  protected void doMovement() {
    if(delay<0) {
      float targetAngle=atan2(targetNode.y-y,targetNode.x-x);
      float thetaErr=angleBetween(facing,targetAngle);
      float delThetaErr = lastThetaErr-thetaErr;
      sumThetaErr += thetaErr;
      float thetaAction = constrain(kpt*thetaErr+kit*sumThetaErr+kdt*delThetaErr,-1,1);
      
      
      float posErr = findSquareDist(x,y,targetNode.x,targetNode.y)-targetNode.tolerance;
      float delPosErr = lastPosErr-posErr;
      sumPosErr += posErr;
      float posAction=constrain(kps*posErr+kis*sumPosErr+kds*delPosErr,-0.5,1);
      
      println(this+"Action: turn By:"+thetaAction+", Drive by:"+posAction);
      turn(thetaAction);
      drive(posAction);
      
      if(posErr<targetNode.tolerance) {
        delay=targetNode.delay;
        targetNode=route.next();
      }
    } else {
      delay--;
    }
      
      
  }
  
  public String toString() {
    return "PID-Tuned AI "+kpt+","+kit+","+kdt+"|"+kps+","+kis+","+kds;
  }
}

//A route for a patrol tank to follow
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

//a single point along a route
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

public class Sighting {
  
  public final float x,y,facing,turretFacing;
  public final byte team;
  private final long initTime;
  
  public Sighting(Tank t) {
    this.initTime=millis();
    this.x=t.getX();
    this.y=t.getY();
    this.facing=t.getFacing();
    this.turretFacing=t.getTurretDirection();
    this.team=t.getTeam();
  }
  
  public long getAge() {
    return millis()-initTime;
  }
  
}
