using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PureMVC.Patterns;
using PureMVC.Interfaces;
using System;

public class SelectRolePanelMediator : Mediator
{
    public new const string NAME = "SelectRolePanelMediator";

    public SelectRolePanelMediator(object viewComponent):base(NAME,viewComponent)
    {
        SelectRolePanelView view = ((SelectRolePanelView)ViewComponent);

        PlayerInfoProxy playerInfo = (PlayerInfoProxy)Facade.RetrieveProxy(PlayerInfoProxy.NAME);
        int curRole = ResourceTool.Instance.GetRoleIndex(playerInfo.data.CharacterName);

        view.rolePreview.sprite = ResourceTool.Instance.GetRolePreview(ResourceTool.Instance.roles[curRole]);
        view.roleIntroduce.text = ResourceTool.Instance.GetRoleIntroduce(ResourceTool.Instance.roles[curRole]);
        view.curRoleIndex = curRole;
        view.maxRoleNum = ResourceTool.Instance.roles.Count;

        view.cancleBtn.onClick.AddListener(OnCancle);
        view.lastRoleBtn.onClick.AddListener(OnLastRole);
        view.nextRoleBtn.onClick.AddListener(OnNextRole);
        view.selectBtn.onClick.AddListener(OnSelect);
    }

    private void OnSelect()
    {
        PlayerInfoProxy playerInfo = (PlayerInfoProxy)Facade.RetrieveProxy(PlayerInfoProxy.NAME);

        SelectRolePanelView view = ((SelectRolePanelView)ViewComponent);
        playerInfo.data.CharacterName = ResourceTool.Instance.roles[view.curRoleIndex];

        ((RoomPanelMediator)Facade.RetrieveMediator(RoomPanelMediator.NAME)).ChangeRolePreview(playerInfo.data.CharacterName);
        SendNotification(MyFacade.ChangeRoomPlayerInfo,playerInfo.data);
        OnCancle();
    }

    private void OnNextRole()
    {
        SelectRolePanelView view = (SelectRolePanelView)ViewComponent;
        if (view.curRoleIndex < view.maxRoleNum - 1) 
        {
            view.curRoleIndex++;
            view.rolePreview.sprite= ResourceTool.Instance.GetRolePreview(ResourceTool.Instance.roles[view.curRoleIndex]);
            view.roleIntroduce.text = ResourceTool.Instance.GetRoleIntroduce(ResourceTool.Instance.roles[view.curRoleIndex]);
        }
    }

    private void OnLastRole()
    {
        SelectRolePanelView view = (SelectRolePanelView)ViewComponent;
        if (view.curRoleIndex > 0) 
        {
            view.curRoleIndex--;
            view.rolePreview.sprite = ResourceTool.Instance.GetRolePreview(ResourceTool.Instance.roles[view.curRoleIndex]);
            view.roleIntroduce.text = ResourceTool.Instance.GetRoleIntroduce(ResourceTool.Instance.roles[view.curRoleIndex]);
        }
    }

    private void OnCancle()
    {
        GameObject roomPanel = ((RoomPanelView)Facade.RetrieveMediator(RoomPanelMediator.NAME).ViewComponent).gameObject;
        roomPanel.SetActive(true);

        GameObject selectPanel= ((SelectRolePanelView)Facade.RetrieveMediator(SelectRolePanelMediator.NAME).ViewComponent).gameObject;
        Facade.RemoveMediator(SelectRolePanelMediator.NAME);
        GameObject.Destroy(selectPanel);
    }
}
