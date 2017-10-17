import processing.net.*;
class ServerClient {

  //プレイヤーの人数
  int player_number = 4;
  //現在のプレイヤーを数
  int player_count = 0;
  //プレイヤーのターン
  int current_turn = 0;
  //割り当てるプレイヤーID
  String[] player_id = {"APPLE", "ORANGE", "GRAPE", "CHERRY"};

  Server server;

  ServerClient(samegame_sys name) {
    server = new Server(name, 20000);
  }

  //ClientからのPacketを受け取る
  void receivePacket() {
    Client client = server.available();
    if (client != null) {
      String packet = client.readString();
      String[] inf = packet.split(",", 0);
      checkCommand(inf);
    }
  }

  //Clientから送られたコマンドをチェックする
  void checkCommand(String[] _inf) {
    switch(_inf[0]) {
    case "PLAYER_ID":
      server.write("PLAYER_ID," + player_id[player_count++]);
      break;
    case "FIELD":    /**Field情報をClientに送信する**/
      sendFieldData();
      break;
    case "POS":    /**Clientが選択したPieceを削除する**/
      if (_inf[1].equals(player_id[current_turn])) {
        field.updateConnectivity(int(_inf[2]), int(_inf[3]));
        if (field.removePiece()) { // 駒を消す処理
          // 駒が消されたら、ブロックを落とし、ラインを詰める
          field.dropPiece();
          field.shiftLine();
          print(current_turn);
          current_turn++;
          if (current_turn == player_number) {
            current_turn = 0;
          }
        }
        sendFieldData();
        break;
      }
    }
  }

  //Field情報をClientに送信する
  void sendFieldData() {
    String s = "FIELD";
    for (int y = 0; y < field.rows; y++) {
      for (int x = 0; x < field.cols; x++) {
        s+= "," + field.data[y][x];
      }
    }
    println(s);
    server.write(s);
  }
}