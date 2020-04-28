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
using TrueSync;

public class BattleUIMediator : Mediator
{
    public new const string NAME = "BattleUIMediator";
    //private LoginPanelView view;
    private readonly BattleUIProxy battleUIProxy;

    public BattleUIMediator(object viewComponent) : base(NAME, viewComponent) {

        //监听技能（道具）按钮
        for (int i = 0; i < ((BattleUIView)ViewComponent).SkillBTs.Count; i++) {
            int a = i;
            ((BattleUIView)ViewComponent).SkillBTs[0].onClick.AddListener(delegate() {
                OnClickSkillBT(a);
            });
        }

        ((BattleUIView)ViewComponent).AddListener(OnDragTouch);

        battleUIProxy = Facade.RetrieveProxy(BattleUIProxy.NAME) as BattleUIProxy;
    }

    private void OnClickSkillBT(int id) {
        //FrameDataModel
        //TODO::向服务器发送技能操作
    }

    private void OnDragTouch() {
        //TODO::向服务器发送移动操作

        PlayerInput input = new PlayerInput();
        input.MoveDirectionX = ((BattleUIView)ViewComponent).touchL.fMoveDirection.x._serializedValue;
        input.MoveDirectionY = ((BattleUIView)ViewComponent).touchL.fMoveDirection.y._serializedValue;
        input.UsePropsInPackID = -1;
        ClientMsg msg = new ClientMsg() {
            Type = ClientEventCode.C2Ssync,
            Input = input
        };

        //NetworkManager.Instance.Send(msg.ToByteString());

        //向假服务器发送信息 测试用
        SendNotification(MyFacade.FakeServer, msg);
    }

    public override IList<string> ListNotificationInterests() {
        return new List<string>() { 
            //MyFacade.LoginSuccess,
            //MyFacade.LoginFailure
        };
    }

    public override void HandleNotification(INotification notification)
    {
        switch (notification.Name)
        {
            //case MyFacade.LoginSuccess:
            //    ((LoginPanelView)ViewComponent).messageText.text = "succeed";
            //    break;
            default:
                break;
        }
    }
}
