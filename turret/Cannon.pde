class Cannon {
	int x;
	int y;
	int length;
	int angle;

	Cannon(int x, int y) {
		this.x = x;
		this.y = y;
		this.length = 30;
		this.angle = 270;
	}

	void draw() {
		float deltaX = length*cos(radians(angle));
		float deltaY = length*sin(radians(angle));
		line(x, y, x+deltaX, y+deltaY);
	}

	void rotate(int degree) {
		angle += degree;
	}

	int currentAngle() {
		return angle;
	}
}
