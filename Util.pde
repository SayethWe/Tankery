public float findSquareDist(float x1, float y1, float x2, float y2){
  float xDist= x1-x2;
  float yDist= y1-y2;
  return (xDist*xDist)+(yDist*yDist);
}

static class PartBuilder {
  public static Shape createCollision(float[] xPoints, float[] yPoints, int points) {
    if(!(xPoints.length==points&&yPoints.length==points)) throw new IllegalArgumentException();
    return new Polygon(int(xPoints),int(yPoints),points);
  }
  public static  PShape createRender(float[] xPoints, float[] yPoints, int points, color fill, color stroke) {
    if(!(xPoints.length==points&&yPoints.length==points)) throw new IllegalArgumentException();
    PShape render = instance.createShape();
    render.beginShape();
    for(int i = 0; i<points; i++) {
      render.vertex(xPoints[i],yPoints[i]);
    }
    render.endShape(CLOSE);
    
    //color fillColor = instance.color(fill[0],fill[1],fill[2]);
    //color strokeColor = instance.color(stroke[0],stroke[1],stroke[2]);
    
    render.setFill(fill);
    render.setStroke(stroke);
    return render;
  }
}

public static float clampedGaussian(float mean, float variance, float min, float max) {
  float rand = instance.randomGaussian();
  float calcDamage = rand*variance+mean;
  return constrain(calcDamage, min, max);
}

static void createProjectile(float x, float y, float direction, float penetration, float shellVelocity, int damage, float caliber) {
  entities.add(instance.new Projectile(x,y,direction,penetration, shellVelocity,damage,caliber));
}
