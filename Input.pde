import java.util.Map;

Map<Character,Boolean>keys=new HashMap<Character,Boolean>();

void keyPressed() {
  keys.put(Character.toLowerCase(key),true);
}

void keyReleased() {
  keys.put(Character.toLowerCase(key),false);
}

void handleKeys() {
  if (keys.getOrDefault('s', false)) {
    stop();
    delay(2500);
    exit();
  }
  testPlayer.handleKeyInput(keys);
}
