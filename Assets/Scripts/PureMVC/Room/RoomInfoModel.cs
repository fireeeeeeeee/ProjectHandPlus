using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using GameProto;

public class RoomInfoModel 
{
    public int id;
    public int roundTime;
    public int roundNumber;
    public string roomName;
    public string mapName;
    public string password;
    public int maxPlayers;
    public List<PlayerInfo> preparedPlayers = new List<PlayerInfo>();
    public List<PlayerInfo> unPreparedPlayers = new List<PlayerInfo>();
    public int master;
}
