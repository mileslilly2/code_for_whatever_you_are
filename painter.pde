

JSONArray strokes;
PImage   brushTex;        // optional 64×64 PNG with soft edges
int      idx       = 0;
int      total;
boolean  playing   = true;
int      delayMs   = 1;   // controls speed


boolean  recording = false;

void setup() {
  size(1000, 1000);
  background(255);
  strokes = loadJSONArray("monet_strokes.json");   // or paint_strokes.json
  total   = strokes.size();
  frameRate(60);


}

void draw() {
  if (playing && idx < total && millis() > delayMs * idx) {
    paintStroke(strokes.getJSONObject(idx));
    idx++;

    if (idx == total) {
      println("✓ Finished replaying " + total + " strokes");
    }


    if (idx == total) {
      recording = false;

      println("✓ GIF saved.");
    }
  }
}

void paintStroke(JSONObject s) {
  JSONArray pts   = s.getJSONArray("points");
  float     w     = s.getFloat("width");
  JSONArray c     = s.getJSONArray("color");
  float     alpha = s.getFloat("opacity") * 255;

  stroke(c.getInt(0), c.getInt(1), c.getInt(2), alpha);
  strokeWeight(w);
  noFill();

  // ── textured brush? ─────────────────────────────────────
  if (brushTex != null) {
    // stamp texture along the Bézier path every 'w' pixels
    for (float t = 0; t < 1.0; t += w / 60.0) {
      PVector p = bezPoint(pts, t);
      tint(c.getInt(0), c.getInt(1), c.getInt(2), alpha);
      imageMode(CENTER);
      image(brushTex, p.x, p.y, w * 2, w * 2);
    }
  } else {
    beginShape();
    for (int i = 0; i < pts.size(); i++) {
      JSONArray pt = pts.getJSONArray(i);
      vertex(pt.getFloat(0), pt.getFloat(1));
    }
    endShape();
  }
}

PVector bezPoint(JSONArray p, float t) {
  float x = bezierPoint(
              p.getJSONArray(0).getFloat(0),
              p.getJSONArray(1).getFloat(0),
              p.getJSONArray(2).getFloat(0),
              p.getJSONArray(3).getFloat(0),
              t
            );
  float y = bezierPoint(
              p.getJSONArray(0).getFloat(1),
              p.getJSONArray(1).getFloat(1),
              p.getJSONArray(2).getFloat(1),
              p.getJSONArray(3).getFloat(1),
              t
            );
  return new PVector(x, y);
}

void keyPressed() {
  if (key == ' ') {
    playing = !playing;
  }
  if (key == 's' || key == 'S') {
    saveFrame("frame-####.png");
  }
  if (key == '+' && delayMs > 5) {
    delayMs -= 5;
  }
  if (key == '-' && delayMs < 200) {
    delayMs += 5;
  }
}
