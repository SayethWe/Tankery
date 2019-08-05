interface Opaque {
  public List<LineSegment> getEdges();
}

public class LineSegment implements Comparable<LineSegment> {
  private static final float RAY_LENGTH_INIT = 100;
  public final float x1, y1, x2, y2, delY, delX;
  
  public LineSegment(float x1, float y1, float x2, float y2) {
    this.x1=x1;
    this.y1=y1;
    this.x2=x2;
    this.y2=y2;
    this.delX=x2-x1;
    this.delY=y2-y1;
    //println(toString());
  }
  
  public LineSegment(float x, float y, float dir, float len, boolean ray) {
    this(x,y,x+cos(dir)*len,y+sin(dir)*len);
    //println("Ray " + x+","+y+":"+dir+'/'+len);
  }
  
  public LineSegment(float... points) {
    this(points[0],points[1],points[2],points[3]);
    if(points.length!=4) throw new IllegalArgumentException("Incorrect number of points for line segment");
  }
  
  public LineSegment translate(float delX,float delY) {
    return new LineSegment(x1+delX, y1+delY, x2+delX, y2+delY); 
  }
  
  public LineSegment rotate(float xPrime, float yPrime, float theta) {
    float angle1 = atan2(yPrime-y1,xPrime-x1);
    float dist1 = dist(x1,y1,xPrime,yPrime);
    float angle2 = atan2(yPrime-y2,xPrime-x1);
    float dist2 = dist(x2,y2,xPrime,yPrime);
    return new LineSegment(xPrime+cos(angle1+theta)*dist1,yPrime+sin(angle1+theta)*dist1,xPrime+cos(angle2+theta)*dist2,yPrime+sin(angle2+theta)*dist2);
  }
  
  public float intersects(LineSegment l) {
    float t2 = (delX*(l.y1-y1) + delY*(x1-l.x1))/(l.delX*delY-l.delY*delX);
    if(t2 >= 0 && t2<=1) {
      return (l.x1+l.delX*t2-x1)/delX;
    } else {
      return -1;
    }
  }
  
  public float getDirection() {
    return atan2(y2-y1,x2-x1);
  }
  
  @Override
  public int compareTo(LineSegment other) {
    return sign(angleBetween(other.getDirection(),getDirection()));
  }
  @Override
  public String toString() {
    return "Line " + x1+ ","+y1+"/"+x2+","+y2;
  }
}
