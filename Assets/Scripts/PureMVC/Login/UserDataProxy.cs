using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PureMVC.Patterns;

public class UserDataProxy : Proxy
{
    public new const string NAME = "UserData";
    
    public UserDataProxy(object data) : base(NAME, data) {
        
    }

    public void SetProperty(UserDataModel newModel) {
        ((UserDataModel)Data).account = newModel.account;
        ((UserDataModel)Data).password = newModel.password;
        Debug.Log("UserDataProxy SetProperty(): " + ((UserDataModel)Data).account + ", " + ((UserDataModel)Data).password);
    }

    public void SetProperty(string email, string password) {
        ((UserDataModel)Data).account = email;
        ((UserDataModel)Data).password = password;
        Debug.Log("UserDataProxy: SetProperty()" + ((UserDataModel)Data).account + ", " + ((UserDataModel)Data).password);
    }

}
