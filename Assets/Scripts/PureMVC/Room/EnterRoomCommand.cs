using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Google.Protobuf;
using GameProto;
using PureMVC.Interfaces;
using PureMVC.Patterns;

public class EnterRoomCommand : SimpleCommand
{
    public override void Execute(INotification notification)
    {
        int roomID = (int)notification.Body;

        ClientMsg msg = new ClientMsg
        {
            Type = ClientEventCode.EnterRoom,
            Roominfo = new RoomInfo
            {
                Id = roomID
            }
        };

        NetworkManager.Instance.Send(msg.ToByteString());
    }

}
