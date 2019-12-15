// Original Code based off of Coding train challenge #88, by Daniel Shiffman
// thecodingtrain.com/CodingChallenges/088-snowfall.html
// Modied by Clayton Kenney, Nov 2019. 

import com.hamoid.*;

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// The kinect stuff is happening in another class
KinectTracker tracker;
Kinect kinect;

ArrayList<Snowflake> snow; //array that holds the snowflakes
PVector gravity; //gravity global variable
float angle; //angle global variable
int t; //time global variable
VideoExport videoExport;
int frameRate = 30;
boolean render = false;
float xOff;



//generates random that skews smaller by comapring random numbers. add one to ensure flakes aren't too small
float getRandomSize() {
  float r3 = randomGaussian() * 2 + 5;
  return constrain(abs(r3), 3, 100);
}
    
//snowflake constructor
class Snowflake {
    
    PVector pos;
    PVector vel;
    PVector acc;
    float r;
    float radius;
    float initialAngle;
    
    
    Snowflake(float x1, float y1) {
        float x = x1;   //starting point of flake based on width
        float y = y1;   //generate flakes offscreen so they are falling 
        float xv = random(-.5, .5); //assign random horizontal vector on creation
        pos = new PVector(x, y); //position vector
        vel = new PVector(xv, 0); //initial velocity vector
        acc = new PVector(); //acceleration vector
        r = getRandomSize();  //snowflake size based on above rando algo
        radius = sqrt(random(pow(width / 2, 2)));
        initialAngle = random(0, 2 * PI); //generate random starting angle between 0 & 2PI
        xOff = 0;
    }
    
    void applyForce(PVector force){
        //faux parallax effect
        PVector f = force.copy();
        f.mult(r); //gravity acts more on 'bigger' aka heavier particles
        acc.add(f); //gravity force to accelerator 
        
    }
    void randomize() {
      float x = random(width);
      float y = random(-100, -10);
      float xv = random(0); //assign random horizontal vector on creation
      pos = new PVector(x, y);
      vel = new PVector(xv, 0); //initial velocity vector
      acc = new PVector(); //acceleration vector
      initialAngle = random(0, 2 * PI); //generate random starting angle between 0 & 2PI
      r = getRandomSize();  //snowflake size based on above rando algo
      
    }
    void update() {
        vel.add(acc);
        vel.limit(r * .35); //gravity limit .2-.5
        pos.add(vel);
        acc.mult(0);
        
        /*
        //commented out for now
        float w = 0.002; // angular speed
        float angle = w * t + initialAngle;
        pos.x = width/ 2 + radius * sin(angle);
       */
        
        if (pos.y > height + r) {
          randomize();
        }
        
    }
    void offsetR() {
      acc.x += random(100, 200);
    }
    void offsetL() {
      acc.x -= (random(100, 200));
    } 
    void render() {
        stroke(255);
        strokeWeight(r);
        point(pos.x, pos.y);
    }
}
void setup() {
    //const canvas = createCanvas(1080, 3438); //canvas is 1/4 scale of tower, set to canvas variable
    fullScreen(); //1080x3438 full res, 270x860 1/4 scale
    kinect = new Kinect(this);
    tracker = new KinectTracker();
    
    if (render) {
    videoExport = new VideoExport(this, "3000.mp4");
    videoExport.setQuality(100, 128);
    videoExport.setFrameRate(frameRate);
    }
    frameRate(frameRate);
    
    gravity = new PVector(0, 1); //define gravity
    snow = new ArrayList<Snowflake>();
    for (int i=0; i < 2000; i++) {
      float x = random(width);
      float y = random(height);
      snow.add(new Snowflake(x, y));
    }
    
    //no export if render is set to false
    if (render) {
    videoExport.startMovie();
    }

}
void draw(){
    background(1); //black for test
    t = frameCount; //set the time

    // Run the tracking analysis
  tracker.track();
  // Show the image
  tracker.display();

  // Let's draw the raw location
  PVector v1 = tracker.getPos();
  float vx1 = map(v1.x, 0, 640, 0, 1280);
  float vy1 = map(v1.y, 0, 480, 0, 680);
  fill(0, 0, 0, 200);
  stroke(255, 0, 0);
  strokeWeight(.5);
  ellipse(vx1, vy1, 175, 200);

  // Display some info
  noStroke();
  int t = tracker.getThreshold();
  fill(255);
  textSize(10);
  text("threshold: " + t + "    " + int(frameRate) + "    " + 
    "UP increase threshold, DOWN decrease threshold", 10, 710);
   textSize(100);
    fill(40);
    text("LET", 100, 200);
    text("IT", 400, 550);  
    text("SNOW", 900, 400);  
    
    
    //Make Snow Flakes!!
    
    for(int i =0; i< snow.size(); i++){ 
      Snowflake flake = snow.get(i);
      flake.applyForce(gravity);
      flake.update();
      flake.render(); 
      if (flake.pos.x > vx1 && flake.pos.x < vx1 + 110 && flake.pos.y > vy1 - 100 && flake.pos.y < vy1 + 100){
        flake.offsetR();
        //flake.pos.x += 200;  
        //flake.vel.x += random(200, 300);
        }
        if (flake.pos.x < vx1 && flake.pos.x > vx1 - 110 && flake.pos.y > vy1 - 100 && flake.pos.y < vy1 + 100){
          flake.offsetL();
          //flake.pos.x -= 200; 
          // flake.vel.x -= random(200, 300);

        }
      }
    
    
    //Renderer
     if (render) {   
      videoExport.saveFrame();
     }
     noStroke();
     fill(150);
}

void keyPressed() {
  if (key == 'q') {
    videoExport.endMovie();
    exit();
  }
  int t = tracker.getThreshold();
  if (key == CODED) {
    if (keyCode == UP) {
      t+=5;
      tracker.setThreshold(t);
    } else if (keyCode == DOWN) {
      t-=5;
      tracker.setThreshold(t);
    }
  }
}
