import java.awt.Polygon;
import java.awt.geom.AffineTransform;
import java.awt.Shape;

public class Obstacle {
  float x,y,rot;
  
  float[] xPoints;
  float[] yPoints;
  
  int selectedVertex;
  
  public Obstacle(float x, float y) {
    this.x=x;
    this.y=y;
    this.rot=0;
    this.selectedVertex=-1;
    this.xPoints=new float[]{-10,10,10,-10};
    this.yPoints=new float[]{-5,-5,5,5};
  }
  
  public boolean contains(float x_, float y_) {
    AffineTransform at = new AffineTransform();
    at.translate(x,y);
    at.rotate(rot);
    Shape col = at.createTransformedShape(new Polygon(int(xPoints),int(yPoints),xPoints.length));
    return col.contains(x_,y_);
  }
  
  public void nudge(float delX,float delY) {
    if(selectedVertex==-1) {
      x+=delX;
      y+=delY;
    } else {
      xPoints[selectedVertex]+=delX;
      yPoints[selectedVertex]+=delY;
    }
  }
  
  public void spin(float delRot) {
    rot+=delRot;
  }
  
  public void nextVertex(int dir) {
    selectedVertex+=dir;
    if(selectedVertex>=xPoints.length) {
      selectedVertex=-1;
    } else if(selectedVertex<-1) {
      selectedVertex=xPoints.length-1;
    }
  }
  
  public void addVertex() {
    float[] newX = new float[xPoints.length+1];
    float[] newY = new float[xPoints.length+1];
    int addVertex=selectedVertex+1;
    for (int i = 0; i<newX.length; i++) {
      if(i==addVertex) {
        newX[i]=0;
        newY[i]=0;
      } else if (i>addVertex) {
        newX[i]=xPoints[i-1];
        newY[i]=yPoints[i-1];
      } else {
        newX[i]=xPoints[i];
        newY[i]=yPoints[i];
      }
    }
    xPoints=newX;
    yPoints=newY;
    selectedVertex=addVertex;
  }
  
  private void removeVertex() {
    float[] newX = new float[xPoints.length-1];
    float[] newY = new float[xPoints.length-1];
    for(int i = 0; i<newX.length; i++) {
      if(i<selectedVertex) {
        newX[i]=xPoints[i];
        newY[i]=yPoints[i];
      } else {
        newX[i]=xPoints[i+1];
        newY[i]=yPoints[i+1];
      }
    }
    xPoints=newX;
    yPoints=newY;
  }
  
  public void delete() {
    if(selectedVertex==-1||xPoints.length==3) {
      obstacles.remove(this);
    } else {
      removeVertex();
    }
  }
  
  @Override
  public String toString() {
    StringBuilder result = new StringBuilder("Obstacle|");
    result.append(x).append(',').append(y).append('|');
    result.append(rot).append('|');
    for (float f:xPoints) {
      result.append(f).append(',');
    }
    result.append('|');
    for (float f:yPoints) {
      result.append(f).append(',');
    }
    return result.toString();
  }
  
  public void render() {
    boolean selected = false;
    if(selectedObstacle.equals(this)){
      selected=true;
      fill(128);
    } else {
      fill(0);
    }
    noStroke();
    pushMatrix();
    translate(x,y);
    rotate(rot);
    beginShape();
    for (int i=0; i<xPoints.length;i++) {
      vertex(xPoints[i],yPoints[i]);
    }
    endShape(CLOSE);
    
    if(selected){
      float selectedX = 0;
      float selectedY = 0;
      if(selectedVertex!=-1) {
        selectedX=xPoints[selectedVertex];
        selectedY=yPoints[selectedVertex];
        noFill();
        stroke(255,0,0);
        ellipse(selectedX,selectedY,4,4);
      }
      stroke(85,200,40);
      line(selectedX-20,selectedY,selectedX+20,selectedY);
      ellipse(selectedX+10,selectedY,2,2);
      stroke(85,170,225);
      line(selectedX,selectedY-20,selectedX,selectedY+20);
      ellipse(selectedX,selectedY+10,2,2);
    }
    popMatrix();
  }
}
