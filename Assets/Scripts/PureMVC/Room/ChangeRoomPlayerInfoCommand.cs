using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Google.Protobuf;
using GameProto;
using PureMVC.Interfaces;
using PureMVC.Patterns;

public class ChangeRoomPlayerInfoCommand : SimpleCommand
{
    public override void Execute(INotification notification)
    {
        PlayerInfo message = (PlayerInfo)notification.Body;

        ClientMsg msg = new ClientMsg
        {
            Type = ClientEventCode.ChangeStateInRoom,
            Playerinfo=message
        };

        NetworkManager.Instance.Send(msg.ToByteString());

    }
}
