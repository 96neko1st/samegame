public class Piece {
  private int pieceSize, pieceSize2;

  protected Piece(int s) {
    pieceSize = s;
    pieceSize2 = s / 2;
  }

  public void setSize(int s) {
    pieceSize = s;
    pieceSize2 = s / 2;
  }

  public int getSize() {
    return pieceSize;
  }

  public int getSize2() {
    return pieceSize2;
  }

  public void draw(int x, int y, boolean hilight) {
    if (hilight) {
      drawHilight(x, y);
    }
  }

  public void drawHilight(int x, int y) {
    fill(127);
    rect(x, y, pieceSize, pieceSize);
  }
};

// 円形の駒
public class CirclePiece extends Piece {
  private color col;

  public CirclePiece(int diameter, color col) {
    super(diameter);
    this.col = col;
  }

  public void draw(int x, int y, boolean hilight) {
    super.draw(x, y, hilight);
    fill(col);
    ellipse(x + getSize2(), y + getSize2(), getSize(), getSize());
  }
};

// 画像の駒
public class ImagePiece extends Piece {
  private PImage img;
  private float angle = 0.0f;
  public ImagePiece(int s, String filename) {
    super(s);
    img = loadImage(filename);
  }

  public void resetSwing() {
    angle = 0.0;
  }

  public void updateSwing() {
    angle += 0.1;
  }

  public void draw(int x, int y, boolean hilight) {
    pushMatrix();
    translate(x+getSize2(), y+getSize2());
    if (hilight)
      rotate(sin(angle) * 0.35);
    image(img, 0, 0, getSize(), getSize());
    popMatrix();
  }
};