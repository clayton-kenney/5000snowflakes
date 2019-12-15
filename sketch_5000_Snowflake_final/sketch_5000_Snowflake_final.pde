// Original Code based off of Coding train challenge #88, by Daniel Shiffman
// thecodingtrain.com/CodingChallenges/088-snowfall.html
// Modified by Clayton Kenney, Nov 2019. 

import com.hamoid.*; //Video Export library

ArrayList<Snowflake> snow; //array that holds the snowflakes
PVector gravity; //gravity global variable
float angle; //angle global variable
int t; //time global variable
VideoExport videoExport; //Initialize video export library
int frameRate = 30; //set framerate, 60fps for final export
boolean render = false; //render variable, set to false if testing
float wind; //wind varible, didn't end up using.

//generates random number using randomGaussian function. Scaled to deliver appropriate size flakes. Change depending on render size. 
float getRandomSize() {
  float r3 = randomGaussian() * 3 + 5;
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
    
    
    Snowflake(float x, float y) {
        float xv = random(-.5, .5); //assign random horizontal vector left or right
        pos = new PVector(x, y); //position vector
        vel = new PVector(xv, 0); //initial velocity vector
        acc = new PVector(); //acceleration vector
        r = getRandomSize();  //snowflake size based on above rando algo
        radius = sqrt(random(pow(width / 2, 2)));  //define radius for lateral movement of the snowflake
        initialAngle = random(0, 2 * PI); //generate random starting angle between 0 & 2PI
        wind = 0;
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
        vel.limit(r * .3); //gravity limit .2-.5 depening on size of flake. to account for wind resistance
        pos.add(vel);
        acc.mult(0);
        
        //horizontal movement, updates x position every frame, based on https://p5js.org/examples/simulate-snowflakes.html
        float w = 0.003; // angular speed, .003 is greate for full resolution
        float angle = w * t + initialAngle;
        pos.x = width/ 2 + radius * sin(angle);

        if (pos.y > height + r) {  //if snowflake passes bottom of screen, pos.y, run randomize and move back to top offscreen
          randomize();
        }
        
    }
    void render() {  //render the snowflake
        stroke(255); //255 for white
        strokeWeight(r);
        point(pos.x, pos.y);
    }
}
void setup() {
    size(1080, 3438); //1080x3438 full res, 270x860 1/4 scale
    
    //EXPORT SETTING, no export if render is set to false
    if (render) { 
    videoExport = new VideoExport(this, "3000.mp4");  //change the file name here
    videoExport.setQuality(100, 128);  //quality settings, (Video, Audio)
    videoExport.setFrameRate(frameRate);
    }
    frameRate(frameRate);
    
    gravity = new PVector(0, 1); //define gravity
    
    //Make snowflakes and add them in the Snow Arraylist
    snow = new ArrayList<Snowflake>(); 
    for (int i=0; i < 3000; i++) {  //change number of snowflakes here. 3000 & 5000 look best on projection
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
    background(1); //black background
    t = frameCount; //set the time, used for horizontal movement updates

    // LOOP THROUGH ARRAYLIST AND RENDER, APPLY GRAVITY, AND UPDATE POSITION
    for(int i =0; i< snow.size(); i++){ 
      Snowflake flake = snow.get(i);
      flake.applyForce(gravity);
      flake.update();
      flake.render(); 
    }
    
    //Renderer Save function
     if (render) {   
      videoExport.saveFrame();
     }
}

//End render/sketch if Q is pressed
void keyPressed() {
  if (key == 'q') {
    videoExport.endMovie();
    exit();
  }
}
