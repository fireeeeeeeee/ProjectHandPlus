using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Google.Protobuf;
using GameProto;
using PureMVC.Interfaces;
using PureMVC.Patterns;

public class RefreshRoomInfoCommand : SimpleCommand
{
    public override void Execute(INotification notification)
    {
        RoomPanelMediator roomPanelMediator = (RoomPanelMediator)Facade.RetrieveMediator(RoomPanelMediator.NAME);
        RoomPlayerInfoProxy roomPlayerInfoProxy = (RoomPlayerInfoProxy)Facade.RetrieveProxy(RoomPlayerInfoProxy.NAME);

        RoomPanelView roomPanelView = (RoomPanelView)roomPanelMediator.ViewComponent;
        PlayerInfoProxy playerInfoProxy = (PlayerInfoProxy)Facade.RetrieveProxy(PlayerInfoProxy.NAME);
        ServerMsg msg = (ServerMsg)notification.Body;

        if(msg!=null)
        {
            roomPlayerInfoProxy.roomPlayerInfos.Clear();
            roomPlayerInfoProxy.roomPlayerInfos = new List<PlayerInfo>(msg.Roominfos[0].Players);
            if(msg.Roominfos[0].Master==playerInfoProxy.data.Uid)
            {
                roomPanelMediator.ChangeMaster(true);
            }
            else
            {
                roomPanelMediator.ChangeMaster(false);
            }
        }

        for(int i=0;i < roomPanelView.playerShortInfos.Count;i++)
        {
            GameObject.Destroy(roomPanelView.playerShortInfos[i]);
        }

        roomPanelView.playerShortInfos.Clear();

        for (int i = 0, posY = 0; i < roomPlayerInfoProxy.roomPlayerInfos.Count; i++, posY -= 20)  
        {
            PlayerInfo playerInfo = roomPlayerInfoProxy.roomPlayerInfos[i];
            GameObject newShortInfo = GameObject.Instantiate(ResourceTool.Instance.RoleShortInfoView);
            roomPanelView.playerShortInfos.Add(newShortInfo);
            newShortInfo.transform.SetParent(roomPanelView.playerList.transform);

            ((RectTransform)newShortInfo.transform).localPosition = new Vector3(0, posY, 0);


            RoleShortInfoView newView = newShortInfo.GetComponent<RoleShortInfoView>();
            newView.roleName.text = playerInfo.Nickname;
            newView.roleRank.text = playerInfo.CharacterName;
            newView.isReady.text = playerInfo.Prepared ? "准备" : "";
        }
    }
}
