import beads.*;
import org.jaudiolibs.beads.*;
import controlP5.*;
import java.util.Arrays;
import java.lang.Math;

ControlP5 p5;

Button pressureCoverage;
Button angle;
Button speed;

Button back;
Button startEventStream;
Button stopEventStream;

Button interact;

Slider hpDemoSlider;

//to use text to speech functionality, copy text_to_speech.pde from this sketch to yours
//example usage below

//IMPORTANT (notice from text_to_speech.pde):
//to use this you must import 'ttslib' into Processing, as this code uses the included FreeTTS library
//e.g. from the Menu Bar select Sketch -> Import Library... -> ttslib

TextToSpeechMaker ttsMaker; 

//<import statements here>

//to use this, copy notification.pde, notification_listener.pde and notification_server.pde from this sketch to yours.
//Example usage below.

//name of a file to load from the data directory
String dataJSON;

NotificationServer notificationServer;
ArrayList<Notification> notifications;

String state;
Boolean interactive;
int time;

PImage toothbrush;
PImage toothbrush2;
PImage mouth;
PImage tooth;
int x;
int y;

boolean timestamp;

//Pressure
SamplePlayer toothBrushSong;
BiquadFilter hpFilter;
Glide demoGlide;

//Coverage
SamplePlayer coverageBeep;
Envelope beepEnvelope;
Gain beepGain;
String currMouthArea;
String prevMouthArea;
int count;
Button frontLeft;
Button frontRight;
Button backLeft;
Button backRight;

//Angle
float prevBaseFrequency;
float baseFrequency;
WavePlayer wpAngle;
Glide angleFG;
Gain angleGain;
Slider angleSlide;
float theta;

//Speed
SamplePlayer toothBrushSong2;
Glide toothBrushGlide;
Gain toothBrushGain;
float volume;
String exampleSpeech;
boolean talking;
Slider speedSlide;

MyNotificationListener myNotificationListener;

void setup() {
  size(800,600);
  p5 = new ControlP5(this);
  
  ac = new AudioContext(); //ac is defined in helper_functions.pde
  
  //this will create WAV files in your data directory from input speech 
  //which you will then need to hook up to SamplePlayer Beads
  ttsMaker = new TextToSpeechMaker();
  
  exampleSpeech = "Brush slower";
  
  //ttsExamplePlayback(exampleSpeech); //see ttsExamplePlayback below for usage
  
  toothbrush = loadImage("toothbrush.png");
  toothbrush2 = loadImage("toothbrush2.png");
  mouth = loadImage("mouth.png");
  tooth = loadImage("tooth.png");

  coverageBeep = getSamplePlayer("beep.wav");
  coverageBeep.pause(true); 
  
  beepEnvelope = new Envelope(ac, 0.0);
  beepGain = new Gain(ac, 1, beepEnvelope);
  
  beepGain.addInput(coverageBeep);
  
  demoGlide = new Glide(ac, 1500.0, 50);
  
  hpFilter = new BiquadFilter(ac, BiquadFilter.HP, demoGlide, 0.5f);
  
  toothBrushSong = getSamplePlayer("toothbrush song.wav");
  toothBrushSong.pause(true); 
  
  toothBrushSong2 = getSamplePlayer("toothbrush song.wav");
  toothBrushSong2.pause(true);
  
  toothBrushGlide = new Glide(ac, 1, 50);
  toothBrushGain = new Gain(ac, 1, toothBrushGlide);
  toothBrushGain.addInput(toothBrushSong2);
  
  hpFilter.addInput(toothBrushSong);
  
  angleFG = new Glide(ac, 440, 50);
  wpAngle = new WavePlayer(ac, angleFG, Buffer.SINE);
  wpAngle.pause(true);
  
  angleGain = new Gain(ac, 1, 0.1);
  angleGain.addInput(wpAngle);
  
  ac.out.addInput(angleGain);
  ac.out.addInput(hpFilter);
  ac.out.addInput(beepGain);
  ac.out.addInput(toothBrushGain);
  
  state = "start";
  timestamp = false;
  
  //START NotificationServer setup
  notificationServer = new NotificationServer();
  
  //instantiating a custom class (seen below) and registering it as a listener to the server
  myNotificationListener = new MyNotificationListener();
  notificationServer.addListener(myNotificationListener);
  
    pressureCoverage = p5.addButton("pressureCoverage")
      .setPosition(150, 300)
      .setSize(100, 50)
      .setLabel("Brushing Pressure \n and Coverage")
      .show();
    
    frontLeft = p5.addButton("frontLeft")
      .setPosition(550, 400)
      .setSize(100, 50)
      .setLabel("Front Left")
      .hide();
      
    frontRight = p5.addButton("frontRight")
      .setPosition(660, 400)
      .setSize(100, 50)
      .setLabel("Front Right")
      .hide();
      
    backLeft = p5.addButton("backLeft")
      .setPosition(550, 460)
      .setSize(100, 50)
      .setLabel("Back Left")
      .hide();
      
    backRight = p5.addButton("backRight")
      .setPosition(660, 460)
      .setSize(100, 50)
      .setLabel("Back Right")
      .hide();
      
    angle = p5.addButton("angle")
      .setPosition(350, 300)
      .setSize(100, 50)
      .setLabel("Brushing Angle")
      .show();
      
    angleSlide = p5.addSlider("angleSlide")
      .setPosition(225, 425)
      .setSize(300, 25)
      .setRange(60, 120)
      .setValue(90)
      .setLabel("Angle")
      .hide();
      
    speed = p5.addButton("speed")
      .setPosition(550, 300)
      .setSize(100, 50)
      .setLabel("Brushing Speed")
      .show();
      
    speedSlide = p5.addSlider("speedSlide")
      .setPosition(100, 200)
      .setSize(600, 150)
      .setLabel("Speed")
      .setRange(0, 10)
      .setValue(4)
      .hide();
      
    interact = p5.addButton("interact") 
      .setPosition(660, 75)
      .setSize(100, 50)
      .setLabel("Interact")
      .hide();
  
    startEventStream = p5.addButton("startEventStream")
      .setPosition(40,20)
      .setSize(150,20)
      .setLabel("Start")
      .hide();
   
    stopEventStream = p5.addButton("stopEventStream")
      .setPosition(40,100)
      .setSize(150,20)
      .setLabel("Stop")
      .hide();
      
    hpDemoSlider = p5.addSlider("demoSlider")
      .setPosition(300,20)
      .setSize(20,200)
      .setRange(1, 5000)
      .setValue(.1)
      .setLabel("Demo Slider")
      .hide();
      
    back = p5.addButton("backButton") 
      .setPosition(50, 500)
      .setSize(100, 40)
      .setLabel("Back")
      .hide();
    
  ac.start();
}

