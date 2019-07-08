StringBuilder x =new StringBuilder("new float[]{");
StringBuilder y = new StringBuilder("new float[]{");
PShape render = createShape();

color fill=color(135,244,245);
color stroke=color(34,93,103);

String fillString = '#'+hex(fill,6);
String strokeString = '#'+hex(stroke,6);

int vertices=5;
int radius = 20;
float delTheta = TWO_PI/vertices;

//--------------

render.beginShape();
for (int i = 0; i<vertices; i++) {
  float angle=i*delTheta;
  float xVert = radius*cos(angle);
  float yVert = radius*sin(angle);
  x.append(nf(xVert,1,2)).append(", ");
  y.append(nf(yVert,1,2)).append(", ");
  render.vertex(xVert,yVert);
}
render.endShape(CLOSE);
render.setFill(fill);
render.setStroke(stroke);

x.setLength(max(x.length()-2, 0));
y.setLength(max(y.length()-2, 0));

x.append('}');
y.append('}');

translate(width/2, height/2);
shape(render);

println(x);
println(y);
println(vertices);
println(fillString);
println(strokeString);

StringBuilder printable = new StringBuilder();
printable.append(x).append(", ");
printable.append(y).append(", ");
printable.append(vertices).append(", ");
printable.append(fillString).append(", ");
printable.append(strokeString);

println();
println(printable);
