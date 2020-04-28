using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PureMVC.Patterns;

public class FakeServerDataProxy : Proxy
{
    public new const string NAME = "FakeServerData";

    public FakeServerDataProxy(object data) : base(NAME, data) {
        
    }

}
