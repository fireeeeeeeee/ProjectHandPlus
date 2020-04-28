using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Google.Protobuf;
using GameProto;
using PureMVC.Interfaces;
using PureMVC.Patterns;

public class CharactersFrameUpdataCommand : SimpleCommand
{
    //用从服务器接收的帧信息进行帧更新
    public override void Execute(INotification notification)
    {
        CharactersDataProxy proxy = Facade.RetrieveProxy(CharactersDataProxy.NAME) as CharactersDataProxy;
        List<PlayerInput> inputs = (List<PlayerInput>)notification.Body;


        //将收到的帧操作交给角色代理处理，更新角色信息
        proxy.FrameUpdata(inputs);
    }
}
