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
  
  TEST(70,20.0,70,new float[]{-25, 25,30,25,-25},new float[]{-15,-15, 0,15, 15},5,#80EE54,#80EE54);
  
  public final float mass;
  public final int maxHealth;
  public final float armor;
  
  //TODO: collision polygon
  private final Shape collision;
  protected final PShape render;
  
  private Hull(int maxHealth, float mass, float armor, float[] xPoints, float[] yPoints, int points, color fill, color stroke) {
    this.maxHealth=maxHealth;
    this.mass=mass;
    this.armor=armor;
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
  
  TEST(PI/20,5.0,30,new float[]{20,-10,-10},new float[]{0,17.3,-17.3},3,#6E52FF,#6E52FF);
  
  public final float mass;
  public final float turnRate;
  public final int maxHealth;
  
  private final Shape collision;
  protected final PShape render;
  
  private Turret(float turnRate, float mass, int maxHealth, float[] xPoints, float[] yPoints, int points, color fill, color stroke) {
    this.turnRate=turnRate;
    this.mass=mass;
    this.maxHealth=maxHealth;
    
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
    TEST(50,75,10,6,2.5,PI/100,PI/20,3.5,new float[]{0,30,30,0},new float[]{-2,-2,2,2},4,#CD3F66,#000000);
  
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
    
    public void fire(float x, float y, float facing) {
        float direction=clampedGaussian(facing,dispersion,facing-maxDispersion,facing+maxDispersion);
        createProjectile(x,y,direction,penetration,shellVelocity,damage,caliber);
    }
}

enum Engine {
  TEST(150,5.0);
  
  public final int power;
  public final float mass;
  
  private Engine(int power,float mass) {
    this.power=power;
    this.mass=mass;
  }
}
