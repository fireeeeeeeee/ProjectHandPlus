using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RoomListModel 
{
    /// <summary>
    /// 
    /// </summary>
    /// <param name="curPage">当前页面</param>
    /// <param name="maxPage">总页数</param>
    /// <param name="pageRoomNum">页面房间个数</param>
    /// <param name="pageRoomGap">页面房间列表的间距</param>
    public RoomListModel(int pageRoomNum,int pageRoomGap)
    {
        this.pageRoomNum = pageRoomNum;
        this.pageRoomGap = pageRoomGap;
        curPage = 0;
        maxPage = 0;
        curRoomID = -1;
    }
    public int curPage;
    public int maxPage;
    public int pageRoomNum;
    public int pageRoomGap;
    public int curRoomID;
}
