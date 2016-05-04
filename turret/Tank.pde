class Tank {

	PVector pos;

	Tank(int x, int y) {
		pos = new PVector(x, y);
	}

	void draw() {
		rect(pos.x, pos.y, 20, 20);
	}

	PVector getCoordinates() {
		return pos;
	}
}
