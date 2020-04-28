using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PureMVC.Patterns;
using PureMVC.Interfaces;
using GameProto;

public class RegisterPanelMediator : Mediator
{
    public new const string NAME = "RegisterPanelMediator";



    public RegisterPanelMediator(object viewComponent) : base(NAME, viewComponent)
    {
        ((RegisterPanelView)ViewComponent).registerBtn.onClick.AddListener(OnClickRegister);
        ((RegisterPanelView)ViewComponent).cancleBtn.onClick.AddListener(OnClickCancle);
    }

    private void OnClickCancle()
    {
        GameObject loginPanel = (GameObject)GameObject.Instantiate(ResourceTool.Instance.LoginPanel);
        LoginPanelView loginPanelView = loginPanel.GetComponent<LoginPanelView>();
        Facade.RegisterMediator(new LoginPanelMediator(loginPanelView));

        GameObject registerPanel = ((RegisterPanelView)Facade.RetrieveMediator(RegisterPanelMediator.NAME).ViewComponent).gameObject;
        Facade.RemoveMediator(RegisterPanelMediator.NAME);
        GameObject.Destroy(registerPanel);

        //((RegisterPanelView)Facade.RetrieveMediator(RegisterPanelMediator.NAME).ViewComponent).gameObject.SetActive(false);

        //((LoginPanelView)Facade.RetrieveMediator(LoginPanelMediator.NAME).ViewComponent).gameObject.SetActive(true);
    }

    private void OnClickRegister()
    {
        string _userName= ((RegisterPanelView)ViewComponent).userNameText.text;
        string _email = ((RegisterPanelView)ViewComponent).emailText.text;
        string _password = ((RegisterPanelView)ViewComponent).passwordText.text;
        string _checkPassword = ((RegisterPanelView)ViewComponent).checkPasswordText.text;
        if(_password!=_checkPassword)
        {
            ((RegisterPanelView)ViewComponent).messageText.text = "请确认密码";
            return;
        }
        UserDataModel message = new UserDataModel
        {
            userName = _userName,
            account = _email,
            password = _password
        };
        SendNotification(MyFacade.Register, message);
    }

    public override IList<string> ListNotificationInterests()
    {
        return new List<string>() { MyFacade.RegisterSuccess, MyFacade.RegisterFailure };
    }

    public override void HandleNotification(INotification notification)
    {
        switch (notification.Name)
        {
            case MyFacade.RegisterSuccess:
                {
                    ((RegisterPanelView)ViewComponent).messageText.text = "注册成功";
                }
                break;
            case MyFacade.RegisterFailure:
                {
                    ((RegisterPanelView)ViewComponent).messageText.text = "用户名已存在";
                }
                break;
            default:
                break;
        }
    }
}
