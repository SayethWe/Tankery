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

public class Obstacle {
  
}
