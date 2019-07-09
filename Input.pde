import java.util.Map;
import java.util.EnumMap;
import java.util.stream.*;

Map<Keybind,Boolean>keys=new EnumMap<Keybind,Boolean>(Keybind.class);

Map<Character,Keybind>keybinds = dvorakLayout();

void keyPressed() {
  if(key!=CODED){
    keys.put(keybinds.getOrDefault(Character.toLowerCase(key),Keybind.UNKNOWN),true);
    switch(Character.toLowerCase(key)) {
      case 'g':
      testPlayer=testGunner;
      break;
      case 'c':
      testPlayer = testCommander;
      break;
      case 'r':
      testPlayer=testDriver;
      break;
      case 'd':
      playerTank.damage(1);
      break;
      case 'h':
      playerTank.damage(-5);
      break;
      case '=':
      stop();
      exit();
    }
  }
}

void keyReleased() {
  if(key!=CODED){
    keys.put(keybinds.getOrDefault(Character.toLowerCase(key),Keybind.UNKNOWN),false);
  }
}

void handleKeys() {
  testPlayer.handleKeyInput(keys);
}

enum Keybind {
  FRONT(),
  BACK(),
  LEFT(),
  RIGHT(),
  ACTION(),
  SLOW_LEFT(),
  SLOW_RIGHT(),
  UNKNOWN();
}

Map<Character,Keybind> dvorakLayout() {
  Map<Character,Keybind> result = new HashMap<Character,Keybind>();
  result.put('\'',Keybind.SLOW_LEFT);
  result.put(',',Keybind.FRONT);
  result.put('.',Keybind.SLOW_RIGHT);
  result.put('a',Keybind.LEFT);
  result.put('o',Keybind.BACK);
  result.put('e',Keybind.RIGHT);
  result.put(' ',Keybind.ACTION);
  return result;
}
