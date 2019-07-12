/*
* A Co-operative tanking game Demo
* Started 03 July 2019
* Last Update 09 July 2019
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
  
  //Tank aiTank;
  playerTank = new Tank(1);
  new Tank(200,300,PI/3,PI/2,0);
  new PatrolAI(500,400,PI/4,PI/6,0,Hull.LIGHT,Turret.SMALL,Cannon.SHORT,Engine.TEST,testRoute());
  new PatrolAI(650,75,PI,3*PI/5,0,testRoute());
  new PatrolAI(100,600,PI/2,PI/2,0,Hull.TEST,Turret.PENT,Cannon.TEST,Engine.WEAK,testBack());
  testPlayer = new TestPlayer();
  testCommander = new Commander(playerTank);
  testGunner=new Gunner(playerTank);
  testDriver=new Driver(playerTank);
  //entities.add(testPlayer=testCommander);
  logger.log("Startup sucessful");
}

void draw() {
  background(255);
  
  handleKeys();
  updateAll();
  handleCollisions();
  //renderAll();
  handleFog(); //Must be penultimate call
  drawUI(); //must be last call
}

void dispose() {
  logger.dispose();
  println("Shutting down");
  exit();
}

public void updateAll() {
  for (Entity e:entities){
    e.update();
    e.render();
  }
  impactors.removeAll(toRemove);
  entities.removeAll(toRemove);
  hittables.removeAll(toRemove);
  toRemove.clear();
}

public void handleCollisions() {
  for(Impactor i :impactors) {
    for(Hittable h: hittables) {
      if(h.contains(i.getCollider())&&i.getTeam()!=h.getTeam()) {
        h.damage(i.impact(h.getThickness(i.getFacing())));
      }
    }
  }
}

interface Hittable {
  public boolean contains(Shape collider);
  public void damage(int damage);
  public float getThickness(float incident);
  public byte getTeam();
}

interface Impactor {
  public int impact(float thickness);
  public float getFacing();
  public Shape getCollider();
  public byte getTeam();
}

public abstract class Entity {
  protected float x,y,facing;
  protected final byte team;
  protected final long init;
  
  protected int hash; //coching teh Hashcode after it's called;
  
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
