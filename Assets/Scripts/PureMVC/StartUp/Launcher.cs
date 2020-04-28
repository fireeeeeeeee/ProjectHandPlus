using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Launcher : MonoBehaviour
{
    public string ip;
    public int port;
    // Start is called before the first frame update
    void Start()
    {
        MessageCenter.CreateInstance();
        NetworkManager.CreateInstance();
        NetworkManager.Instance.Connect(ip, port);
        MyFacade.GetInstance().SendNotification(MyFacade.StartUp);

        Debug.Log("Lanuch");
        //MyFacade.GetInstance().SendNotification(MyFacade.TestBattleStartUp);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
