using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using GameProto;
using PureMVC.Patterns;

public class PlayerInfoProxy : Proxy
{
    public new const string NAME = "PlayerInfo";

    public PlayerInfo data;

    public PlayerInfoProxy(object data) : base(NAME)
    {
        this.data = (PlayerInfo)data;
    }

}
