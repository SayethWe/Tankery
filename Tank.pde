import java.awt.geom.Area;
import java.util.Random;

class Tank extends Entity implements Hittable, Impactor{
  private final Hull hull;
  private final Turret turret;
  private final Cannon cannon;
  private final Engine engine;
  private final float mass;
  public final int maxHealth;
  private final float speed;
  private final float traverse;
  
  private int hash;
  
  protected float turretFacing;
  private int health;
  private int reloadCounter;
  private boolean isDead=false;
  
  //public Tank() {
  //  this(width/2,height/2,0,0,Hull.TEST,Turret.TEST,Cannon.TEST,Engine.TEST,0);
  //}
  
  public Tank(int team) {
    this(width/2,height/2,0,0,Hull.TEST,Turret.TEST,Cannon.TEST,Engine.TEST,team);
  }
  
  //public Tank(float x, float y, float facing, float turretFacing) {
  //  this(x,y,facing,turretFacing, Hull.TEST, Turret.TEST, Cannon.TEST, Engine.TEST,0);
  //}
  
  public Tank(float x, float y, float facing, float turretFacing, int team) {
    this(x,y,facing,turretFacing, Hull.TEST, Turret.TEST, Cannon.TEST, Engine.TEST,team);
  }
  
  //public Tank(float x, float y, float facing, float turretFacing, Random random) {
  //  this(x,y,facing,turretFacing,
  //  Hull.values()[random.nextInt(Hull.values().length)],
  //  Turret.values()[random.nextInt(Turret.values().length)],
  //  Cannon.values()[random.nextInt(Turret.values().length)],
  //  Engine.values()[random.nextInt(Turret.values().length)]
  //  ,0);
  //}
  
  public Tank(float x, float y, float facing, float turretFacing, Hull hull, Turret turret, Cannon cannon, Engine engine, int team) {
    super(x,y,facing,team);
    this.hull=hull;
    this.turret=turret;
    this.turretFacing=turretFacing;
    this.cannon=cannon;
    this.engine=engine;
    this.mass = hull.mass+turret.mass+cannon.mass+engine.mass;
    this.maxHealth=hull.maxHealth+turret.maxHealth;
    this.health=this.maxHealth;
    this.speed=engine.power/(mass+hull.groundResistance);
    this.traverse=PI*engine.traversePower/(mass+hull.groundResistance);
  }
  
  protected void addToTrackers() {
    hittables.add(this);
    super.addToTrackers();
  }
  
  public void turnTurretBy(float delTheta) {
    turretFacing+=delTheta;
  }
  public void turnTurretTo(float theta) {
    turretFacing=theta;
  }
  
  public void markToRemove() {
    super.markToRemove();
    isDead=true;
  }
  
  public void damage(int damage) {
    health-=damage;
    health=constrain(health,0,maxHealth);
    if(health==0) this.markToRemove();
    logger.log(this+" hit for: " + damage+ ", now at: "+health); 
  }
  
  public void render() {
    //render(hull,facing);
    //render(turret,turretFacing);
    //render(cannon,turretFacing);
    pushMatrix();
    translate(x,y);
    rotate(facing);
    shape(hull.render);
    translate(hull.turretOffset,0);
    rotate(turretFacing-facing);
    shape(turret.render);
    translate(turret.cannonOffset,0);
    shape(cannon.render);
    popMatrix();
  }
  
  public boolean contains(Area collider) {
    //TODO: Use java.awt.shape for collision detection
    //return(dist(this.x,this.y,x,y)<20);
    Area col = getCollider();
    col.intersect(collider);
    return !col.isEmpty();
  }
  public float getThickness(float angle) {
    float incidence=(facing-angle)%TWO_PI;
    return hull.armor/sin(incidence);
  }
  
  public int getHealth() {
    return health;
  }
  
  public float getTurretFacing() {
   return turretFacing;
  }
  
  public void fire() {
    if(reloadCounter==0) {
      cannon.fire(x,y,turretFacing,team);
      reloadCounter=cannon.reload;
    }
  }
  
  public void drive(float dir) {
    float newX = x+dir*speed*cos(facing);
    float newY = y+dir*speed*sin(facing);
    moveTo(newX,newY);
  }
  
  public void turn(float dir) {
    //println("traverse "+dir);
    turnBy(traverse*dir);
    turnTurretBy(traverse*dir);
  }
  
  public void aimTurret(float dir) {
    turnTurretBy(turret.turnRate*dir);
  }
  
  public void update() {
    reloadStep(false);
  }
  
  public boolean isDead() {
    return isDead;
  }
  
  public void reloadStep(boolean wasLoader) {
      if(wasLoader) {
        reloadCounter=0;
      } else if (reloadCounter>0) {
        reloadCounter--;
      }
    }
    
    public Area getCollider() {
      AffineTransform at = new AffineTransform();
      at.translate(x,y);
      at.rotate(facing);
      Area collider = new Area(at.createTransformedShape(hull.collision));
      at.translate(hull.turretOffset,0);
      at.rotate(turretFacing-facing);
      collider.add(new Area(at.createTransformedShape(turret.collision)));
      return collider;
    }
    
  public int impact(Hittable h) {
    println("tank collision");
    float thickness=h.getThickness(facing);
    int damage = int(getThickness(facing)/thickness*speed);
    //todo: bounce back
    h.damage(damage);
    this.damage(damage);
    return damage;
  }
    
  public int hashCode() {
    if(hash==0) {
      Hasher hashCalc = new Hasher(11,super.hashCode());
      hashCalc.append(hull);
      hashCalc.append(turret);
      hashCalc.append(cannon);
      hashCalc.append(engine);
      hashCalc.append(mass);
      hashCalc.append(maxHealth);
      hashCalc.append(speed);
      hashCalc.append(traverse);
      hash=hashCalc.getResult();
    }
    return hash;
  }
}
