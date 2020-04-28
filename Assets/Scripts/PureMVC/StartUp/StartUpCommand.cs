using System.Collections;
using System.Collections.Generic;
using PureMVC.Interfaces;
using PureMVC.Patterns;
using UnityEngine;

public class StartUpCommand : SimpleCommand {
    public override void Execute(INotification notification) {
        Debug.Log("StartUpCommand: hello!");

        GameObject loginPanel =(GameObject)GameObject.Instantiate(ResourceTool.Instance.LoginPanel);
        LoginPanelView loginPanelView = loginPanel.GetComponent<LoginPanelView>();
        Facade.RegisterMediator(new LoginPanelMediator(loginPanelView));
        

        //LoginPanelView loginPanelView = GameObject.Find("LoginPanel").GetComponent<LoginPanelView>();
        //Facade.RegisterMediator(new LoginPanelMediator(loginPanelView));
        //RegisterPanelView registerPanelView = GameObject.Find("RegisterPanel").GetComponent<RegisterPanelView>();
        //Facade.RegisterMediator(new RegisterPanelMediator(registerPanelView));
        //registerPanelView.gameObject.SetActive(false);
    }
}