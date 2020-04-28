using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PureMVC.Patterns;
using GameProto;

public class RoomInfoProxy : Proxy
{
    public new const string NAME = "RoomInfo";

    public List<RoomInfo> roomInfos;
    public RoomInfo myRoom;


    public RoomInfoProxy() : base(NAME)
    {
        roomInfos = new List<RoomInfo>();
    }
    public void AddRoomInfo(RoomInfo roomInfo)
    {
        roomInfos.Add(roomInfo);
    }

    public void RemoveRoomInfo(RoomInfo roomInfo)
    {
        roomInfos.Remove(roomInfo);
    }

    public void RemoveRoomInfo(int roomID)
    {
        for(int i=0;i<roomInfos.Count;i++)
        {
            if(roomInfos[i].Id==roomID)
            {
                roomInfos.RemoveAt(i);
                break;
            }
        }
    }

    public RoomInfo GetRoomInfo(int roomID)
    {
        for (int i = 0; i < roomInfos.Count; i++)
        {
            if (roomInfos[i].Id == roomID)
            {
                return roomInfos[i];
            }
        }

        return null;
    }


}
