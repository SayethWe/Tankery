public abstract class Level {
  private final Set<Entity> enemies;
  private final Set<Obstacle> terrain;
  protected final Tank playerTank;
  
  public Level() {
    enemies = new HashSet<Entity>();
    terrain = new HashSet<Obstacle>();
    playerTank = new Tank();
  }
  
  public void addEnemy(Entity enemy) {
    enemies.add(enemy);
  }
  public void addTerrain(Obstacle obstacle) {
    terrain.add(obstacle);
  }
  
  public void update() {
    
  }
  
  public void render() {
    
  }
  
  public abstract void checkWinCondition();
}

public class Obstacle extends Entity implements Hittable {
  final Shape collider;
  final PShape render;
  
  public Obstacle(float x, float y, float facing, float[] xPoints, float[] yPoints, int vertices) {
    super(x,y,facing); 
    AffineTransform at = new AffineTransform();
    at.translate(x,y);
    at.rotate(facing);
    collider=at.createTransformedShape(PartBuilder.createCollision(xPoints,yPoints,vertices));
    render=PartBuilder.createRender(xPoints,yPoints,vertices,#000000,#A0A0A0);
  }

  public void addToTrackers() {
    super.addToTrackers();
    hittables.add(this);
  }
  
  
  public void damage(int damage) {}
  
  public boolean contains(Shape other) {
    return collider.intersects(other.getBounds());
  }
  
  public float getThickness(float facing) {
    return 200;
  }
  
  public void render() {
    pushMatrix();
    translate(x,y);
    rotate(facing);
    shape(render);
    popMatrix();
  }
  
  public void update(){}
}
