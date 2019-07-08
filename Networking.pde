import processing.net.Server;

static final int DEFAULT_PORT = 21006;

class TankeryServer extends Server {
  
  public TankeryServer() {
    super(instance,DEFAULT_PORT);
  }
  
}

class TankeryClient extends Client {
  public TankeryClient (String host) {
    super(instance,DEFAULT_PORT,host);
  }
  
  public TankeryClient() {
   this("localhost"); 
  }
}
