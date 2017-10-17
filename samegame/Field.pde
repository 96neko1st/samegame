import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

public class Field {
  private int rows, cols;  // フィールドの駒の数（縦、横）
  private int rowsOrg, colsOrg;
  private Piece[] pieces;  // 駒データ
  private int pieceSize;  // 駒のサイズ
  private int posX, posY;  // 駒の表示開始位置
  private int[][] data;  //  フィールドの駒の状態
  private boolean[][] connection;  //  駒の接続関係
  public static final int fieldWidth = 400;  // フィールドの幅
  public static final int fieldHeight = 400;  // フィールドの高さ
  private Minim minim;  // 音楽再生用
  private AudioPlayer seClick;  // クリック時の音
  private AudioPlayer seBGM, seGameOver, seClear;
  private boolean playedGameOver, playedClear;
  private PImage imgBackground;  // 背景画像
  private int score;  // スコア
  private PImage[] imgScore;  // スコア用画像
  private boolean flagCleared, flagGameOver;  // フラグ（クリア、ゲームオーバー）
  private PImage imgCleared, imgGameOver;

  // コンストラクタ
  // w: 横方向の駒の数
  // h: 縦方向の駒の数
  // ps: 駒データ
  // minim: 音楽再生用  
  public Field(int w, int h, Piece[] ps, Minim minim)
  {
    // 音データ読み込み
    this.minim = minim;
    seClick = this.minim.loadFile("click.mp3");
    seBGM = this.minim.loadFile("bgm.mp3", 4096);
    seBGM.setGain(-20.f);    
    seClear = this.minim.loadFile("clear.mp3");
    seGameOver = this.minim.loadFile("gameover.mp3");

    // 各種変数の初期化  
    rowsOrg = w;
    colsOrg = h;
    pieces = ps;
    posX = 0;
    posY = 0;
    pieceSize = ps[0].getSize();

    // 背景画像データ読み込み
    imgBackground = loadImage("background.png");

    // スコア用の数字画像データ読み込み
    imgScore = new PImage[10];
    for (int i=0; i<=9; i++) {
      imgScore[i] = loadImage(i + ".png");
    }

    // クリア時の画像データ読み込み
    imgCleared = loadImage("clear.png");
    // ゲームオーバー時の画像データ読み込み
    imgGameOver = loadImage("gameover.png");

    // 駒の配置
    create();
  }

  // 駒の配置
  public void create() {
    if (seClear.isPlaying()) {
      seClear.rewind();
      seClear.pause();
    }
    if (seGameOver.isPlaying()) {
      seGameOver.rewind();
      seGameOver.pause();
    }

    seBGM.unmute();

    flagCleared = false;
    flagGameOver = false;
    playedClear = false;
    playedGameOver = false;
    score = 0;
    rows = rowsOrg;
    cols = colsOrg;

    data = new int[rows][cols];
    connection = new boolean[rows][cols];
    
  }

  // 駒の表示開始位置の設定
  // x, y: 開始位置
  public void setPos(int x, int y) {
    posX = x;
    posY = y;
  }

  // クリアーしたかどうかの状態を得る
  public boolean isCleared() {
    return flagCleared;
  }

  // ゲームオーバーかどうかの状態を得る
  public boolean isGameOver() {
    return flagGameOver;
  }

  // 画面の座標からフィールドのX座標を得る
  private int convertScreenToFieldPosX(int x) {
    if (x < posX || x >= cols * pieceSize + posX) return -1;
    return (x - posX) / pieceSize;
  }

  // 画面の座標からフィールドのY座標を得る
  private int convertScreenToFieldPosY(int y) {
    if (y < posY || y >= rows * pieceSize + posY) return -1;
    return (y - posY) / pieceSize;
  }

  // 駒の接続関係をリセットする
  private void clearConnectivity() {
    for (int y=0; y<rows; y++) {
      for (int x=0; x<cols; x++) {
        connection[y][x] = false;
      }
    }
  }

  // 駒の連結数を調べる
  // type: 駒の種類
  // x, y: 調べる座標
  // 戻り値: 連結数
  private int getConnectivity(int type, int x, int y) {
    int count = 0;

    if (data[y][x] != type) return 0;
    if (connection[y][x]) return 0;

    connection[y][x] = true;
    count++;

    if (x > 0)
      count += getConnectivity(type, x-1, y);
    if (y > 0)
      count += getConnectivity(type, x, y-1);
    if (x < cols - 1)
      count += getConnectivity(type, x+1, y);
    if (y < rows - 1)
      count += getConnectivity(type, x, y+1);

    return count;
  }

  // 隣り合う駒が同じ色か調べる
  // x, y: 調べたい駒の座標
  // 戻り値: true=同じ色, false=違う色
  private boolean isExistNeighbor(int x, int y) {
    return x > 0 && data[y][x] == data[y][x-1]
      || x < cols - 1 && data[y][x] == data[y][x+1]
      || y > 0 && data[y][x] == data[y-1][x]
      || y < rows - 1 && data[y][x] == data[y+1][x];
  }

  // ゲームオーバーかどうか調べる
  // 戻り値: 0=消せる駒がある, 1=クリア, 2=ゲームオーバー
  private int checkGameOver() {
    if (cols == 0)
      return 1;
    for (int y=0; y<rows; y++) {
      for (int x=0; x<cols; x++) {
        if (data[y][x] != -1 && isExistNeighbor(x, y))
          return 0;
      }
    }
    return 2;
  }

