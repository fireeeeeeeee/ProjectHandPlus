using PureMVC.Patterns;
using PureMVC.Interfaces;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Events;
using GameProto;

public class RoomListPanelMediator : Mediator
{
    public new const string NAME = "RoomListPanelMediator";


    public RoomListPanelMediator(object viewComponent):base(NAME,viewComponent)
    {
        ((RoomListPanelView)viewComponent).creatButton.onClick.AddListener(OnCreatRoom);
        ((RoomListPanelView)viewComponent).selectButton.onClick.AddListener(OnSelectRoom);
        ((RoomListPanelView)viewComponent).downButton.onClick.AddListener(delegate { OnChangePage(1); });
        ((RoomListPanelView)viewComponent).firstButton.onClick.AddListener(delegate { OnChangePage(-999); });
        ((RoomListPanelView)viewComponent).lastButton.onClick.AddListener(delegate { OnChangePage(999); });
        ((RoomListPanelView)viewComponent).upButton.onClick.AddListener(delegate { OnChangePage(-1); });
        ((RoomListPanelView)viewComponent).pageNum.text = "1/1";
        Facade.RegisterProxy(new RoomListProxy(new RoomListModel(10, 30)));
    }

    
    public void AddListenToRoomShortInfo(RoomShortInfoView view)
    {
        view.toggle.onValueChanged.AddListener(delegate { ChoseRoom(view); });
    }

    private void ChoseRoom(RoomShortInfoView view)
    {
        if(view.toggle.isOn)
        {
            RoomListProxy proxy = (RoomListProxy)Facade.RetrieveProxy(RoomListProxy.NAME);
            proxy.data.curRoomID = int.Parse(view.roomID.text);
            Debug.Log(proxy.data.curRoomID);
        }
    }

    private void OnChangePage(int dPage)
    {
        RoomListProxy roomListProxy = ((RoomListProxy)Facade.RetrieveProxy(RoomListProxy.NAME));
        roomListProxy.ChangePage(dPage);
        ((RoomListPanelView)ViewComponent).pageNum.text = roomListProxy.data.curPage + "/" + roomListProxy.data.maxPage;
    }

    private void OnSelectRoom()
    {
        RoomListProxy proxy = (RoomListProxy)Facade.RetrieveProxy(RoomListProxy.NAME);
        if (proxy.data.curRoomID != -1) 
        {
            SendNotification(MyFacade.EnterRoom, proxy.data.curRoomID);
        }
    }

    private void OnCreatRoom()
    {
        GameObject roomCreatPanel = (GameObject)GameObject.Instantiate(ResourceTool.Instance.RoomCreatPanel);
        RoomCreatPanelView roomCreatPanelView = roomCreatPanel.GetComponent<RoomCreatPanelView>();
        Facade.RegisterMediator(new RoomCreatPanelMediator(roomCreatPanelView));

        GameObject roomListPanel = ((RoomListPanelView)Facade.RetrieveMediator(RoomListPanelMediator.NAME).ViewComponent).gameObject;
        roomListPanel.SetActive(false);

        //RoomInfoModel tem = new RoomInfoModel();
        //tem.id = UnityEngine.Random.Range(0, 100);
        //tem.roomName = UnityEngine.Random.Range(0, 100).ToString();
        //tem.mapName = UnityEngine.Random.Range(0, 100).ToString();
        //tem.master = UnityEngine.Random.Range(0, 100);
        //((RoomInfoProxy)Facade.RetrieveProxy(RoomInfoProxy.NAME)).AddRoomInfo(tem);
        //SendNotification(MyFacade.RefreshRoomList);
    }

    public override IList<string> ListNotificationInterests()
    {
        return new List<string>() { MyFacade.EnterRoomSuccess };
    }

    public override void HandleNotification(INotification notification)
    {
        switch (notification.Name)
        {
            case MyFacade.EnterRoomSuccess:
                {
                    RoomInfoProxy roomInfoProxy = (RoomInfoProxy)Facade.RetrieveProxy(RoomInfoProxy.NAME);
                    roomInfoProxy.myRoom = ((ServerMsg)notification.Body).Roominfos[0];
                    Debug.Log(roomInfoProxy.myRoom.MapName);
                    GameObject roomPanel = (GameObject)GameObject.Instantiate(ResourceTool.Instance.RoomPanel);
                    RoomPanelView roomPanelView = roomPanel.GetComponent<RoomPanelView>();
                    Facade.RegisterMediator(new RoomPanelMediator(roomPanelView, false));




                    GameObject roomListPanel = ((RoomListPanelView)Facade.RetrieveMediator(RoomListPanelMediator.NAME).ViewComponent).gameObject;
                    roomListPanel.SetActive(false);
                }
                break;

            default:
                break;
        }
    }
}
