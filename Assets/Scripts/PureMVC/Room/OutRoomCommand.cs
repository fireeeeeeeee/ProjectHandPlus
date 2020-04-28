using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Google.Protobuf;
using GameProto;
using PureMVC.Interfaces;
using PureMVC.Patterns;

public class ExitRoomCommand : SimpleCommand
{

    public override void Execute(INotification notification)
    {
        ClientMsg msg = new ClientMsg
        {
            Type = ClientEventCode.ExitRoom
        };

        NetworkManager.Instance.Send(msg.ToByteString());
    }
}
