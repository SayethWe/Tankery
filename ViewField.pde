import java.util.Collections;

//a certain space that can be seen
public class ViewField {
  
  private static final int RAY_COUNT = 2;
  
  private final float viewAngle, viewArc;
  private final float viewDistance;
  private final float viewDistSquare;
  private final int fogScale;
  
  public ViewField(float viewAngle, float viewDistance, int resolution) {
    this.viewAngle = viewAngle;
    this.viewArc = viewAngle/2;
    this.viewDistance = viewDistance;
    this.viewDistSquare = viewDistance*viewDistance;
    this.fogScale = resolution;
  }
  
  public boolean isInView(float x, float y, float facing, float checkX, float checkY) {
    float distSquare=findSquareDist(checkX, checkY, x, y);
    if (distSquare>=viewDistSquare)return false;

    float angle=atan2(checkY-y, checkX-x);
    //angle=(angle+TWO_PI)%TWO_PI;
    //herein lies the problem
    float seperation = angleBetween(facing,angle);
    return (abs(seperation)<=viewArc);
  }
  
  public Shape createViewPolygon(float x, float y, float facing) {
    //basic rays
    List<LineSegment> rays = new ArrayList<LineSegment>();
    for (int ray = 0; ray<=RAY_COUNT; ray++) {
      float dir = facing-viewArc+ray*viewAngle/RAY_COUNT;
      //println(dir);
      rays.add(new LineSegment(x,y,dir,viewDistance,true));
    }
    //edge-finding rays
     println(viewBlocks.size());
    for(Opaque o: viewBlocks) {
      for (LineSegment l : o.getEdges()) {
        float dir = atan2(l.y1-y,l.x1-x);
        if(abs(angleBetween(facing,dir))<viewArc) {
          //println(dir + " Is Between " + (facing-viewArc) + " and " + (facing+viewArc));
          LineSegment cornerRay = new LineSegment(x,y,dir,viewDistance,true);
          rays.add(cornerRay);
          rays.add(new LineSegment(x,y,dir-PI/100,viewDistance,true));
          rays.add(new LineSegment(x,y,dir+PI/100,viewDistance,true));
        }
      }
    }
    Collections.sort(rays);
    //println(rays);
    //println(rays.size()+" rays cast");
    //collision
    List<Integer> xList = new ArrayList<Integer>(rays.size()+1);
    List<Integer> yList = new ArrayList<Integer>(rays.size()+1);
    //fill(0);
    //beginShape();
    //vertex(x,y);
    xList.add(int(x));
    yList.add(int(y));
    for (LineSegment l:rays) {
      Set<Float> collisions = new HashSet<Float>();
      
      for(Opaque o: viewBlocks) {
        //println(o);
        //println(o.getEdges().size());
        for (LineSegment l2 : o.getEdges()) {
          float col = l.intersects(l2);
          if(col>0) {
            collisions.add(min(col,1));
          }
        }
      }
      float min = collisions.isEmpty()?1:Collections.min(collisions);
      xList.add(int(x+cos(l.getDirection())*min*viewDistance));
      yList.add(int(y+sin(l.getDirection())*min*viewDistance));
    }
    //create polygon
    int points = xList.size();
    if(yList.size()!=points) throw new ArithmeticException("Imbalanced point arrays");
    int[] xPoints = new int[points];
    int[] yPoints = new int[points];
    for(int i = 0; i<points; i++) {
      xPoints[i]=xList.get(i);
      yPoints[i]=yList.get(i);
      //println(xList.get(i)+","+yList.get(i));
      //vertex(xList.get(i),yList.get(i));
    }
    //endShape(CLOSE);
    return new Polygon(xPoints,yPoints,points);
    
  }
  
  //public void render(float x, float y, float facing) {
  //  fill(128);
  //  noStroke();
  //  beginShape();
  //  vertex(x,y);
  //  vertex(x+viewDistance*cos(facing+viewAngle/2),y+viewDistance*sin(facing+viewAngle/2));
  //  float angle = floor(facing/PI/2)*PI/2+PI/4;
  //  float dist=sqrt(2)*viewDistance;
  //  for(int i = 0; i<4;i++) {
  //    float dir = i*PI/2+angle;
  //    vertex(x+dist*cos(dir),y+dist*sin(dir));
  //  }
  //  vertex(x+viewDistance*cos(facing-viewAngle/2),y+viewDistance*sin(facing-viewAngle/2));
  //  endShape(CLOSE);
  //}
  
  public float getViewDistance() {
    return viewDistance;
  }
  
  public int getFogScale() {
    return fogScale;
  }
  
}
