using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;


public class BattleUIView : MonoBehaviour
{
    /// <summary>
    /// 左摇杆
    /// </summary>
    public EasyTouchMove touchL;

    /// <summary>
    /// 右摇杆    TODO::需要改成滑动屏幕模式
    /// </summary>
    public EasyTouchMove touchR;
    public List<Button> SkillBTs;


    private List<Action> actions = new List<Action>();

    public void Update() {
        //Debug.Log("Run");

        //执行监听的函数  --这里就是执行摇杆模块的事件
        foreach (var e in actions) {
            e();
        }
    }

    public void AddListener(Action action)
    {
        actions.Add(action);
    }

}
