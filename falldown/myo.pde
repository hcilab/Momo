import de.voidplus.myo.*;
import java.util.HashMap;

Myo myo;
API api;
boolean calibrated;

void setup() {
  size(800, 400);
  background(255);
	frameRate(2);

  myo = new Myo(this);
  myo.withEmg();
	api = new API();
	calibrated = false;
}

void draw() {
  background(255);

	if (!calibrated) {
		calibrate();
		calibrated = true;
	}

	HashMap<String, Float> readings = api.poll();
	println("Out: "+readings.get("OUT")+"\tIn: "+readings.get("IN"));
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
