using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using PureMVC.Patterns;
using PureMVC.Interfaces;
using System;
using UnityEngine.SceneManagement;

public class RoomPanelMediator : Mediator
{
    public new const string NAME = "RoomPanelMediator";

    public RoomPanelMediator(object viewComponent, bool isMaster) : base(NAME, viewComponent)
    {
        ((RoomPanelView)ViewComponent).changeRoleBtn.onClick.AddListener(OnChangeRole);
        ((RoomPanelView)ViewComponent).exitRoomBtn.onClick.AddListener(OnExitRoom);
        ((RoomPanelView)ViewComponent).startBtn.onClick.AddListener(OnStart);
        ((RoomPanelView)ViewComponent).startBtn.gameObject.SetActive(isMaster);

        Toggle isReadyToggle = ((RoomPanelView)ViewComponent).isReadyToggle;
        isReadyToggle.onValueChanged.AddListener((bool value) => OnIsReady(isReadyToggle, value));


        string mapName = ((RoomInfoProxy)Facade.RetrieveProxy(RoomInfoProxy.NAME)).myRoom.MapName;
        string roleName = ResourceTool.Instance.roles[0];
        ChangeRolePreview(roleName);
        ChangeMapPreView(mapName);
        PlayerInfoProxy playerInfo = (PlayerInfoProxy)Facade.RetrieveProxy(PlayerInfoProxy.NAME);
        playerInfo.data.CharacterName = roleName;
        SendNotification(MyFacade.ChangeRoomPlayerInfo, playerInfo.data);
    }

    public void ChangeRolePreview(string name)
    {
        ((RoomPanelView)ViewComponent).rolePreview.sprite = ResourceTool.Instance.GetRolePreview(name);
    }

    public void ChangeMapPreView(string name)
    {
        ((RoomPanelView)ViewComponent).mapPreview.sprite = ResourceTool.Instance.GetMapPreview(name);
    }

    public void ChangeMaster(bool isMaster)
    {
        ((RoomPanelView)ViewComponent).startBtn.gameObject.SetActive(isMaster);
    }


    public override void OnRegister()
    {
        Facade.RegisterProxy(new RoomPlayerInfoProxy());
        base.OnRegister();
    }

    public override void OnRemove()
    {
        Facade.RemoveProxy(RoomPlayerInfoProxy.NAME);
        base.OnRemove();
    }

    private void OnStart()
    {
        SendNotification(MyFacade.StartGame);
    }

    private void OnIsReady(Toggle toggle, bool isOn)
    {
        RoomPanelView view = ((RoomPanelView)ViewComponent);
        PlayerInfoProxy playerInfo = (PlayerInfoProxy)Facade.RetrieveProxy(PlayerInfoProxy.NAME);
        if (isOn)
        {
            view.isReady.text = "取消准备";
            playerInfo.data.Prepared = true;
        }
        else
        {
            view.isReady.text = "准备";
            playerInfo.data.Prepared = false;
        }
        SendNotification(MyFacade.ChangeRoomPlayerInfo, playerInfo.data);
    }

    

    private void OnExitRoom()
    {
        SendNotification(MyFacade.ExitRoom);

        GameObject roomListPanel = ((RoomListPanelView)Facade.RetrieveMediator(RoomListPanelMediator.NAME).ViewComponent).gameObject;
        roomListPanel.SetActive(true);

        GameObject roomPanel = ((RoomPanelView)Facade.RetrieveMediator(RoomPanelMediator.NAME).ViewComponent).gameObject;
        Facade.RemoveMediator(RoomPanelMediator.NAME);
        GameObject.Destroy(roomPanel);
    }

    private void OnChangeRole()
    {
        GameObject selectRolePanel = (GameObject)GameObject.Instantiate(ResourceTool.Instance.SelectRolePanel);
        SelectRolePanelView selectRolePanelView = selectRolePanel.GetComponent<SelectRolePanelView>();
        Facade.RegisterMediator(new SelectRolePanelMediator(selectRolePanelView));


        GameObject roomPanel = ((RoomPanelView)Facade.RetrieveMediator(RoomPanelMediator.NAME).ViewComponent).gameObject;
        roomPanel.SetActive(false);
    }

    public override IList<string> ListNotificationInterests()
    {
        return new List<string>() { MyFacade.StartGameSuccess ,MyFacade.StartGameFail};
    }

    public override void HandleNotification(INotification notification)
    {
        switch (notification.Name)
        {
            case MyFacade.StartGameSuccess:
                {
                    GameProto.ServerMsg msg = (GameProto.ServerMsg)notification.Body;

                    NetworkManager.Instance.Connect(msg.Ip, msg.Port);
                    SceneManager.LoadScene("BattleTest");



                    GameObject roomPanel = ((RoomPanelView)Facade.RetrieveMediator(RoomPanelMediator.NAME).ViewComponent).gameObject;
                    Facade.RemoveMediator(RoomPanelMediator.NAME);
                    GameObject.Destroy(roomPanel);
                }
                break;
            case MyFacade.StartGameFail:
                {

                }
                break;
            default:
                break;
        }
    }
}
