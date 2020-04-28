using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class RoomPanelView : MonoBehaviour
{
    public Toggle isReadyToggle;
    public Button exitRoomBtn;
    public Button startBtn;
    public Button changeRoleBtn;
    public Image rolePreview;
    public Image mapPreview;
    public Text maxPlayerNum;
    public Text isReady;
    public List<GameObject> playerShortInfos;
    public GameObject playerList;
}
