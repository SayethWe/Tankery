class Infantry extends Entity implements Hittable {
  
  private final Shape collider;
  private final PShape render;
  
  public Infantry(float x, float y, float facing, int team) {
    super(x,y,facing,team);
    collider=new Ellipse2D.Float(0,0,5,5);
    render=createShape(ELLIPSE,0,0,5,5);
  }
  
  protected void addToTrackers() {
    super.addToTrackers();
    hittables.add(this);
  }
  
  public void render() {
    pushMatrix();
    translate(x,y);
    rotate(facing);
    shape(render);
    popMatrix();
  }
  
  public void update() {
    
  }
  
  public void damage(int damage) {
    markToRemove();
  }
  
  public boolean contains(Area a) {
    AffineTransform at = new AffineTransform();
    at.translate(x,y);
    at.rotate(facing);
    Area col = new Area(at.createTransformedShape(collider));
    col.intersect(a);
    return !col.isEmpty();
  }
  
  public float getThickness() {
    return 0.25;
  }
  
  public float getThicknessTowards(float dir) {
    return 0.25;
  }
}
