import java.awt.geom.Ellipse2D;

//a flying thing that can do damage
class Projectile extends Entity implements Impactor{
  private static final float PEN_LOSS_ON_BOUNCE = 0.1;
  private static final float DAMAGE_VARIANCE = 0.1;
  private static final float MAX_DAMAGE_VARIANCE = 0.3;
  private static final int FUSE = 6;
  
  float penetration;
  float velocity;
  final float meanDamage;
  final int damage;
  final float caliber;
  byte age = 0;
  private boolean armed=false;
  
  public Projectile(float x, float y, float angle, float penetration, float velocity,float damage,float caliber,int team) {
    super(x,y,angle,team);
    this.penetration=penetration;
    this.velocity=velocity;
    this.meanDamage=damage;
    this.damage=genDamage(damage);
    this.caliber=caliber;
  }
  
  protected void addToTrackers() {
    impactors.add(this);
    super.addToTrackers();
  }
  
  public void update() {
    float newX=x+velocity*cos(facing);
    float newY=y+velocity*sin(facing);
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
    float thickness = h.getThickness(facing);
    if(thickness<penetration&&armed) {
      h.damage(damage);
      markToRemove();
      return damage;
    } else {
      //Todo: Bouncing
      markToRemove();
      return 0;
    }
  }
  
  public Area getCollider() {
    return new Area(new Ellipse2D.Float(x,y,caliber,caliber));
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
