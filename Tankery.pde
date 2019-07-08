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

public static final Set<Entity>entities=new HashSet<Entity>();
public static final Set<Projectile>projectiles=new HashSet<Projectile>();

Set<Entity>toRemove=new HashSet<Entity>();
Set<Projectile>deadProjectiles=new HashSet<Projectile>();

Logger logger;

void setup() {
  instance = this;
  logger = new Logger("logs/Tankery_");
  //registerDispose(e->{};);
  registerMethod("dispose",this);
  
  size(750,750);
  surface.setResizable(true);
  noSmooth();
  
  
  entities.add(playerTank = new Tank());
  entities.add(new Tank(200,300,PI/3,PI/2));
  entities.add(new Tank(500,400,PI/4,PI/6,Hull.TEST,Turret.PENT,Cannon.TEST,Engine.TEST));
  testPlayer = new TestPlayer();
  //testPlayer = new Commander());
  //testPlayer=new Gunner();
  //testPlayer=new Driver();
  entities.add(testPlayer);
  logger.log("Startup sucessful");
}

void draw() {
  background(255);
  
  handleMovement();
  updateAll();
  handleCollisions();
  renderAll();
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
  }
  projectiles.removeAll(deadProjectiles);
  deadProjectiles.clear();
  println(deadProjectiles);
  entities.removeAll(toRemove);
  toRemove.clear();
}

public void handleCollisions() {
  for(Projectile p : projectiles) {
    for(Entity e:entities) {
      if(e.contains(p.getX(),p.getY())&&!p.equals(e)) {
        e.damage(p.impact(e.getFacing(),e.getThickness()));
      }
    }
  }
}

public void renderAll() {
  for (Entity e:entities){
    e.render();
  }
}

public abstract class Entity {
  protected float x,y,facing;
  
  public Entity(float x,float y,float facing) {
    this.x=x;
    this.y=y;
    this.facing=facing;
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
  
  abstract void render();
  abstract void update();
  abstract float getThickness();
  abstract void damage(int damage);
  abstract boolean contains(float x, float y);
}
