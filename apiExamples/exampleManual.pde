import de.voidplus.myo.*;
import java.util.HashMap;

/*

// !!! Uncomment and rename to '../MyoFalldown.pde' to run !!!m

int MAX_HEIGHT = 400;
int OUT_SENSOR_ID = 0;
int IN_SENSOR_ID = 5;

Myo myo;
MyoAPI api;

void setup() {
  size(200, 600);
  background(255);
  frameRate(60);

  myo = new Myo(this);
  myo.withEmg();
  api = new MyoAPI();

  api.registerActionManual("OUT", OUT_SENSOR_ID);
  api.registerActionManual("IN", IN_SENSOR_ID);
}

void draw() {
  background(255);

  HashMap<String, Float> readings = api.poll();

  int outHeight = int(MAX_HEIGHT * readings.get("OUT"));
  int inHeight = int(MAX_HEIGHT * readings.get("IN"));

  fill(0); // black
  ellipse(75, 500-outHeight, 20, 20);

  fill(128); // grey
  ellipse(125, 500-inHeight, 20, 20);
}


void myoOnEmg(Myo myo, long nowMicros, int[] data) {
  api.onEmg(nowMicros, data);
}

*/
