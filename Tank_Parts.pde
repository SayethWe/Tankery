import java.awt.Shape;
import java.awt.Polygon;
import java.awt.geom.AffineTransform;

interface Collideable {
  public Shape getCollider();
}

interface Renderable {
  public PShape getRender();
}

//a utility class to generate renders and colliders
static class PartBuilder {
  public static Shape createCollision(float[] xPoints, float[] yPoints, int points) {
    if(!(xPoints.length==points&&yPoints.length==points)) throw new IllegalArgumentException();
    return new Polygon(int(xPoints),int(yPoints),points);
  }
  public static  PShape createRender(float[] xPoints, float[] yPoints, int points, color fill, color stroke) {
    if(!(xPoints.length==points&&yPoints.length==points)) throw new IllegalArgumentException();
    PShape render = instance.createShape();
    render.beginShape();
    for(int i = 0; i<points; i++) {
      render.vertex(xPoints[i],yPoints[i]);
    }
    render.endShape(CLOSE);
    
    render.setFill(fill);
    render.setStroke(stroke);
    return render;
  }
  
  public static Set<Integer> compatibilitySet(int... compatibilities) {
    Set<Integer> result = new HashSet<Integer>();
    for(int compatibility : compatibilities) {
      result.add(compatibility);
    }
    return result;
  }
}

//the main body. responsible for armor, part of the health, and movement resistance.
enum Hull implements Collideable, Renderable{
  
