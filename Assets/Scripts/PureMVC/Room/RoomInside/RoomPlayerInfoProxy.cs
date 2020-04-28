using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GameProto;
using PureMVC.Patterns;

public class RoomPlayerInfoProxy : Proxy
{
    public new const string NAME = "RoomPlayerInfo";

    public List<PlayerInfo> roomPlayerInfos;

    public RoomPlayerInfoProxy() : base(NAME)
    {
        roomPlayerInfos = new List<PlayerInfo>();
    }

}
