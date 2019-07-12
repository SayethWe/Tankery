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

static void createProjectile(float x, float y, float direction, float penetration, float shellVelocity, int damage, float caliber) {
  entities.add(instance.new Projectile(x,y,direction,penetration, shellVelocity,damage,caliber));
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
