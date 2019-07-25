import java.awt.geom.Ellipse2D;

public class Explosion extends Entity implements Impactor {
  private static final float GROWTH_RATE=0.7;
  private static final float SHRINK_RATE=0.25;
  private static final float TOLERANCE = 3.5;
  
  private final float size;
  private final int damage;
  
  private float currentSize;
  private boolean growing;
  
  //private final Shape collider;
  
  public Explosion(float x, float y, float size, int damage, int team) {
    super(x,y,0,team);
    this.size=size;
    this.currentSize=0;
    this.growing=true;
    this.damage=damage;
    //this.collider=new Ellipse2D.Float(x-size,y-size,size*2,size*2);
    //println("explosion at "+x+","+y);
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
    return new Area(new Ellipse2D.Float(x-size,y-size,currentSize*2,currentSize*2));
  }
  
  public int impact(Hittable h) {
    //println(this+" exploded on "+h);
    h.damage(int(damage/h.getThickness())); //TODO: reduce with thickness properly, after proper angle incident calculation is applied
    return damage;
  }
}