  // 描画
  public void draw() {
    if (!seBGM.isPlaying()) {
      seBGM.loop();
    }

    // 背景画像を表示
    image(imgBackground, imgBackground.width/2, imgBackground.height/2);

    // 駒を順番に表示する
    int px, py;
    for (int y=0; y<rows; y++) {
      py = posY + y * pieceSize;
      px = posX;
      for (int x=0; x<cols; x++) {
        if (data[y][x] != -1)
          pieces[data[y][x]].draw(px, py, connection[y][x]);
        px += pieceSize;  // 次の駒へ
      }
    }

    drawScore();

    // ゲームオーバー時の画像表示
    if (isGameOver()) {
      seBGM.mute();
      if (isCleared()) {  // クリアー
        if (!seClear.isPlaying() && !playedClear) {
          seClear.play();
          playedClear = true;
        }
        image(imgCleared, width / 2, height / 2);
      }
      else {   // ゲームオーバー
        if (!seGameOver.isPlaying() && !playedGameOver) {
          seGameOver.play();
          playedGameOver = true;
        }
        image(imgGameOver, width / 2, height / 2);
      }
    }
  }

  // スコアを描画する
  private void drawScore() {
    int x = 552;  // 1桁目の開始座標
    int s = score;

    // 1の位から順に描画していく
    for (int i=0; i<5; i++) {
      // スコアを10で割った余りに対応する数字の画像を表示
      image(imgScore[s % 10], x, 108);
      s /= 10;  // 10で割って、表示した1桁目を捨てる
      x -= 24;  // 次の数字を表示する座標に更新
    }
  }

  // 駒の接続関係を更新する
  // mx, my: 調べる座標（スクリーン座標）
  public void updateConnectivity(int mx, int my) {
    clearConnectivity();

    int result = checkGameOver();
    if (1 == result) {
      // クリアー
      flagCleared = true;
      flagGameOver = true;
      return;
    } 
    else if (2 == result) {
      // ゲームオーバー
      flagCleared = false;
      flagGameOver = true;
      return;
    }

    // スクリーン座標からフィールド上の座標に変換する
    int x = convertScreenToFieldPosX(mx);
    int y = convertScreenToFieldPosY(my);
    if (x == -1 || y == -1)  // 駒が無い部分にカーソルがあると処理を中断
      return;

    int count = 0;

    // フィールド上に駒があれば、接続関係を調べる
    if (data[y][x] != -1)
      count = getConnectivity(data[y][x], x, y);

    // 連結数が2未満の場合、接続関係をリセット
    if (count < 2)
      clearConnectivity();
  }

  // 駒を消す
  public boolean removePiece() {
    int count = 0;

    // 接続関係がある部分のデータに-1を入れて駒を消す
    for (int y=0; y<rows; y++) {
      for (int x=0; x<cols; x++) {
        if (connection[y][x] == true) {
          connection[y][x] = false;
          data[y][x] = -1;
          count++;
        }
      }
    }

    if (count > 0) {
      // クリック音を再生
      if (seClick.isPlaying()) {
        seClick.pause();
      }
      seClick.rewind();
      seClick.play();

      // スコア計算: (消した数-2)の2乗
      score += pow(count-2, 2);
    }

    return count > 0;
  }

  // 駒を消した空きスペースに上の駒を詰めて落とす
  public void dropPiece() {
    int begin;
    for (int x=0; x<cols; x++) {
      begin = -1;
      for (int y=rows-1; y>=0; y--) {
        if (data[y][x] == -1) {
          if (begin == -1) {
            begin = y;
          }
        }
        else {
          if (begin != -1) {
            dropPiece2(x, begin, y);
            y += begin - y + 1;
            begin = -1;
          }
        }
      }
    }
  }

  // 
  private void dropPiece2(int x, int begin, int end) {
    int dy = begin;
    for (int y=end; y>=0; y--) {
      data[dy][x] = data[y][x];
      dy--;
    }
    for (;dy>=0; dy--) {
      data[dy][x] = -1;
    }
  }

  // 空いてる列を探して列を詰める
  public void shiftLine()
  {
    int begin = -1;
    for (int x=0; x<cols; x++) {
      if (isBlankLine(x)) {
        if (begin == -1) {
          begin = x;
        }
      }
      else {
        if (begin != -1) {
          moveLine(begin, x);
          begin = -1;
          x += begin - x + 1;
        }
      }
    }
    if (begin != -1) {
      cols = begin;
    }
  }

  // 列を移動させる
  // dst: 移動先の列番号
  // src: 移動元の列番号
  private void moveLine(int dst, int src) {
    int dx = dst;
    int sx = src;
    while (sx < cols) {
      for (int y=0; y<rows; y++) {
        data[y][dx] = data[y][sx];
      }
      dx++;
      sx++;
    }
    while (dx < cols) {
      for (int y=0; y<rows; y++) {
        data[y][dx] = -1;
      }
      dx++;
    }
  }

  // 1列左へ詰める
  // target列 ← (target+1)列
  private void moveLine(int target)
  {
    for (int x=target; x<cols-1; x++) {
      for (int y=0; y<rows; y++) {
        data[y][x] = data[y][x+1];
        data[y][x+1] = -1;
      }
    }
  }

  // 指定した列が空白かどうか調べる
  // 戻り値: 空白ならtrue, そうでないならfalse
  private boolean isBlankLine(int x)
  {
    for (int y=0; y<rows; y++) {
      if (data[y][x] != -1) {
        return false;
      }
    }
    return true;
  }

  public void stopSound() {
    seClick.close();
    seBGM.close();
    seClear.close();
    seGameOver.close();
  }
}