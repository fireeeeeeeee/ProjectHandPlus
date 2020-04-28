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

public class FakeServerCommand : SimpleCommand
{
    static float preTime = 0;
    public override void Execute(INotification notification) {

        if (EasyTouchMove.touchTime - preTime < 0.02) {
            preTime = EasyTouchMove.touchTime;
            return;
        } preTime = EasyTouchMove.touchTime;
        ClientMsg message = (ClientMsg)notification.Body;

        ServerMsg msg = new ServerMsg();
        msg.Inputs.Add(message.Input);

        List<PlayerInput> inputs = new List<PlayerInput>();
        foreach (var e in msg.Inputs) {
            inputs.Add(e);
        }
        SendNotification(MyFacade.CharactersFrameUpdata, inputs);
    }

}
