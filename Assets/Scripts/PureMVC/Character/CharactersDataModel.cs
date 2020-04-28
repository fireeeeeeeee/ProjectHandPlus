using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrueSync;

/// <summary>
/// 角色数据
/// </summary>
public class CharactersDataModel
{

}

public class CharacterBaseData
{

    ///////////////////////////////////物理信息
    /// <summary>
    /// 角色当前位置（世界坐标系）
    /// </summary>
    public TSVector pos;

    /// <summary>
    /// 角色当前视角朝向（世界坐标系）
    /// </summary>
    public TSVector rot;

    ////////////////////////////////////用户信息userData
    //uid
    //nickname

    ////////////////////////////////////阵营信息

    //角色阵营：阵营1、阵营2、、、、、、

    //////
    //buff栏？
    //状态栏？
    //////

    //////////////////////////////////属性相关信息

    //角色种族（职业）
    //角色血量
    //角色蓝量
    //角色基础攻击力
    //角色基础防御力
    //角色攻速
    //角色移速

    //操作按钮配置  总共7个  每个栏可设置属性为（技能 道具 禁用）

    //背包  假定总共6*6个   前4*6开放可调整物品    后2*6为默认技能不可调整

    public CharacterAttributes characterAttributes;


    
    //TODO:移动逻辑
    public void Move(TSVector speed, int frameNumber = 1) {

    }

    public void Move(FP speed, int frameNumber = 1) {

    }                                           

    public void MoveFoward(FP speed, int frameNumber = 1) {

    }

    public void MoveFoward(TSVector speed, int frameNumber = 1) {

    }

}
