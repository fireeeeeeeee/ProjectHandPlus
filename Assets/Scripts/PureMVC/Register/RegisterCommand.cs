using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Google.Protobuf;
using GameProto;
using PureMVC.Interfaces;
using PureMVC.Patterns;

public class RegisterCommand : SimpleCommand{

    public override void Execute(INotification notification){
        UserDataModel message = (UserDataModel)notification.Body;

        ClientMsg msg = new ClientMsg {
            Type = ClientEventCode.Regist,
            Playerinfo = new PlayerInfo
            {
                Nickname = message.userName,
                Account = message.account,
                Password = message.password
            }
            //Name = message.account,
            //Password = message.password
        };

        NetworkManager.Instance.Send(msg.ToByteString());
    }
}
