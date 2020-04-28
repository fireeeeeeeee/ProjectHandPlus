using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class roleIntroduce
{

    public roleIntroduce(string name,string content)
    {
        this.name = name;
        this.content = content;
    }
    public string name;
    public string content;
}

public class ResourceTool : SingletonMonoBehaviour<ResourceTool>
{
    public GameObject LoginPanel;
    public GameObject RegisterPanel;
    public GameObject RoomShortInfoView;
    public GameObject RoomListPanel;
    public GameObject RoomCreatPanel;
    public GameObject RoomPanel;
    public GameObject SelectRolePanel;
    public GameObject RoleShortInfoView;

    public List<string> maps;
    public List<string> roles;

    //简易版配置
    public List<roleIntroduce> roleIntroduces = new List<roleIntroduce>();

    void Start()
    {
        DontDestroyOnLoad(this);
        roleIntroduces.Add(new roleIntroduce("Shange", "山哥NB"));
        roleIntroduces.Add(new roleIntroduce("WeiSuoMan1", "猥琐男1号"));
        roleIntroduces.Add(new roleIntroduce("WeiSuoMan2", "猥琐男2号"));
            
    }


    public int GetRoleIndex(string name)
    {
        for(int i=0;i<roles.Count;i++)
        {
            if(roles[i]==name)
            {
                return i;
            }
        }
        return -1;
    }

    public Sprite GetMapPreview(string name)
    {
        return Resources.Load("Image/MapPreview/" + name + "Pre", typeof(Sprite)) as Sprite;
    }

    public Sprite GetRolePreview(string name)
    {
        return Resources.Load("Image/RolePreview/" + name + "Pre", typeof(Sprite)) as Sprite;
    }

    public string GetRoleIntroduce(string name)
    {
        for(int i=0;i<roleIntroduces.Count;i++)
        {
            if(roleIntroduces[i].name==name)
            {
                return roleIntroduces[i].content;
            }
        }
        return null;
    }
}
