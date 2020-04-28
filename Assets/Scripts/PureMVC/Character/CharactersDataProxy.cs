using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PureMVC.Patterns;
using GameProto;
using TrueSync;


/// <summary>
/// 所有角色的管理代理
/// </summary>
public class CharactersDataProxy : Proxy
{
    public new const string NAME = "CharactersData";
    
    public CharactersDataProxy(object data) : base(NAME, data) {

    }


    /// <summary>
    /// 更新一帧所有角色的数据
    /// </summary>
    public void FrameUpdata(List<PlayerInput> opts) {

        foreach (var e in opts) {
            UpdateCharacter(e.Uid, e);


            FP x = new FP(), z = new FP();
            x._serializedValue = e.MoveDirectionX;
            z._serializedValue = e.MoveDirectionY;
            Vector3 moveD = (new Vector3(x.AsFloat(), 0, z.AsFloat())).normalized;
            moveD.x /= 50.0f;
            moveD.z /= 50.0f;
            Debug.Log(moveD);
            GameObject.Find("Cube").transform.Translate(moveD);
        }

        //角色逻辑更新完毕，发送通知更新角色视图
        SendNotification(MyFacade.CharacterViewUpdata);
    }

    /// <summary>
    /// 更新某一个角色一帧的信息
    /// </summary>
    /// <param name="uid">用户唯一标识</param>
    /// <param name="opt">改用户的帧操作</param>
    private void UpdateCharacter(int uid, PlayerInput opt) {
        var character = FindCharacter(uid);
    }
    /// <summary>
    /// 根据用户唯一标识查找对应在游戏中的角色
    /// </summary>
    /// <param name="uid"></param>
    /// <returns></returns>
    private CharacterBaseData FindCharacter(int uid) {
        return new CharacterBaseData();
    }
}
