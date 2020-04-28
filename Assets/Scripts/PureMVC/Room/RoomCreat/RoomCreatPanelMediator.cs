using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PureMVC.Patterns;
using PureMVC.Interfaces;
using System;
using GameProto;
public class RoomCreatPanelMediator : Mediator
{
    public new const string NAME = "RoomCreatPanelMediator";

    public RoomCreatPanelMediator(object viewComponent):base(NAME,viewComponent)
    {
        ((RoomCreatPanelView)ViewComponent).mapPreview.sprite = ResourceTool.Instance.GetMapPreview(ResourceTool.Instance.maps[0]);
        ((RoomCreatPanelView)ViewComponent).curMapIndex = 0;
        ((RoomCreatPanelView)ViewComponent).mapNum = ResourceTool.Instance.maps.Count;
        ((RoomCreatPanelView)ViewComponent).lastMapBtn.onClick.AddListener(onLastMap);
        ((RoomCreatPanelView)ViewComponent).nextMapBtn.onClick.AddListener(onNextMap);
        ((RoomCreatPanelView)ViewComponent).cancleBtn.onClick.AddListener(onCancle);
        ((RoomCreatPanelView)ViewComponent).selectRoomBtn.onClick.AddListener(onCheck);
    }

    private void onCheck()
    {
        RoomCreatPanelView view = (RoomCreatPanelView)ViewComponent;
        if(!view.Legal())
        {
            view.message.text = "请输入完整房间信息";

            return;
        }
        string _roomName = view.roomName.text;
        int _maxPlayers = int.Parse(view.maxPlayers.text);
        int _roundNum = int.Parse(view.roundNum.text);
        int _roundTime = int.Parse(view.roundTime.text);
        string _password = view.password.text;
        string _mapName = ResourceTool.Instance.maps[view.curMapIndex];

        RoomInfoModel message = new RoomInfoModel
        {
            roomName = _roomName,
            maxPlayers = _maxPlayers,
            roundNumber = _roundNum,
            password = _password,
            mapName = _mapName
        };
        SendNotification(MyFacade.CreatRoom,message);


        //GameObject roomPanel = (GameObject)GameObject.Instantiate(ResourceTool.Instance.RoomPanel);
        //RoomPanelView roomPanelView = roomPanel.GetComponent<RoomPanelView>();
        //Facade.RegisterMediator(new RoomPanelMediator(roomPanelView));

        //GameObject roomCreatPanel = ((RoomCreatPanelView)Facade.RetrieveMediator(RoomCreatPanelMediator.NAME).ViewComponent).gameObject;
        //Facade.RemoveMediator(RoomCreatPanelMediator.NAME);
        //GameObject.Destroy(roomCreatPanel);
    }

    private void onCancle()
    {
        GameObject roomListPanel = ((RoomListPanelView)Facade.RetrieveMediator(RoomListPanelMediator.NAME).ViewComponent).gameObject;
        roomListPanel.SetActive(true);
        //RoomListPanelView roomlistPanelView = roomListPanel.GetComponent<RoomListPanelView>();
        //Facade.RegisterMediator(new RoomListPanelMediator(roomlistPanelView));


        GameObject roomCreatPanel = ((RoomCreatPanelView)Facade.RetrieveMediator(RoomCreatPanelMediator.NAME).ViewComponent).gameObject;
        Facade.RemoveMediator(RoomCreatPanelMediator.NAME);
        GameObject.Destroy(roomCreatPanel);
    }

    private void onNextMap()
    {
        RoomCreatPanelView view = (RoomCreatPanelView)ViewComponent;
        if (view.curMapIndex < view.mapNum - 1) 
        {
            view.curMapIndex++;
            ((RoomCreatPanelView)ViewComponent).mapPreview.sprite = ResourceTool.Instance.GetMapPreview(ResourceTool.Instance.maps[view.curMapIndex]);
        }
    }

    private void onLastMap()
    {
        RoomCreatPanelView view = (RoomCreatPanelView)ViewComponent;
        if (view.curMapIndex > 0) 
        {
            view.curMapIndex--;
            ((RoomCreatPanelView)ViewComponent).mapPreview.sprite = ResourceTool.Instance.GetMapPreview(ResourceTool.Instance.maps[view.curMapIndex]);
        }
    }


    public override IList<string> ListNotificationInterests()
    {
        return new List<string>() { MyFacade.CreatRoomSuccess };
    }

    public override void HandleNotification(INotification notification)
    {
        switch (notification.Name)
        {
            case MyFacade.CreatRoomSuccess:
                {
                    RoomInfoProxy roomInfoProxy = (RoomInfoProxy)Facade.RetrieveProxy(RoomInfoProxy.NAME);
                    roomInfoProxy.myRoom = ((ServerMsg)notification.Body).Roominfos[0];


                    GameObject roomPanel = (GameObject)GameObject.Instantiate(ResourceTool.Instance.RoomPanel);
                    RoomPanelView roomPanelView = roomPanel.GetComponent<RoomPanelView>();
                    Facade.RegisterMediator(new RoomPanelMediator(roomPanelView,true));

                    GameObject roomCreatPanel = ((RoomCreatPanelView)Facade.RetrieveMediator(RoomCreatPanelMediator.NAME).ViewComponent).gameObject;
                    Facade.RemoveMediator(RoomCreatPanelMediator.NAME);
                    GameObject.Destroy(roomCreatPanel);
                }
                break;

            default:
              break;
        }
    }
}
