class Projectile extends Entity{
  private static final float PEN_LOSS_ON_BOUNCE = 0.1;
  private static final float DAMAGE_VARIANCE = 0.1;
  private static final float MAX_DAMAGE_VARIANCE = 0.3;
  private static final int FUSE = 5;
  
  float penetration;
  float velocity;
  final float meanDamage;
  final float caliber;
  byte age = 0;
  
  public Projectile(float x, float y,float angle, float penetration,float velocity,float damage,float caliber) {
    super(x,y,angle);
    this.penetration=penetration;
    this.velocity=velocity;
    this.meanDamage=damage;
    this.caliber=caliber;
  }
  
  public void update() {
    float newX=x+velocity*cos(facing);
    float newY=y+velocity*sin(facing);
    moveTo(newX,newY);
    
    age++;
    if(age>50) markToRemove();
    if(age==FUSE) arm();
  }
  
  @Override
  public void markToRemove() {
     super.markToRemove();
     deadProjectiles.add(this);
     //logger.log(getDamage());
  }
  
  public void render() {
    fill(0);
    noStroke();
    ellipseMode(CENTER);
    ellipse(x,y,caliber,caliber);
  }
  
  public int impact(float angle, float thickness) {
    float incidence = facing-angle;
    float effectiveThickness=abs(thickness/sin(incidence));
    markToRemove();
    if(effectiveThickness<penetration) {
      return getDamage();
    } else {
      return 0;
    }
  }
  
  private void arm() {
    projectiles.add(this);
    logger.log(this+ "armed at "+x+","+y+" with heading "+facing+"rad");
  }
  
  public int getDamage() {
    float variance = DAMAGE_VARIANCE*meanDamage;
    float maxVariance = MAX_DAMAGE_VARIANCE*meanDamage;
    return int(clampedGaussian(meanDamage, variance, meanDamage-maxVariance, meanDamage+maxVariance));
  }
  
  public boolean contains(float x, float y) {
    return(x==this.x&&y==this.y);
  }
  public float getThickness() {
    return 0; 
  }
  public void damage(int damage){
    this.markToRemove();
  };
}
