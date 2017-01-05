import de.voidplus.myo.*;
import java.util.HashMap;

/*

// !!! Uncomment and rename to '../MyoFalldown.pde' to run !!!

int MAX_HEIGHT = 400;

Myo myo;
MyoAPI api;
boolean calibrated;

void setup() {
  size(200, 600);
  background(255);
  frameRate(60);

  myo = new Myo(this);
  myo.withEmg();
  api = new MyoAPI();
  calibrated = false;
}

void draw() {
  background(255);

  if (!calibrated) {
    calibrate();
    calibrated = true;
  }

  HashMap<String, Float> readings = api.poll();

  int outHeight = int(MAX_HEIGHT * readings.get("OUT"));
  int inHeight = int(MAX_HEIGHT * readings.get("IN"));

  fill(0); // black
  ellipse(75, 500-outHeight, 20, 20);

  fill(128); // grey
  ellipse(125, 500-inHeight, 20, 20);
}

void calibrate() {
  println("Out:");
  api.registerAction("OUT", 5000);
  println("In:");
  api.registerAction("IN", 5000);
}


void myoOnEmg(Myo myo, long nowMicros, int[] data) {
  api.onEmg(nowMicros, data);
}

*/
