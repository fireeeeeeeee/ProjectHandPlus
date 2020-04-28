using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TrueSync;

public class CharacterAttributes
{
    /// <summary>
    /// 角色名称   和人物模型同步
    /// </summary>
    string characterName = "";

    /// <summary>
    /// 角色当前血量
    /// </summary>
    FP curHP;

    /// <summary>
    /// 角色最大血量
    /// </summary>
    FP maxHP;

    /// <summary>
    /// 角色当前魔量
    /// </summary>
    FP curMP;

    /// <summary>
    /// 角色最大魔量
    /// </summary>
    FP maxMP;

    /// <summary>
    /// 角色移动速度
    /// </summary>
    FP speed;

    /// <summary>
    /// 角色攻击速度
    /// </summary>
    FP attackSpeed;
}
