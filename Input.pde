import java.util.Map;

Map<Character,Boolean>keys=new HashMap<Character,Boolean>();

void keyPressed() {
  keys.put(Character.toLowerCase(key),true);
}

void keyReleased() {
  keys.put(Character.toLowerCase(key),false);
}

void handleMovement() {
  if (keys.getOrDefault(',',false)) {
    playerTank.drive();
    testPlayer.moveTo(playerTank);
  } else if (keys.getOrDefault('o',false)) {
    playerTank.back();    
    testPlayer.moveTo(playerTank);
  }
  
  if (keys.getOrDefault('a',false)) {
    playerTank.turn(-1);
  } else if (keys.getOrDefault('e',false)) {
    playerTank.turn(1);
  }
  
  if (keys.getOrDefault('\'',false)) {
    playerTank.aimTurret(-1);
    testPlayer.turnTo(playerTank.getTurretFacing());
  } else if (keys.getOrDefault('.',false)) {
    playerTank.aimTurret(1);
    testPlayer.turnTo(playerTank.getTurretFacing());
  }
  
  if (keys.getOrDefault(' ',false)) {
    playerTank.fire();
  }
  
  if (keys.getOrDefault('s',false)) {
    exit();
  }
  
  if (keys.getOrDefault('d',false)) {
    playerTank.damage(1);
  } else if (keys.getOrDefault('h',false)) {
    playerTank.damage(-5);
  }
}
