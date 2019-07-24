import java.awt.geom.Area;
import java.util.Random;

//the drivey bit that makes up the real meat of the game
class Tank extends Entity implements Hittable, Impactor {
  private final Hull hull;
  private final Turret turret;
  private final Cannon cannon;
  private final Engine engine;
  private final MachineGun machineGun;
  
  private final float mass;
  public final int maxHealth;
  private final float traverse;
  private final float acceleration;
  
  private int hash;
  
  protected float turretFacing;
  private float velocity;
  private int health;
  private int reloadCounter, machineReloadCounter;
  private boolean isDead=false;
  
  public Tank(int team) {
    this(width/2,height/2,0,0,Hull.TEST,Turret.TEST,Cannon.TEST,Engine.TEST,MachineGun.TEST,team);
  }
  

  public Tank(Prebuild build, int team) {
    this(width/2,height/2,0,0,build,team);
  }
  
  public Tank(float x, float y, float facing, float turretFacing, int team) {
    this(x,y,facing,turretFacing, Hull.TEST, Turret.TEST, Cannon.TEST, Engine.TEST,MachineGun.TEST,team);
  }

  public Tank(float x, float y, float facing, float turretFacing, Prebuild build, int team) {
    this(x,y,facing,turretFacing,build.hull,build.turret,build.cannon,build.engine,build.machineGun,team);
  }
  
  //public Tank(float x, float y, float facing, float turretFacing, Random random, int team) {
  //  this(x,y,facing,turretFacing,
  //  Hull.values()[random.nextInt(Hull.values().length)],
  //  Turret.values()[random.nextInt(Turret.values().length)],
  //  Cannon.values()[random.nextInt(Turret.values().length)],
  //  Engine.values()[random.nextInt(Turret.values().length)]
  //  ,team);
  //}
  
  public Tank(float x, float y, float facing, float turretFacing, Hull hull, Turret turret, Cannon cannon, Engine engine, MachineGun bowGun, int team) {
    super(x,y,facing,team);
    this.turretFacing=turretFacing;
    
    this.hull=hull;
    Set<Integer> compatibilityCheck=hull.compatibility;
    this.turret=turret;
    compatibilityCheck.retainAll(turret.compatibility);
    this.cannon=cannon;
    compatibilityCheck.retainAll(cannon.compatibility);
    this.engine=engine;
    compatibilityCheck.retainAll(engine.compatibility);
    this.machineGun=bowGun;
    compatibilityCheck.retainAll(machineGun.compatibility);
    if(compatibilityCheck.isEmpty()) throw new IllegalArgumentException("Incompatible Parts");
    
    this.mass = hull.mass+turret.mass+cannon.mass+engine.mass+bowGun.mass;
    this.maxHealth=hull.maxHealth+turret.maxHealth;
    this.health=this.maxHealth;
    this.acceleration=engine.power/(mass+hull.groundResistance);
    this.traverse=PI*engine.traversePower/(mass+hull.groundResistance);
  }
  
  protected void addToTrackers() {
    hittables.add(this);
    impactors.add(this);
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
  
  public float getTurretPivotX() {
    return x+hull.turretOffset*cos(facing);
  }
  
  public float getTurretPivotY() {
    return y+hull.turretOffset*sin(facing);
  }
  
  public void render() {
    pushMatrix();
    translate(x,y);
    rotate(facing);
    shape(hull.render);
    translate(hull.turretOffset,0);
    rotate(turretFacing);
    shape(turret.render);
    translate(turret.cannonOffset,0);
    shape(cannon.render);
    popMatrix();
  }
  
  public boolean contains(Area collider) {
    Area col = getCollider();
    col.intersect(collider);
    return !col.isEmpty();
  }
  public float getThicknessTowards(float angle) {
    float incidence=(facing-angle);
    return abs(hull.armor/sin(incidence));
  }
  public float getThickness() {
    return hull.armor;
  }
  
  public int getHealth() {
    return health;
  }
  
  public float getTurretDirection() {
   return turretFacing+facing;
  }
  
  public void fireMain() {
    if(reloadCounter<=0) {
      reloadCounter=cannon.fire(x,y,getTurretDirection(),team);
    }
  }
  
  public void fireMachine() {
    if(machineReloadCounter<=0) {
      machineReloadCounter=machineGun.fire(x,y,facing,team);
    }
  }
  
  public void drive(float dir) {
    velocity+=acceleration*dir;
    velocity=constrain(velocity,engine.maxReverseSpeed,engine.maxSpeed);
  }
  
  public void turn(float dir) {
    //println("traverse "+dir);
    turnBy(traverse*dir);
    //turnTurretBy(traverse*dir);
  }
  
  public void aimTurret(float dir) {
    turnTurretBy(turret.turnRate*dir);
  }
  
  public void brake() {
    int sign = sign(velocity);
    velocity-=engine.brakePower*sign/mass;
    if(velocity*sign<0) {
      velocity=0;
    }
  }
  
  public void update() {
    reloadStep(false);
    doMovement();
  }
  
  private void doMovement() {
    float newX = x+velocity*cos(facing);
    float newY = y+velocity*sin(facing);
    moveTo(newX,newY);
  }
  
  public boolean isDead() {
    return isDead;
  }
  
  public void reloadStep(boolean wasLoader) {
    if(wasLoader) {
      reloadCounter=0;
    } else {
      reloadCounter--;
      machineReloadCounter--;
    }
  }
    
  public Area getCollider() {
    AffineTransform at = new AffineTransform();
    at.translate(x,y);
    at.rotate(facing);
    Area collider = new Area(at.createTransformedShape(hull.collision));
    at.translate(hull.turretOffset,0);
    at.rotate(turretFacing);
    collider.add(new Area(at.createTransformedShape(turret.collision)));
    return collider;
  }
    
  public int impact(Hittable h) {
    //println("tank collision");
    float thickness=h.getThicknessTowards(facing);
    //println(thickness);
    int damage = int((hull.armor*2/thickness)*abs(velocity));
    //println(damage);
    //TODO: bounce back
    velocity=0;
    h.damage(damage);
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
      hashCalc.append(traverse);
      hash=hashCalc.getResult();
    }
    return hash;
  }
}
