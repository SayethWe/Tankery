public float findSquareDist(float x1, float y1, float x2, float y2){
  float xDist= x1-x2;
  float yDist= y1-y2;
  return (xDist*xDist)+(yDist*yDist);
}

public static float clampedGaussian(float mean, float variance, float min, float max) {
  float rand = instance.randomGaussian();
  float calcDamage = rand*variance+mean;
  return constrain(calcDamage, min, max);
}

static void createProjectile(float x, float y, float direction, float penetration, float shellVelocity, int damage, float caliber, int team) {
 instance.new QueuedProjectile(x,y,direction,penetration, shellVelocity,damage,caliber,team);
}

//avoid concurrent modification exceptions
static Set<QueuedProjectile> queue = new HashSet<QueuedProjectile>();


  
public static void createProjectiles() {
  for(QueuedProjectile qp:queue) {
    instance.new Projectile(qp.x,qp.y,qp.direction,qp.penetration,qp.velocity,qp.damage,qp.caliber,qp.team);
  }
  queue.clear();
}

class QueuedProjectile {
  
  
  public final float x,y,direction,penetration,velocity,caliber;
  public final int damage,team;
  
  public QueuedProjectile(float x, float y, float direction, float penetration, float shellVelocity, int damage, float caliber, int team) {
    this.x=x;
    this.y=y;
    this.direction=direction;
    this.penetration=penetration;
    this.velocity=shellVelocity;
    this.damage=damage;
    this.caliber=caliber;
    this.team=team;
    queue.add(this);
  }
}

static float angleBetween(float a, float b) {
  float diff = ( a - b + PI ) % TWO_PI - PI;
  return diff < -PI ? diff + TWO_PI : diff;
}

String formattedDate(char sep) {
  StringBuilder result = new StringBuilder();
  result.append(nf(year(),4)).append(sep);
  result.append(nf(month(),2)).append(sep);
  result.append(nf(day(),2));
  
  return result.toString();
}

void screenshot() {
  noLoop();
  save("screenshots/screenshot_"+formattedDate('-')+formattedTime('-')+".png");
  logger.log("Screenshot saved");
  loop();
}

String formattedTime(char sep) {
  StringBuilder result = new StringBuilder();
  result.append(nf(hour(),2)).append(sep);
  result.append(nf(minute(),2)).append(sep);
  result.append(nf(second(),2));
  return result.toString();
}

int sign(float f) {
  if (f==0) return 0;
  return (f<0)?-1:1;
}

enum LogLevel {
  
  ERROR("[ERROR] "),
  INFO("");
  
  public final String pre;
  
  private LogLevel(String pre) {
    this.pre=pre;
  }
  
}

class Logger {
  
  final PrintWriter logFile;
  
  public Logger(String path) {
    logFile = createWriter(path+"log_"+formattedDate('-')+'_'+formattedTime('-')+".txt");
  }
  
  public void dispose() {
    log("Closing Log");
    logFile.flush();
    logFile.close();
  }
  
  public void log(String text) {
    log(text, LogLevel.INFO);
  }
  
  public void log(String text, LogLevel level) {
    logFile.println(formattedTime(':')+' '+level.pre+text);
  }
  
  public void lineBreak() {
    logFile.println();
  }
  
}

class Hasher {
  private int result;
  
  final int prime;
  
  public Hasher(int prime) {
    this(prime,0);
  }
  
  public Hasher(int prime, int hash) {
    this.prime=prime;
    this.result=hash;
  }
  
  public int getResult() {
    return result;
  }
  
  public void append(Object o) {
    append((o==null)?0:o.hashCode());
  }
  
  public void append(int i) {
    result*=prime;
    result+=i;
  }
  
  public void append(float f) {
    result*=prime;
    result+=(int)(f+0.5);
  }
}