void startEventStream(int value) {
  //loading the event stream, which also starts the timer serving events
  notificationServer.stopEventStream();
  notificationServer.loadEventStream(dataJSON);
}

//void pauseEventStream(int value) {
//  //loading the event stream, which also starts the timer serving events
//  notificationServer.pauseEventStream();
//}

void stopEventStream(int value) {
  //loading the event stream, which also starts the timer serving events
  notificationServer.stopEventStream();
}

void demoSlider(int value) {
  demoGlide.setValue(value);  
}

void pressureCoverage() {
  dataJSON = "brushing_pressure_coverage.json";
  x = 385;
  y = 200;
  interactive = false;
  time = 0;
  notificationServer.stopEventStream(); //always call this before loading a new stream
  notificationServer.loadEventStream(dataJSON);
  state = "pressureCoverage";
  //println("**** New event stream loaded: " + dataJSON + " ****");
}

void frontLeft() {
  currMouthArea = "front left";
}

void frontRight() {
  currMouthArea = "front right";
}

void backLeft() {
  currMouthArea = "back left";
}

void backRight() {
  currMouthArea = "back right";
}

void angle() {
  baseFrequency = 440;
  theta = PI;
  x = 425;
  y = 240;
  interactive = false;
  wpAngle.pause(false);
  dataJSON = "brushing_angle.json";
  notificationServer.stopEventStream(); //always call this before loading a new stream
  notificationServer.loadEventStream(dataJSON);
  state = "angle";
}

void angleSlide(int value) {
  angleFG.setValue(440 - 90 + value);
  baseFrequency = 440 - 90 + value;
}

void speed() {
  dataJSON = "brushing_speed.json";
  volume = 1;
  x = 0;
  y = 0;
  talking = false;
  notificationServer.stopEventStream(); //always call this before loading a new stream
  notificationServer.loadEventStream(dataJSON);
  state = "speed";
}

