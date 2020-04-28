using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PureMVC.Interfaces;
using PureMVC.Patterns;

public class TestBattleStartUpCommand : SimpleCommand 
{
    public override void Execute(INotification notification) {
        Debug.Log("TestBattleStartUpCommand: hello!");

        Facade.RegisterMediator(new BattleUIMediator(GameObject.Find("BattleUIManager").GetComponent<BattleUIView>()));


        //LoginPanelView loginPanelView = GameObject.Find("LoginPanel").GetComponent<LoginPanelView>();
        //Facade.RegisterMediator(new LoginPanelMediator(loginPanelView));
        //RegisterPanelView registerPanelView = GameObject.Find("RegisterPanel").GetComponent<RegisterPanelView>();
        //Facade.RegisterMediator(new RegisterPanelMediator(registerPanelView));
        //registerPanelView.gameObject.SetActive(false);
    }
}
