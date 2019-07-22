import java.awt.geom.Ellipse2D;

public class Explosion extends Entity implements Impactor {
  private static final float GROWTH_RATE=0.7;
  private static final float SHRINK_RATE=0.5;
  private static final float TOLERANCE = 3.5;
  
  private final float size;
  private final int damage;
  
  private float currentSize;
  private boolean growing;
  
  public Explosion(float x, float y, float size, int damage) {
    super(x,y,0,127);
    this.size=size;
    this.currentSize=0;
    this.growing=true;
    this.damage=damage;
    println("explosion at "+x+","+y);
  }
  
  public void addToTrackers() {
    impactors.add(this);
    super.addToTrackers();
  }
  
  public void render() {
    ellipseMode(RADIUS);
    fill(240,169,82);
    noStroke();
    ellipse(x,y,currentSize,currentSize);
  }
  
  public void update() {
    if(growing) {
      if(abs(size-currentSize)<TOLERANCE||currentSize>size) {
        growing=false;
      } else {
        float growth=GROWTH_RATE*(size-currentSize);
        currentSize+=growth;
      }
    } else {
      if(currentSize<TOLERANCE) {
        this.markToRemove();
      } else {
        float contraction = SHRINK_RATE*currentSize;
        currentSize-=contraction;
      }
    }
  }
  
  public Area getCollider() {
    return new Area(new Ellipse2D.Float(x+size,y+size,currentSize*2,currentSize*2));
  }
  
  public int impact(Hittable h) {
    h.damage(damage); //TODO: reduce with thickness, after proper angle incident calculation is applied
    return damage;
  }
}
