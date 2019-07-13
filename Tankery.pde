/*
* A Co-operative tanking game Demo
* Started 03 July 2019
* Last Update 12 July 2019
* By Sayeth_We
*/

import java.util.Set;
import java.util.HashSet;

static Tankery instance;

//the active player and vehicle, in most cases.
Player testPlayer;
Tank playerTank;

//testing roles that can be swapped between
Player testCommander;
Player testDriver;
Player testGunner;

//trackers, for drawing and collision purposes
public static final Set<Entity>entities=new HashSet<Entity>();
public static final Set<Impactor>impactors=new HashSet<Impactor>();
public static final Set<Hittable>hittables=new HashSet<Hittable>();
public static final Set<AbstractAI>robots=new HashSet<AbstractAI>();

//Things that should be removed from the trackers
Set<Entity>toRemove=new HashSet<Entity>();

Logger logger;

void setup() {
  instance = this;
  logger = new Logger("logs/Tankery_");
  registerMethod("dispose",this);
  
  size(750,750);
  //surface.setResizable(true);
  noSmooth();
  
  //Create some tanks to play with
  playerTank = new Tank(1);
  new Tank(200,300,PI/3,PI/2,0);
  new PatrolAI(500,400,PI/4,PI/6,100,75,Prebuild.FAST,0,testRoute());
  new PatrolAI(650,75,PI,3*PI/5,50,52.5,0,testRoute());
  new PatrolAI(100,600,PI/2,PI/2,70,34,0,Hull.TEST,Turret.PENT,Cannon.TEST,Engine.WEAK,testBack());

  
  //initialize the test roles

  testPlayer = new TestPlayer();
  testCommander = new Commander(playerTank);
  testGunner=new Gunner(playerTank);
  testDriver=new Driver(playerTank);
  
  logger.log("Startup sucessful");
}

void draw() {
  background(255);
  
  handleKeys();
  updateAll();
  handleCollisions();
  handleFog(); //Must be penultimate call
  drawUI(); //must be last call
}

//called when the program closes
void dispose() {
  logger.dispose();
  println("Shutting down");
  exit();
}

//go through everything we track, and update then draw them
public void updateAll() {
  createProjectiles();
  for (Entity e:entities){
    e.update();
    e.render();
  }
  for (AbstractAI robot:robots) {
    if(robot.spot(playerTank.getX(),playerTank.getY())) robot.spotted(playerTank);
  }
  impactors.removeAll(toRemove);
  entities.removeAll(toRemove);
  hittables.removeAll(toRemove);
  robots.removeAll(toRemove);
  toRemove.clear();
}

//check if things are occupying the same space.
public void handleCollisions() {
  for(Impactor i :impactors) {
    for(Hittable h: hittables) {
      if(i.getTeam()!=h.getTeam()&&h.contains(i.getCollider())) {
        i.impact(h);
      }
    }
  }
}

//something that can be hit
interface Hittable {
  public boolean contains(Area collider);
  public void damage(int damage);
  public float getThickness(float incident);
  public byte getTeam();
}

//something that can hit anotehr thing
interface Impactor {
  public int impact(Hittable h); //returns how much damage it did
  public float getFacing();
  public Area getCollider();
  public byte getTeam();
}

//the tracking class. things that can be moved, turned and drawn.
public abstract class Entity {
  protected float x,y,facing;
  protected final byte team;
  protected final long init;
  
  protected int hash; //caching the Hashcode after it's called;
  
  public Entity(float x,float y,float facing, int team) {
    if(team>Byte.MAX_VALUE) throw new IllegalArgumentException();
    this.x=x;
    this.y=y;
    this.facing=facing;
    this.team=(byte)team;
    this.init=millis();
    addToTrackers();
  }
  
  public Entity(Entity beginAt, int team) {
    this(beginAt.x,beginAt.y,beginAt.facing, team);
  }
  
  public void markToRemove() {
    toRemove.add(this);
  }
  
  public float getX() {
    return x;
  }
  public float getY() {
    return y;
  }
  public float getFacing() {
    return facing;
  }
  public void moveTo(float x, float y){
    this.x=x;
    this.y=y;
  }
  public void turnBy(float delTheta) {
    facing+= delTheta;
    facing=(facing+TWO_PI)%TWO_PI;
  }
  public void turnTo(float theta){
    facing=(theta+TWO_PI)%TWO_PI;
  }
  
  public byte getTeam() {
    return team;
  }
  
  protected void addToTrackers() {
    entities.add(this);
  }
  public abstract void render();
  public abstract void update();
  
  public int hashCode() {
    if(hash==0) {
      Hasher hashCalc = new Hasher(17);
      hashCalc.append(team);
      hashCalc.append(init);
      hash=hashCalc.getResult();
    }
    return hash;
  }
}
