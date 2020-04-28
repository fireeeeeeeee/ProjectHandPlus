using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Google.Protobuf;
using GameProto;
using PureMVC.Interfaces;
using PureMVC.Patterns;
using System.Security.Cryptography;
using System;
using System.Text;

public class LoginCommand : SimpleCommand {
    // 处理由LoginPanelMediator的OnLoginClick()发出的通知，可以去看一下
    public override void Execute(INotification notification) {
        UserDataProxy proxy = Facade.RetrieveProxy(UserDataProxy.NAME) as UserDataProxy;
        UserDataModel message = (UserDataModel)notification.Body;
        proxy.SetProperty(message);

        ClientMsg msg = new ClientMsg {
            Type = ClientEventCode.LogIn,

            Playerinfo = new PlayerInfo
            {
                Account = message.account,
                Password = message.password
            }

            //Playerinfo.Account = message.email,
            //Password = message.password
        };

        NetworkManager.Instance.Send(msg.ToByteString());
    }

}
