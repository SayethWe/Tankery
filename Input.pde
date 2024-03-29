import java.util.Map;
import java.util.EnumMap;
import java.util.stream.*;

//keys that are currently being held
Map<Keybind,Boolean>keys=new EnumMap<Keybind,Boolean>(Keybind.class);

static boolean paused=false;

void keyPressed() {
  if(key!=CODED){
    keys.put(keybinds.getOrDefault(Character.toLowerCase(key),Keybind.UNKNOWN),true);
    switch(Character.toLowerCase(key)) {
      case '1':
      testPlayer=testGunner;
      break;
      case '2':
      testPlayer=testCommander;
      break;
      case '3':
      testPlayer=testDriver;
      break;
      case '[':
      playerTank.damage(1);
      break;
      case ']':
      playerTank.damage(-5);
      break;
      case '\\':
      screenshot();
      break;
      case 'p':
      if(paused) {loop();}else{noLoop();}
      paused=!paused;
      break;
      case '=':
      stop();
      exit();
      break;
    }
  }
}

void keyReleased() {
  if(key!=CODED){
    keys.put(keybinds.getOrDefault(Character.toLowerCase(key),Keybind.UNKNOWN),false);
  }
}

void handleKeys() {
  //TODO: use Streams and filter
  for (Keybind kb : keys.keySet()) {
    if (keys.get(kb)) testPlayer.handleKeyInput(kb);   
  }
}

enum Keybind {
  FRONT(),
  BACK(),
  LEFT(),
  RIGHT(),
  ACTION(),
  AUXILIARY(),
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
  result.put('x',Keybind.AUXILIARY);
  return result;
}

Map<Character,Keybind> qwertyLayout() {
  Map<Character,Keybind> result = new HashMap<Character,Keybind>();
  result.put('q',Keybind.SLOW_LEFT);
  result.put('w',Keybind.FRONT);
  result.put('e',Keybind.SLOW_RIGHT);
  result.put('a',Keybind.LEFT);
  result.put('s',Keybind.BACK);
  result.put('d',Keybind.RIGHT);
  result.put(' ',Keybind.ACTION);
  result.put('x',Keybind.AUXILIARY);
  return result;
}
