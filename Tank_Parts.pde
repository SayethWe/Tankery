import java.awt.Shape;
import java.awt.Polygon;
import java.awt.geom.AffineTransform;

interface Collideable {
  public Shape getCollider();
}

interface Renderable {
  public PShape getRender();
}

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
}

enum Hull implements Collideable, Renderable{
  
  TEST(70,20.0,70,2.5,0,new float[]{-25, 25,30,25,-25},new float[]{-15,-15, 0,15, 15},5,#80EE54,#80EE54),
  LIGHT(30,10.0,25,1.0,-5,new float[]{25,15,-15,-20,-15,15},new float[]{0,10,10,0,-10,-10},6,#F50F0F,#F5AC0F);
  
  public final float mass;
  public final int maxHealth;
  public final float armor;
  public final float groundResistance;
  public final float turretOffset;
  
  //TODO: collision polygon
  private final Shape collision;
  protected final PShape render;
  
  private Hull(int maxHealth, float mass, float armor, float groundResistance, float turretPivot, float[] xPoints, float[] yPoints, int points, color fill, color stroke) {
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
 
enum Turret implements Collideable, Renderable{
  
  TEST(PI/20,5.0,30,10,new float[]{20,-10,-10},new float[]{0,17.3,-17.3},3,#6E52FF,#6E52FF),
  PENT(PI/25,6.0,45,15,new float[]{20.00, 6.18, -16.18, -16.18, 6.18}, new float[]{0.00, 19.02, 11.76, -11.76, -19.02}, 5, #87F4F5, #225D67),
  SMALL(PI/10,2.0,20,6.5,new float[]{12.00, -0.00, -12.00, 0.00}, new float[]{0.00, 12.00, -0.00, -12.00}, 4, #557C4C, #2DD38C);
  
  public final float mass;
  public final float turnRate;
  public final int maxHealth;
  public final float cannonOffset;
  
  private final Shape collision;
  protected final PShape render;
  
  private Turret(float turnRate, float mass, int maxHealth, float cannonMount, float[] xPoints, float[] yPoints, int points, color fill, color stroke) {
    this.turnRate=turnRate;
    this.mass=mass;
    this.maxHealth=maxHealth;
    this.cannonOffset=cannonMount;
    
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

enum Cannon implements Renderable {
    TEST(50,75,10,6,2.5,PI/100,PI/20,3.5,new float[]{0,30,30,0},new float[]{-2,-2,2,2},4,#CD3F66,#000000),
    SHORT(100,100,30,3,1.5,PI/20,PI/10,4.3,new float[]{0,15,17,17,15,0},new float[]{-2.5,-2.5,-4,4,2.5,2.5}, 6, #5F4C22, #2E2309);
  
    private final int damage;
    private final float penetration;
    private final int reload;
    public final float shellVelocity;
    public final float mass;
    public final float dispersion;
    public final float maxDispersion;
    private final float caliber;
    private final PShape render;
    
    private Cannon(int damage, int penetration, int reload, float shellVelocity, float mass, float dispersion, float maxDispersion, float caliber, float[] xPoints, float[] yPoints, int points, color fill, color stroke) {
      this.damage=damage;
      this.penetration=penetration;
      this.reload=reload;
      this.shellVelocity=shellVelocity;
      this.mass=mass;
      this.dispersion=dispersion;
      this.maxDispersion=maxDispersion;
      this.caliber=caliber;
      this.render=PartBuilder.createRender(xPoints,yPoints,points,fill,stroke);
    }
    
    public PShape getRender() {
      return render;
    }
    
    public void fire(float x, float y, float facing, int team) {
        float direction=clampedGaussian(facing,dispersion,facing-maxDispersion,facing+maxDispersion);
        createProjectile(x,y,direction,penetration,shellVelocity,damage,caliber,team);
    }
}

enum Engine {
  TEST(150,1.0,5.0),
  WEAK(75,0.7,3.0);
  
  public final int power;
  public final float traversePower;
  public final float mass;
  
  private Engine(int power, float traversePower, float mass) {
    this.power=power;
    this.traversePower=traversePower;
    this.mass=mass;
  }
}
