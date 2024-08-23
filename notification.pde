enum NotificationType {Pressure, Coverage, Angle, Speed}

class Notification {
   
  int timestamp;
  NotificationType type; 
  String flag;
  int priority;
  
  float pressure;

  float currX;
  float currY;
  
  float angle;
  
  float speed;
  
  public Notification(JSONObject json) {
    this.timestamp = json.getInt("timestamp");
    //time in milliseconds for playback from sketch start
    
    String typeString = json.getString("type");
    
    try {
      this.type = NotificationType.valueOf(typeString);
    }
    catch (IllegalArgumentException e) {
      throw new RuntimeException(typeString + " is not a valid value for enum NotificationType.");
    }
    
    if (json.isNull("pressure")) {
      this.pressure = 0;
    }
    else {
      this.pressure = json.getFloat("pressure");
    }
    
    if (json.isNull("currX")) {
      this.currX = 0;
    }
    else {
      this.currX = json.getFloat("currX");      
    }
    
    if (json.isNull("currY")) {
      this.currY = 0;
    }
    else {
      this.currY = json.getFloat("currY");      
    }
    
    if (json.isNull("angle")) {
      this.angle = 0;
    }
    else {
      this.angle = json.getFloat("angle");      
    }
    
    if (json.isNull("speed")) {
      this.speed = 0;
    }
    else {
      this.speed = json.getFloat("speed");      
    }
    
    if (json.isNull("flag")) {
      this.flag = "";
    }
    else {
      this.flag = json.getString("flag");      
    }
    
    this.priority = json.getInt("priority");
    //1-3 levels (1 is highest, 3 is lowest)    
  }
  
  public int getTimestamp() { return timestamp; }
  public NotificationType getType() { return type; }
  public String getFlag() { return flag; }
  public int getPriorityLevel() { return priority; }
  public float getPressure() { return pressure; }
  public float getCurrX() { return currX; }
  public float getCurrY() { return currY; }
  public float getAngle() { return angle; }
  public float getSpeed() { return speed; }
  
  public String toString() {
      String output = getType().toString() + ": ";
      //output += "(location: " + getLocation() + ") ";
      //output += "(tag: " + getTag() + ") ";
      output += "(flag: " + getFlag() + ") ";
      output += "(priority: " + getPriorityLevel() + ") ";
      //output += "(note: " + getNote() + ") ";
      return output;
    }
}
