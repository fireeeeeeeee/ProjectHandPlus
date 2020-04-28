using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class RoomCreatPanelView : MonoBehaviour
{
    public InputField roomName;
    public InputField maxPlayers;
    public InputField roundNum;
    public InputField roundTime;
    public InputField password;
    public Text message;
    public Image mapPreview;
    public Button nextMapBtn;
    public Button lastMapBtn;
    public Button cancleBtn;
    public Button selectRoomBtn;
    public int curMapIndex;
    public int mapNum;

    public bool Legal()
    {
        return (roomName.text != "" && maxPlayers.text != "" && roundNum.text != "" && roundTime.text != "");
    }

}
