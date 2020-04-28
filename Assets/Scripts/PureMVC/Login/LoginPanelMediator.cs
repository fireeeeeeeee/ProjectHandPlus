using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PureMVC.Patterns;
using PureMVC.Interfaces;
using GameProto;

public class LoginPanelMediator : Mediator
{
    public new const string NAME = "LoginPanelMediator";
    //private LoginPanelView view;
    private readonly UserDataProxy userDataProxy;

    public LoginPanelMediator(object viewComponent):base(NAME, viewComponent) {
        ((LoginPanelView)ViewComponent).loginBtn.onClick.AddListener(OnClickLogin);
        ((LoginPanelView)ViewComponent).registerBtn.onClick.AddListener(OnClickRegister);
        userDataProxy = Facade.RetrieveProxy(UserDataProxy.NAME) as UserDataProxy;
    }

    private void OnClickRegister() {


        GameObject registerPanel = (GameObject)GameObject.Instantiate(ResourceTool.Instance.RegisterPanel);
        RegisterPanelView registerPanelView = registerPanel.GetComponent<RegisterPanelView>();
        Facade.RegisterMediator(new RegisterPanelMediator(registerPanelView));

        GameObject loginPanel = ((LoginPanelView)Facade.RetrieveMediator(LoginPanelMediator.NAME).ViewComponent).gameObject;
        Facade.RemoveMediator(LoginPanelMediator.NAME);
        GameObject.Destroy(loginPanel);

        //((RegisterPanelView)Facade.RetrieveMediator(RegisterPanelMediator.NAME).ViewComponent).gameObject.SetActive(true);

        //((LoginPanelView)Facade.RetrieveMediator(LoginPanelMediator.NAME).ViewComponent).gameObject.SetActive(false);
    }

    private void OnClickLogin() {
        string _email = ((LoginPanelView)ViewComponent).emailText.text;
        string _password = ((LoginPanelView)ViewComponent).passwordText.text;
        UserDataModel message = new UserDataModel {
            account = _email,
            password = _password
        };
        SendNotification(MyFacade.Login, message);
    }

    public override IList<string> ListNotificationInterests() {
        return new List<string>() { MyFacade.LoginSuccess, MyFacade.LoginFailure};
    }

    public override void HandleNotification(INotification notification) {
        switch (notification.Name) {
            case MyFacade.LoginSuccess:
                {
                    ((LoginPanelView)ViewComponent).messageText.text = "登录成功";
                    //切换场景

                    ServerMsg msg =(ServerMsg)notification.Body;

                    ((UserDataModel)Facade.RetrieveProxy(UserDataProxy.NAME).Data).uid = msg.PlayerInfo.Uid;
                    ((UserDataModel)Facade.RetrieveProxy(UserDataProxy.NAME).Data).userName = msg.PlayerInfo.Nickname;

                    GameObject roomListPanel = (GameObject)GameObject.Instantiate(ResourceTool.Instance.RoomListPanel);
                    RoomListPanelView roomListPanellView = roomListPanel.GetComponent<RoomListPanelView>();
                    Facade.RegisterProxy(new RoomInfoProxy());
                    Facade.RegisterProxy(new PlayerInfoProxy(msg.PlayerInfo));
                    Facade.RegisterMediator(new RoomListPanelMediator(roomListPanellView));
                    

                    GameObject loginPanel = ((LoginPanelView)Facade.RetrieveMediator(LoginPanelMediator.NAME).ViewComponent).gameObject;
                    Facade.RemoveMediator(LoginPanelMediator.NAME);
                    GameObject.Destroy(loginPanel);
                }
                break;
            case MyFacade.LoginFailure:
                {
                    if (((ServerMsg)notification.Body).Type == ServerEventCode.LogInErrorAccountDontExist)
                    {
                        ((LoginPanelView)ViewComponent).messageText.text = "用户名不存在";
                    }
                    else if(((ServerMsg)notification.Body).Type == ServerEventCode.LogInErrorPasswordWrong)
                    {
                        ((LoginPanelView)ViewComponent).messageText.text = "密码错误";
                    }
                    else if(((ServerMsg)notification.Body).Type == ServerEventCode.LogInErrorReLogIn)
                    {
                        ((LoginPanelView)ViewComponent).messageText.text = "用户已登录";
                    }
                }
                break;

            default:
                break;
        }
    }
}
