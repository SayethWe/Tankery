import java.awt.Rectangle;

//a flying thing that can do damage
class Projectile extends Entity implements Impactor{
  private static final float PEN_LOSS_ON_BOUNCE = 0.1;
  private static final float DAMAGE_VARIANCE = 0.1;
  private static final float MAX_DAMAGE_VARIANCE = 0.3;
  private static final int FUSE = 6;
  
  private final Shape frameCollider;
  
  float penetration;
  float velocity;
  final float meanDamage;
  final int damage;
  final float caliber;
  final float explosiveLoad;
  byte age = 0;
  private boolean armed=false;
  
  public Projectile(float x, float y, float angle, float penetration, float velocity,float damage,float caliber,float explosiveLoad,int team) {
    super(x,y,angle,team);
    this.penetration=penetration;
    this.velocity=velocity;
    this.meanDamage=damage;
    this.damage=genDamage(damage);
    this.caliber=caliber;
    this.explosiveLoad=explosiveLoad;
    frameCollider = new Rectangle(int(-caliber),int(-caliber/2),int(velocity+2*caliber),int(caliber));
  }
  
  protected void addToTrackers() {
    impactors.add(this);
    super.addToTrackers();
  }
  
  public void update() {
    float newX=x+velocity*cos(facing);
    float newY=y+velocity*sin(facing);
    stroke(255,0,255);
    rectMode(CORNERS);
    line(x,y,newX,newY);
    moveTo(newX,newY);
    
    age++;
    if(age>50) markToRemove();
    if(age==FUSE) arm();
  }
  
  public void render() {
    fill(0);
    noStroke();
    ellipseMode(CENTER);
    ellipse(x,y,caliber,caliber);
  }
  
  public int impact(Hittable h) {
    float thickness = h.getThicknessTowards(facing);
    if(thickness<penetration&&armed) {
      h.damage(damage);
      markToRemove();
      return damage;
    } else {
      //Todo: Bouncing
      explosion(x,y,caliber*explosiveLoad,int(damage*explosiveLoad),team);
      markToRemove();
      return 0;
    }
  }
  
  public Area getCollider() {
    AffineTransform at = new AffineTransform();
    at.translate(x,y);
    at.rotate(facing);
    return new Area(at.createTransformedShape(frameCollider));
  }
  
  private void arm() {
    //projectiles.add(this);
    armed=true;
    logger.log(this+ "armed at "+x+","+y+" with heading "+facing+"rad");
  }
  
  //load how much damage this is going to do, based on a gaussian curve
  private int genDamage(float meanDamage) {
    float variance = DAMAGE_VARIANCE*meanDamage;
    float maxVariance = MAX_DAMAGE_VARIANCE*meanDamage;
    return int(clampedGaussian(meanDamage, variance, meanDamage-maxVariance, meanDamage+maxVariance));
  }
}
