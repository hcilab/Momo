PVector g = new PVector(0, 0.1);
PVector pos = new PVector(400, 600);
int speed = 6;

ArrayList<Ball> balls;
Cannon cannon;
Tank tank;
int score;

void setup() {
	size(800, 640);
	frameRate(30);

	balls = new ArrayList<Ball>();
	cannon = new Cannon(400, 600);
	tank = new Tank(int(random(800)), 600);
	score = 0;
}

void draw() {
	background(255); // clear screen

	cannon.draw();
	tank.draw();

	fill(0);
	textSize(32);
	text("Score: "+score, 50, 50);

	for (Ball ball : balls) {
		ball.draw();
		ball.step();
		if (intersects(tank, ball)) {
			tank = new Tank(int(random(800)), 600);
			score += 5;
		}
	}
}

void keyPressed() {
	if (keyCode == ENTER) {
		int angle = cannon.currentAngle();
		float speedX = speed * cos(radians(angle));
		float speedY = speed * sin(radians(angle));
		balls.add(new Ball(pos.copy(), new PVector(speedX, speedY)));
		score -= 1;

	} else if (keyCode == LEFT) {
		cannon.rotate(-5);

	} else if (keyCode == RIGHT) {
		cannon.rotate(5);
	}
}

// a VERY rough approximation (I think box2D will help me with this)
boolean intersects(Tank t, Ball b) {
	PVector t_pos = t.getCoordinates();
	PVector b_pos = b.getCoordinates();

	return abs(t_pos.x-b_pos.x)<25 && abs(t_pos.y-b_pos.y)<25;
}
