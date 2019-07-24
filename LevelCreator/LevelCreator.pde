import java.util.List;

List<Obstacle> obstacles = new ArrayList<Obstacle>();

Obstacle selectedObstacle;

void setup() {
  size(750,750);
  obstacles.add(selectedObstacle=new Obstacle(width/2,height/2));
}

void draw() {
  background(255);
  for(Obstacle o: obstacles) {
    o.render();
  }
}

void mouseClicked() {
  boolean found=false;
  for(Obstacle o:obstacles) {
    if(o.contains(mouseX,mouseY)) {
      selectedObstacle=o;
      println(o+"Contains "+mouseX+','+mouseY);
      found=true;
    }
  }
  if(!found) {
    obstacles.add(selectedObstacle=new Obstacle(mouseX,mouseY));
  }
}

void keyPressed() {
  if(key==CODED) {
    switch(keyCode) {
      case LEFT:
      selectedObstacle.nextVertex(-1);
      break;
      case RIGHT:
      selectedObstacle.nextVertex(1);
      break;
    }
  } else {
    switch(key) {
      case BACKSPACE:
      case DELETE:
      println("delete");
      selectedObstacle.delete();
      break;
      
      case 'a':
      selectedObstacle.nudge(-4,0);
      case 'A':
      selectedObstacle.nudge(-1,0);
      break;
      
      case 'o':
      selectedObstacle.nudge(0,4);
      case 'O':
      selectedObstacle.nudge(0,1);
      break;
      
      case 'e':
      selectedObstacle.nudge(4,0);
      case 'E':
      selectedObstacle.nudge(1,0);
      break;
      
      case ',':
      selectedObstacle.nudge(0,-4);
      case '<':
      selectedObstacle.nudge(0,-1);
      break;
      
      case '\'':
      selectedObstacle.spin(-3*PI/20);
      case '"':
      selectedObstacle.spin(-PI/20);
      break;
      
      case '.':
      selectedObstacle.spin(3*PI/20);
      case '>':
      selectedObstacle.spin(PI/20);
      break;
      
      case '=':
      case '+':
      selectedObstacle.addVertex();
      break;
    }
  }
}

void printMap() {
  for (Obstacle o : obstacles) {
    println(o);
  }
}
