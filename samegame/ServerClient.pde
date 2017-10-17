import processing.net.*;
class ServerClient {

  Client client;
  String player_name;

  ServerClient(samegame name) {
    client = new Client(name, "127.0.0.1", 20000);
  }

  //Serverから送られてきたPacketを受け取る
  void clientEvent() {
    String packet = client.readString();
    if (packet != null) {
      String[] inf = packet.split(",", 0);
      switch(inf[0]) {
      case "PLAYER_ID":
        if (player_name == null) {
          player_name = inf[1];
          print(player_name);
          requestFieldData();
        }
        break;
      case "FIELD":
        setField(inf);
        break;
      }
    }
  }

  //Serverから送られてきたField情報を格納する
  void setField(String[] _inf) {
    int count = 1;
    for (int y = 0; y < field.rows; y++) {
      for (int x = 0; x < field.cols; x++) {
        field.data[y][x] = int(_inf[count++]);
      }
    }
  }

  //Clientが選択した座標を送る
  void sendPos(int x, int y) {
    client.write("POS," + player_name + "," + x + "," + y);
  }


  //ServerのField情報をリクエストする
  void requestFieldData() {
    client.write("FIELD");
  }

  void requestPlayerId() {
    client.write("PLAYER_ID");
  }
}