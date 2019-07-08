import processing.net.Server;
import processing.net.Client;

static final int DEFAULT_PORT = 21006;

class TankeryServer extends Server {
  
  public TankeryServer() {
    super(instance,DEFAULT_PORT);
  }
  
}

class TankeryClient extends Client {
  public TankeryClient (String host) {
    super(instance,host,DEFAULT_PORT);
  }
  
  public TankeryClient() {
   this("localhost"); 
  }
}
