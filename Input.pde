import java.util.Map;

Map<Character,Boolean>keys=new HashMap<Character,Boolean>();

void keyPressed() {
  if(key!=CODED){
    keys.put(Character.toLowerCase(key),true);
    switch(Character.toLowerCase(key)) {
      case 'g':
      testPlayer=testGunner;
      break;
      case 'c':
      testPlayer = testCommander;
      break;
      case 'r':
      testPlayer=testDriver;
    }
  }
}

void keyReleased() {
  if(key!=CODED){
    keys.put(Character.toLowerCase(key),false);
  }
}

void handleKeys() {
  if (keys.getOrDefault('s', false)) {
    stop();
    delay(2500);
    exit();
  }
  testPlayer.handleKeyInput(keys);
}
