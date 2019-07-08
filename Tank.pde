class Tank extends Entity {
  private final Hull hull;
  private final Turret turret;
  private final Cannon cannon;
  private final Engine engine;
  private final float mass;
  public final int maxHealth;
  private final float speed;
  
  private float turretFacing;
  private int health;
  private int reloadCounter;
  
  public Tank() {
    this(0,0,0,0,Hull.TEST,Turret.TEST,Cannon.TEST,Engine.TEST);
  }
  
  public Tank(float x, float y, float facing, float turretFacing) {
    this(x,y,facing,turretFacing, Hull.TEST, Turret.TEST, Cannon.TEST, Engine.TEST);
  }
  
  public Tank(float x, float y, float facing, float turretFacing, Hull hull, Turret turret, Cannon cannon, Engine engine) {
    super(x,y,facing);
    this.hull=hull;
    this.turret=turret;
    this.turretFacing=turretFacing;
    this.cannon=cannon;
    this.engine=engine;
    this.mass = hull.mass+turret.mass+cannon.mass+engine.mass;
    this.maxHealth=hull.maxHealth+turret.maxHealth;
    this.health=this.maxHealth;
    this.speed=engine.power/mass;
  }
  
  public void turnTurret(float delTheta) {
    turretFacing+=delTheta;
  }
  public void turnTurretTo(float theta) {
    turretFacing=theta;
  }
  
  public void damage(int damage) {
    health-=damage;
    health=constrain(health,0,maxHealth);
    if(health==0) this.markToRemove();
    println(health+" "+damage); 
  }
  
  public void render() {
    render(hull,x,y,facing);
    render(turret,x,y,turretFacing);
    render(cannon,x,y,turretFacing);
  }
  
  public void render(Renderable r, float x, float y, float facing) {
    pushMatrix();
    translate(x,y);
    rotate(facing);
    shape(r.getRender());
    popMatrix();
  }
  
  public boolean collide(Collideable c, float x, float y, float facing, float checkX, float checkY) {
    AffineTransform at = new AffineTransform();
    at.translate(x,y);
    at.rotate(facing);
    Shape collider = at.createTransformedShape(c.getCollider());
    return collider.contains(checkX,checkY);
  }
  
  public boolean contains(float x, float y) {
    //TODO: Use java.awt.shape for collision detection
    //return(dist(this.x,this.y,x,y)<20);
    return(collide(turret, this.x,this.y,turretFacing,x,y)||collide(hull, this.x,this.y,facing,x,y));
  }
  public float getThickness() {
    return hull.armor;
  }
  
  public int getHealth() {
    return health;
  }
  
  public float getTurretFacing() {
    return turretFacing;
  }
  
  public void fire() {
    if(reloadCounter==0) {
      cannon.fire(x,y,turretFacing);
      reloadCounter=cannon.reload;
    }
  }
  
  public void drive() {
    float newX = x+speed*cos(facing);
    float newY = y+speed*sin(facing);
    moveTo(newX,newY);
  }
  
  public void back() {
    float newX = x-speed*cos(facing)/2;
    float newY = y-speed*sin(facing)/2;
    moveTo(newX,newY);
  }
  
  public void turn(int dir) {
    println("traverse "+dir);
    float traverse = PI/20;
    turnBy(traverse*dir);
  }
  
  public void aimTurret(int dir) {
    turnTurret(turret.turnRate*dir);
  }
  
  public void update() {
    reloadStep(false);
  }
  
  public void reloadStep(boolean wasLoader) {
      if(wasLoader) {
        reloadCounter=0;
      } else if (reloadCounter>0) {
        reloadCounter--;
      }
    }
}
