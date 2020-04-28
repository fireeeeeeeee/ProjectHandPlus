using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PureMVC.Patterns;
using PureMVC.Interfaces;


/// <summary>
/// 用于将角色的逻辑信息更新至视图
/// </summary>
public class CharactersMediator : Mediator
{
    public new const string NAME = "CharacterControllerMediator";

    public CharactersMediator(object viewComponent):base(NAME, viewComponent)
    {
        //((LoginPanelView)ViewComponent).loginBtn.onClick.AddListener(OnClickLogin);
        //userDataProxy = Facade.RetrieveProxy(UserDataProxy.NAME) as UserDataProxy;
    }

    public override void HandleNotification(INotification notification)
    {
        switch (notification.Name)
        {
            case MyFacade.CharacterViewUpdata:
                //TODO::更新角色的视图层

                break;
            default:
                break;
        }
    }
}
