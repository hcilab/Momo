class Ball {
	PVector g = new PVector(0, 0.1);
	PVector pos;
	PVector speed;
	int radius;


	Ball(PVector pos, PVector speed) {
		this.pos = pos;
		this.speed = speed;
		this.radius = 20;
	}

	void draw() {
		ellipse(pos.x, pos.y, radius, radius);
	}

	void step() {
		speed.add(g);
		pos.add(speed);
	}

	PVector getCoordinates() {
		return pos;
	}
}
