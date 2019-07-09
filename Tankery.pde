/*
* A Co-operative tanking game Demo
* Started 03 July 2019
* Last Update 07 July 2019
* By Sayeth_We
*/

import java.util.Set;
import java.util.HashSet;

static Tankery instance;

Player testPlayer;
Tank playerTank;

Player testCommander;
Player testDriver;
Player testGunner;

public static final Set<Entity>entities=new HashSet<Entity>();
public static final Set<Impactor>impactors=new HashSet<Impactor>();
public static final Set<Hittable>hittables=new HashSet<Hittable>();

Set<Entity>toRemove=new HashSet<Entity>();

Logger logger;

void setup() {
  instance = this;
  logger = new Logger("logs/Tankery_");
  registerMethod("dispose",this);
  
  size(750,750);
  //surface.setResizable(true);
  noSmooth();
  
  
  entities.add(playerTank = new Tank());
  entities.add(new Tank(200,300,PI/3,PI/2));
  entities.add(new Tank(500,400,PI/4,PI/6,Hull.TEST,Turret.PENT,Cannon.TEST,Engine.TEST));
  //testPlayer = new TestPlayer();
  entities.add(testCommander = new Commander(playerTank));
  entities.add(testGunner=new Gunner(playerTank));
  entities.add(testDriver=new Driver(playerTank));
  entities.add(testPlayer=testCommander);
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
      if(h.contains(i.getCollider())) {
        h.damage(i.impact(h.getThickness(i.getFacing())));
      }
    }
  }
}

//public void renderAll() {
//  for (Entity e:entities){
//    e.render();
//  }
//}

interface Hittable {
  public boolean contains(Shape collider);
  public void damage(int damage);
  public float getThickness(float incident);
}

interface Impactor {
  public int impact(float thickness);
  public float getFacing();
  public Shape getCollider();
}

public abstract class Entity {
  protected float x,y,facing;
  
  public Entity(float x,float y,float facing) {
    this.x=x;
    this.y=y;
    this.facing=facing;
    addToTrackers();
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
  
  protected void addToTrackers() {
    entities.add(this);
  }
  public abstract void render();
  public abstract void update();
}