void interact() {
  if (state == "pressureCoverage") {
    notificationServer.stopEventStream();
    interactive = true;
    currMouthArea = "front right";
    toothBrushSong.pause(true);
    toothBrushSong.setToLoopStart();
    notificationServer.loadEventStream(dataJSON);
  } else if (state == "angle") {
    notificationServer.stopEventStream();
    interactive = true;
    baseFrequency = 440;
    theta = PI;
    x = 425;
    y = 240;
    notificationServer.loadEventStream(dataJSON);
  }
}

void backButton() {
  notificationServer.stopEventStream();
  state = "start";
  toothBrushSong.pause(true);
  toothBrushSong.setToLoopStart();
  wpAngle.pause(true);
  toothBrushSong2.pause(true);
  toothBrushSong2.setToLoopStart();
}

void timestamp() {
  timestamp = true;
}

void draw() {
  background(100);
  //this method must be present (even if empty) to process events such as keyPressed() 
  if (state == "pressureCoverage") {
    pressureCoverage.hide();
    angle.hide();
    speed.hide();
    //hpDemoSlider.show();
    interact.show();
    back.show();
    
    if (interactive) {
      frontLeft.show();
      frontRight.show();
      backLeft.show();
      backRight.show();
    }
    
    textSize(32);
    text("Brushing Pressure and Coverage", 150, 100);
    
    image(mouth, 190, 80);
    noFill();
    stroke(255, 255, 255);
    rect(x, y, 100, 100);
  } else if (state == "angle") {
    pressureCoverage.hide();
    angle.hide();
    speed.hide();
    
    translate(x, y);
    rotate(theta);
    image(toothbrush, 0, 0);
    rotate(-theta);
    translate(-x, -y);
    
    if (interactive) {
      angleSlide.show();
    }
    
    interact.show();
    
    back.show();
    image(tooth, 240, 170);
    textSize(32);
    text("Brushing Angle", 270, 100);
  } else if (state == "speed") {
    pressureCoverage.hide();
    angle.hide();
    speed.hide();
    speedSlide.show();
    back.show();
    
    textSize(32);
    text("Brushing Speed", 280, 100);
  } else if (state == "start") {
    pressureCoverage.show();
    angle.show();
    speed.show();
    frontLeft.hide();
    frontRight.hide();
    backLeft.hide();
    backRight.hide();
    angleSlide.hide();
    speedSlide.hide();
    startEventStream.hide();
    stopEventStream.hide();
    hpDemoSlider.hide();
    interact.hide();
    back.hide();
    
    image(toothbrush2, 240, 0);
    textSize(32);
    text("Audio Toothbrush Simulator", 180, 240);
  }
}

void keyPressed() {
  //example of stopping the current event stream and loading the second one
  if (state == "start") {
    if (key == '1') {
      pressureCoverage();
      println("**** New event stream loaded: " + dataJSON + " ****");
    } else if (key == '2') {
      angle();
    } else if (key == '3') {
      speed();
    }
  }
  
  if (state != "start") {
    if (key == 'b') {
      backButton();
    } else if (key == 't') {
      timestamp();
    }
  }
}

//in your own custom class, you will implement the NotificationListener interface 
//(with the notificationReceived() method) to receive Notification events as they come in
class MyNotificationListener implements NotificationListener {
  
  public MyNotificationListener() {
    //setup here
  }
  
