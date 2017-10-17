// フィールド
Field field;
// 駒の種類
Piece[] pieces;
// 駒のサイズ
int pieceSize = 40;


ServerClient sc;
Minim minim;

// 初期化関数
void setup() {
  size(1150, 500);  // 600x500のウィンドウを表示
  frameRate(60);  // 画面の更新間隔(60fps)

  imageMode(CENTER);
  PFont myFont = loadFont("MS-PGothic-48.vlw");
  textFont(myFont);

  minim = new Minim(this);
  sc = new ServerClient(this);

  // 駒データの定義
  pieces = new Piece[6];   // 駒を2つ作る
  // 駒0の定義
  pieces[0] = new ImagePiece(pieceSize, "piece0.png");
  // 駒1の定義
  pieces[1] = new ImagePiece(pieceSize, "piece1.png");
  // 駒1の定義
  pieces[2] = new ImagePiece(pieceSize, "piece2.png");
  // 駒1の定義
  pieces[3] = new ImagePiece(pieceSize, "piece3.png");
  // 駒1の定義
  pieces[4] = new ImagePiece(pieceSize, "piece4.png");
  // 駒1の定義
  pieces[5] = new ImagePiece(pieceSize, "piece5.png");

  // 駒のサイズに応じてフィールド上に配置できる駒の数を決める
  int cols = Field.fieldWidth / pieceSize;
  int rows = Field.fieldHeight / pieceSize;

  // フィールドを作成
  field = new Field(cols, rows, pieces, minim);
  // フィールドの表示位置（左上座標）を設定
  field.setPos(16, 27);
}

// 描画関数
void draw() {
  // 黒で塗りつぶす
  background(0, 0, 0);

  field.draw();
  sc.receivePacket();

  if (!field.isGameOver()) {
    for (int i=0; i<pieces.length; i++) {
      if (pieces[i] instanceof ImagePiece)
        ((ImagePiece)pieces[i]).updateSwing();
    }
  }
}

// マウスカーソルが動いたときに呼び出される
void mouseMoved() {
  if (!field.isGameOver())
    field.updateConnectivity(mouseX, mouseY);
}

// マウスボタンが押されたときに呼び出される
void mousePressed() {
  if (field.isGameOver()) {
    field.create();
    return;
  }
}

// サウンド関連の終了処理
void stop() {
  field.stopSound();
  minim.stop();
  super.stop();
}