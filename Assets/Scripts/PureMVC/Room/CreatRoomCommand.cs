using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Google.Protobuf;
using GameProto;
using PureMVC.Interfaces;
using PureMVC.Patterns;

public class CreatRoomCommand : SimpleCommand
{
    public override void Execute(INotification notification)
    {
        RoomInfoModel message = (RoomInfoModel)notification.Body;

        ClientMsg msg = new ClientMsg
        {
            Type = ClientEventCode.CreateRoom,
            Roominfo = new RoomInfo
            {
                RoundTime = message.roundTime,
                RoundNumber=message.roundNumber,
                RoomName=message.roomName,
                MapName=message.mapName,
                Password=message.password,
                MaxPlayers=message.maxPlayers
            }
        };

        NetworkManager.Instance.Send(msg.ToByteString());

    }
}
