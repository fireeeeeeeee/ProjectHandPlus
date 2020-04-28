using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PureMVC.Patterns;

public class BattleUIProxy : Proxy
{
    public new const string NAME = "BattleUIData";

    public BattleUIProxy(object data) : base(NAME, data)
    {

    }
}