  //this method must be implemented to receive notifications
  public void notificationReceived(Notification notification) { 
    //println("<Example> " + notification.getType().toString() + " notification received at " 
    //+ Integer.toString(notification.getTimestamp()) + " ms");
    
    String debugOutput = ">>> ";
    switch (notification.getType()) {
      case Pressure:
        //debugOutput += "Pressure applied: ";
        //toothBrushSong.setToLoopStart();
        toothBrushSong.start();
        if (notification.getPressure() > 60) {
          demoGlide.setValue((notification.getPressure() - 60) * 125);
        } else {
          demoGlide.setValue(1.0);
        }
       
        break;
      case Coverage:
        if (!interactive) {
          if (notification.getCurrX() >= 0 && notification.getCurrY() >= 0) {
            currMouthArea = "front right";
          } else if (notification.getCurrX() >= 0 && notification.getCurrY() <= 0) {
            currMouthArea = "back right";
          } else if (notification.getCurrX() <= 0 && notification.getCurrY() >= 0) {
            currMouthArea = "front left";
          } else if (notification.getCurrX() <= 0 && notification.getCurrY() <= 0) {
            currMouthArea = "back left";
          }
        }
        
        if (currMouthArea == "front right") {
            x = 385;
            y = 200;
        } else if (currMouthArea == "back right") {
            x = 405;
            y = 275;
        } else if (currMouthArea == "front left") {
            x = 280;
            y = 200;
        } else if (currMouthArea == "back left") {
            x = 260;
            y = 275;
        }
        
        //println("MOUTH AREA: " + currMouthArea);
        //debugOutput += "Coverage data: ";
        
        if (currMouthArea == prevMouthArea) {
          time += 500;
          count++;
        } else {
          time = 0;
          count = 0;
        }
        
        if (currMouthArea == prevMouthArea && time > 2000) {
          //beep less
          if (count % 2 == 0) {
            break;
          } else if (count > 8 && count % 3 != 0) {
              break;
          } else {
            coverageBeep.setToLoopStart();
            coverageBeep.start();
            beepEnvelope.addSegment(0.8, 50);
            beepEnvelope.addSegment(0.0, 300); 
          }
        } else {
          coverageBeep.setToLoopStart();
          coverageBeep.start();
          beepEnvelope.addSegment(0.8, 50);
          beepEnvelope.addSegment(0.0, 300); 
        }
        
        prevMouthArea = currMouthArea;
        
        if (timestamp) {
          println("Timestamp: " + notification.getTimestamp());
          timestamp = false;
        }
        break;
      case Angle:
        debugOutput += "Brushing angle: " + notification.getAngle();
        
        if (!interactive) {
          if (Math.abs(notification.getAngle() - 90) > 20) {
            if (baseFrequency < 540) {
              baseFrequency += (notification.getAngle() - 90);
              if (notification.getAngle() - 90 > 0) {
                theta += PI / 16;
                x += 10;
              } else {
                theta -= PI / 16;
                x -= 22;
              }
              
              y += 5;
            }
          } else {
            baseFrequency = 440;
            x = 425;
            y = 240;
            theta = PI;
          }
        } else {
          if (Math.abs(baseFrequency - 440) > 20) {
            if (baseFrequency - 440 > 0 && theta < PI + PI / 4) {
              theta += PI / 16;
              x += 10;
            } else if (baseFrequency - 440 < 0 && theta > 3 * PI / 4) {
              theta -= PI / 16;
              x -= 22;
            }
            
            if (theta < PI + PI / 4 && theta > 3 * PI / 4) {
              y += 5;
            }
          } else {
            baseFrequency = 440;
            x = 425;
            y = 240;
            theta = PI;
          }
        }
        
        angleFG.setValue(baseFrequency);
        
        prevBaseFrequency = baseFrequency;
        
        if (timestamp) {
          println("Timestamp: " + notification.getTimestamp());
          timestamp = false;
        }
        break;
      case Speed:
        debugOutput += "Brushing Speed: ";
        
        toothBrushSong2.start();
        
        if (notification.getSpeed() > 5) {
          volume += 0.6;
        } else if (notification.getSpeed() <= 5 && volume > 1) {
          volume -= 0.4;
        }
        
        if (volume < 1) {
          talking = false;
          volume = 1;
        }
        
        if (volume > 4 && !talking) {
          talking = true;
          volume = .5;
          ttsExamplePlayback(exampleSpeech);
        }
        
        speedSlide.setValue(notification.getSpeed());
        toothBrushGlide.setValue(volume);
        
        if (timestamp) {
          println("Timestamp: " + notification.getTimestamp());
          timestamp = false;
        }
        
        println(volume);
        break;
    }
    debugOutput += notification.toString();
    //debugOutput += notification.getLocation() + ", " + notification.getTag();
    
    //println(debugOutput);
    
   //You can experiment with the timing by altering the timestamp values (in ms) in the exampleData.json file
    //(located in the data directory)
  }
}

void ttsExamplePlayback(String inputSpeech) {
  //create TTS file and play it back immediately
  //the SamplePlayer will remove itself when it is finished in this case
  
  String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
  println("File created at " + ttsFilePath);
  
  //createTTSWavFile makes a new WAV file of name ttsX.wav, where X is a unique integer
  //it returns the path relative to the sketch's data directory to the wav file
  
  //see helper_functions.pde for actual loading of the WAV file into a SamplePlayer
  
  SamplePlayer sp = getSamplePlayer(ttsFilePath, true); 
  //true means it will delete itself when it is finished playing
  //you may or may not want this behavior!
  
  ac.out.addInput(sp);
  sp.setToLoopStart();
  sp.start();
  println("TTS: " + inputSpeech);
}