  TEST(PartBuilder.compatibilitySet(1), 70,70,2.5,0,20.0,new float[]{-25, 25,30,25,-25},new float[]{-15,-15, 0,15, 15},5,#80EE54,#80EE54),
  LIGHT(PartBuilder.compatibilitySet(2), 30,25,1.0,-5,10.0,new float[]{25,15,-15,-20,-15,15},new float[]{0,10,10,0,-10,-10},6,#F50F0F,#F5AC0F);
  
  public final float mass;
  public final int maxHealth;
  public final float armor;
  public final float groundResistance;
  public final float turretOffset;
  public final Set<Integer> compatibility;
  
  //TODO: collision polygon
  private final Shape collision;
  protected final PShape render;
  
  private Hull(Set<Integer> compatibility, int maxHealth, float armor, float groundResistance, float turretPivot, float mass, float[] xPoints, float[] yPoints, int points, color fill, color stroke) {
    this.compatibility=compatibility;
    this.maxHealth=maxHealth;
    this.mass=mass;
    this.armor=armor;
    this.groundResistance=groundResistance;
    this.turretOffset=turretPivot;
    this.collision = PartBuilder.createCollision(xPoints,yPoints,points);
    this.render = PartBuilder.createRender(xPoints,yPoints,points,fill,stroke);
  }
  
  public Shape getCollider() {
    return collision;
  }
  public PShape getRender() {
    return render;
  }
}
 
//the bit which the cannon fits in. Responsible for aiming and part of the tank's health
enum Turret implements Collideable, Renderable{
  
  TEST(PartBuilder.compatibilitySet(1), PI/20,30,10,5.0,new float[]{20,-10,-10},new float[]{0,17.3,-17.3},3,#6E52FF,#6E52FF),
  PENT(PartBuilder.compatibilitySet(1), PI/25,45,15,6.0,new float[]{20.00, 6.18, -16.18, -16.18, 6.18}, new float[]{0.00, 19.02, 11.76, -11.76, -19.02}, 5, #87F4F5, #225D67),
  SMALL(PartBuilder.compatibilitySet(2), PI/10,20,6.5,2.0,new float[]{12.00, -0.00, -12.00, 0.00}, new float[]{0.00, 12.00, -0.00, -12.00}, 4, #557C4C, #2DD38C);
  
  public final float mass;
  public final float turnRate;
  public final int maxHealth;
  public final float cannonOffset;
  public final Set<Integer> compatibility;
  
  private final Shape collision;
  private final PShape render;
  
  private Turret(Set<Integer> compatibility, float turnRate, int maxHealth, float cannonMount, float mass, float[] xPoints, float[] yPoints, int points, color fill, color stroke) {
    this.turnRate=turnRate;
    this.mass=mass;
    this.maxHealth=maxHealth;
    this.cannonOffset=cannonMount;
    this.compatibility=compatibility;
    this.render=PartBuilder.createRender(xPoints,yPoints,points,fill,stroke);
    this.collision=PartBuilder.createCollision(xPoints,yPoints,points);
  }
  
  public Shape getCollider() {
    return collision;
  }
  public PShape getRender() {
    return render;
  }
}

//The shooty-bit. Responsible for most of the offensive capabilities.
enum Cannon implements Renderable {
    TEST(PartBuilder.compatibilitySet(1,2), 50,75,10,6,PI/25,PI/20,3.5,3,2.5,new float[]{0,30,30,0},new float[]{-2,-2,2,2},4,#CD3F66,#000000),
    SHORT(PartBuilder.compatibilitySet(1,2),100,30,30,3,PI/20,PI/10,4.3,20,1.5,new float[]{0,15,17,17,15,0},new float[]{-2.5,-2.5,-4,4,2.5,2.5}, 6, #5F4C22, #2E2309),
    LONG(PartBuilder.compatibilitySet(1), 30,1000,300,15,PI/100,PI/50,3.2,0,2.3,new float[]{0,45,40,50,50,40,45,0},new float[]{-1,-1,-2,-1,1,2,1,1},8, #711919, #A7630F);
  
    private final int damage;
    private final float penetration;
    private final int reload;
    public final float shellVelocity;
    public final float mass;
    public final float dispersion;
    public final float maxDispersion;
    private final float caliber;
    private final float explosiveLoad;
    private final PShape render;
    
    public final Set<Integer> compatibility;
    
    private Cannon(Set<Integer> compatibility, int damage, int penetration, int reload, float shellVelocity, float dispersion, float maxDispersion, float caliber, float explosiveLoad, float mass, float[] xPoints, float[] yPoints, int points, color fill, color stroke) {
      this.damage=damage;
      this.penetration=penetration;
      this.reload=reload;
      this.shellVelocity=shellVelocity;
      this.mass=mass;
      this.dispersion=dispersion;
      this.maxDispersion=maxDispersion;
      this.caliber=caliber;
      this.explosiveLoad=explosiveLoad;
      this.compatibility=compatibility;
      this.render=PartBuilder.createRender(xPoints,yPoints,points,fill,stroke);
    }
    
    public PShape getRender() {
      return render;
    }
    
    public int fire(float x, float y, float facing, int team) {
        float direction=clampedGaussian(facing,dispersion,facing-maxDispersion,facing+maxDispersion);
        createProjectile(x,y,direction,penetration,shellVelocity,damage,caliber,explosiveLoad,team);
        return reload;
    }
}

//The thing what drives the movement
enum Engine {
  TEST(PartBuilder.compatibilitySet(1,2), 1.5,1.25,2,-1,1.0,5.0),
  FAST(PartBuilder.compatibilitySet(2), 1,1.5,4,-1.5,1.0,4.5),
  WEAK(PartBuilder.compatibilitySet(1), .75,1,2.5,-1,0.7,3.0);
  
  public final float power, brakePower;
  public final float maxSpeed, maxReverseSpeed; //The speed governer
  public final float traversePower;
  public final float mass;
  
  public final Set<Integer> compatibility;
  
  private Engine(Set<Integer> compatibility, float power, float brakePower, float maxSpeed, float maxReverse, float traversePower, float mass) {
    this.power=power;
    this.brakePower=brakePower;
    this.maxSpeed=maxSpeed;
    this.maxReverseSpeed = maxReverse;
    this.traversePower=traversePower;
    this.compatibility = compatibility;
    this.mass=mass;
  }
}

enum Prebuild {
  TEST(Hull.TEST,Turret.TEST,Cannon.TEST,Engine.TEST,MachineGun.TEST),
  FAST(Hull.LIGHT,Turret.SMALL,Cannon.SHORT,Engine.FAST,MachineGun.NONE);
  
  public final Hull hull;
  public final Turret turret;
  public final Cannon cannon;
  public final Engine engine;
  public final MachineGun machineGun;
  
  private Prebuild(Hull h, Turret t, Cannon c, Engine e, MachineGun mg) {
    this.hull=h;
    this.turret=t;
    this.cannon=c;
    this.engine=e;
    this.machineGun = mg;
  }
}

enum MachineGun {
  TEST(PartBuilder.compatibilitySet(1), 10,5,3,3,PI/10,PI/6,1,0.25),
  NONE(PartBuilder.compatibilitySet(1,2),0,0,0,0,0,0,0,0);
  
  public final float dispersion, maxDispersion;
  public final float caliber, shellVelocity;
  public final float mass;
  public final int reload;
  public final int damage, penetration;
  
  public final Set<Integer> compatibility;
  
  private MachineGun(Set<Integer> compatibility, int damage, int penetration, int reload, float shellVelocity, float dispersion, float maxDispersion, float caliber, float mass) {
    this.damage=damage;
    this.penetration=penetration;
    this.reload=reload;
    this.shellVelocity=shellVelocity;
    this.dispersion=dispersion;
    this.maxDispersion=maxDispersion;
    this.caliber=caliber;
    this.compatibility=compatibility;
    this.mass=mass;
  }
  
  public int fire(float x, float y, float facing, int team) {
    float direction=clampedGaussian(facing,dispersion,facing-maxDispersion,facing+maxDispersion);
    createProjectile(x,y,direction,penetration,shellVelocity,damage,caliber,0,team);
    return reload;
  }
  
}
