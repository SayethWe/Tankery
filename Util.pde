//distance, squared. slightly faster by virtue of not using sqrt
public float findSquareDist(float x1, float y1, float x2, float y2){
  float xDist= x1-x2;
  float yDist= y1-y2;
  return (xDist*xDist)+(yDist*yDist);
}

//basic statistics on a normal distribution
public static float clampedGaussian(float mean, float variance, float min, float max) {
  float rand = instance.randomGaussian();
  float calc = rand*variance+mean;
  return constrain(calc, min, max);
}

//load a new projectile in
static void createProjectile(float x, float y, float direction, float penetration, float shellVelocity, int damage, float caliber,float explosiveLoad, int team) {
 instance.new QueuedProjectile(x,y,direction,penetration, shellVelocity,damage,caliber,explosiveLoad,team);
}

static void explosion(float x, float y, float size,float damage) {
  instance.new QueuedExplosion(x,y,size,int(damage));
}

//avoid concurrent modification exceptions
static Set<QueuedProjectile> queue = new HashSet<QueuedProjectile>();
static Set<QueuedExplosion> explosionQueue = new HashSet<QueuedExplosion>();


  
public static void handleQueues() {
  for(QueuedProjectile qp:queue) {
    instance.new Projectile(qp.x,qp.y,qp.direction,qp.penetration,qp.velocity,qp.damage,qp.caliber,qp.load,qp.team);
  }
  queue.clear();
  for(QueuedExplosion qe:explosionQueue) {
    instance.new Explosion(qe.x,qe.y,qe.size,qe.damage);
  }
  explosionQueue.clear();
}

class QueuedProjectile { 
  
  public final float x,y,direction,penetration,velocity,caliber,load;
  public final int damage,team;
  
  public QueuedProjectile(float x, float y, float direction, float penetration, float shellVelocity, int damage, float caliber, float load, int team) {
    this.x=x;
    this.y=y;
    this.direction=direction;
    this.penetration=penetration;
    this.velocity=shellVelocity;
    this.damage=damage;
    this.caliber=caliber;
    this.team=team;
    this.load=load;
    queue.add(this);
  }
}

class QueuedExplosion {
  public final float x,y,size;
  public final int damage;
  
  public QueuedExplosion(float x, float y, float size, int damage) {
    this.x=x;
    this.y=y;
    this.size=size;
    this.damage=damage;
    explosionQueue.add(this);
  }
}

//the angle between two angle.
static float angleBetween(float a, float b) {
  float diff = ( a - b + PI ) % TWO_PI - PI;
  return diff < -PI ? diff + TWO_PI : diff;
}

//current date, formatted
String formattedDate(char sep) {
  StringBuilder result = new StringBuilder();
  result.append(nf(year(),4)).append(sep);
  result.append(nf(month(),2)).append(sep);
  result.append(nf(day(),2));
  
  return result.toString();
}

//save a screenshot
void screenshot() {
  noLoop();
  save("screenshots/screenshot_"+formattedDate('-')+'_'+formattedTime('-')+".png");
  logger.log("Screenshot saved");
  loop();
}

//current time, formatted
String formattedTime(char sep) {
  StringBuilder result = new StringBuilder();
  result.append(nf(hour(),2)).append(sep);
  result.append(nf(minute(),2)).append(sep);
  result.append(nf(second(),2));
  return result.toString();
}

//if a number is positive, negative, or 0
int sign(float f) {
  if (f==0) return 0;
  return (f<0)?-1:1;
}

//log level stuff
enum LogLevel {
  
  ERROR("[ERROR] "),
  INFO("");
  
  public final String pre;
  
  private LogLevel(String pre) {
    this.pre=pre;
  }
  
}

//A logger that writes to a log file.
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

//Helpful function to create hashcodes.
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
