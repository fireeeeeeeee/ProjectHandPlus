using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PureMVC.Patterns;
using GameProto;
using Google.Protobuf;
using System;

public class MyFacade : Facade {
    public const string StartUp = "start_up";
    public const string Login = "login";
    public const string Register = "register";
    public const string RegisterSuccess = "register_succeed";
    public const string RegisterFailure = "register_failed";
    public const string LoginSuccess = "login_succeed";
    public const string LoginFailure = "login_failed";

    public const string TestBattleStartUp = "test_battle_start_up";


    //战斗操作指令(上传用)
    public const string BattleUI = "battle_ui";
    public const string CharacterViewUpdata = "character_view_updata";

    //角色信息帧更新
    public const string CharactersFrameUpdata = "characters_frame_updata";


    //客户端上传帧操作
    public const string C2SPlayerInput = "c2s_player_input";

    //假客户端操作
    public const string FakeServer = "fake_server";

    //房间相关
    public const string RefreshRoomList = "refreshRoomList";
    public const string CreatRoom = "creatRoom";
    public const string EnterRoom = "enterRoom";
    public const string ExitRoom = "exitRoom";
    public const string EnterRoomSuccess = "enterRoomSuccess";
    public const string EnterRoomFail = "enterRoomFail";
    public const string CreatRoomSuccess = "creatRoomSuccess";
    public const string CreatRoomFail = "creatRoomFail";
    public const string ChangeRoomPlayerInfo = "ChangeRoomPlayerInfo";
    public const string RefreshRoomInfo = "refreshRoomInfo";
    public const string StartGame = "startGame";
    public const string StartGameSuccess = "startGameSuccess";
    public const string StartGameFail = "startGameFail";

    static MyFacade() {
        m_instance = new MyFacade();
    }

    public static MyFacade GetInstance() {
        return m_instance as MyFacade;
    }

    protected override void InitializeController() {
        base.InitializeController();
        RegisterCommand(StartUp, typeof(StartUpCommand));
        RegisterCommand(Login, typeof(LoginCommand));

        RegisterCommand(BattleUI, typeof(BattleUICommand));
        RegisterCommand(CharactersFrameUpdata, typeof(CharactersFrameUpdataCommand));

        RegisterCommand(C2SPlayerInput, typeof(C2SPlayerInputCommand));


        //注册假服务器命令
        RegisterCommand(FakeServer, typeof(FakeServerCommand));
        //注册测试用场景启动命令
        RegisterCommand(TestBattleStartUp, typeof(TestBattleStartUpCommand));

        //RegisterCommand(CharacterViewUpdata)

        // 从消息中心监听服务器发来的事件，将服务器发来的消息存入消息中心由NetworkManager完成

        RegisterCommand(Register, typeof(RegisterCommand));

        //房间相关
        RegisterCommand(RefreshRoomList, typeof(RefreshRoomListCommand));
        RegisterCommand(CreatRoom, typeof(CreatRoomCommand));
        RegisterCommand(EnterRoom, typeof(EnterRoomCommand));
        RegisterCommand(ExitRoom, typeof(ExitRoomCommand));
        RegisterCommand(ChangeRoomPlayerInfo, typeof(ChangeRoomPlayerInfoCommand));
        RegisterCommand(RefreshRoomInfo, typeof(RefreshRoomInfoCommand));
        RegisterCommand(StartGame, typeof(StartGameCommand));
        // 从消息中心监听服务器发来的事件，将服务器发来的消息存入消息中心由NetworkManager完成
        MessageCenter.Instance.AddObserver(GameProto.ServerEventCode.LogInSuccess, OnLoginSucess);
        MessageCenter.Instance.AddObserver(GameProto.ServerEventCode.LogInErrorAccountDontExist, OnLoginFailure);
        MessageCenter.Instance.AddObserver(GameProto.ServerEventCode.LogInErrorPasswordWrong, OnLoginFailure);
        MessageCenter.Instance.AddObserver(GameProto.ServerEventCode.LogInErrorReLogIn, OnLoginFailure);
        MessageCenter.Instance.AddObserver(GameProto.ServerEventCode.RegisterSuccess, OnRegisterSuccess);
        MessageCenter.Instance.AddObserver(GameProto.ServerEventCode.RegisterErrorAccountAlreadyExist, OnRegisterFailure);
        MessageCenter.Instance.AddObserver(GameProto.ServerEventCode.BroadRoomListInfo,OnRefreshRoomList);
        MessageCenter.Instance.AddObserver(GameProto.ServerEventCode.EnterRoomSuccess,OnEnterRoomSuccess);
        MessageCenter.Instance.AddObserver(GameProto.ServerEventCode.CreateRoomSuccess, OnCreatRoomSuccess);
        MessageCenter.Instance.AddObserver(GameProto.ServerEventCode.BroadRoomInfo, OnRefreshRoomInfo);
        MessageCenter.Instance.AddObserver(GameProto.ServerEventCode.StartGameFailure, OnStartGameFailure);
        MessageCenter.Instance.AddObserver(GameProto.ServerEventCode.StartGameSuccess, OnStartGameSuccess);
    }


    protected override void InitializeView() {
        base.InitializeView();
    }

    protected override void InitializeModel() {
        base.InitializeModel();
        RegisterProxy(new UserDataProxy(new UserDataModel()));

        //角色代理注册
        RegisterProxy(new CharactersDataProxy(new CharactersDataModel()));
        //战斗UI代理注册
        RegisterProxy(new BattleUIProxy(new BattleUIModel()));
    }

    private void OnStartGameSuccess(object data)
    {
        SendNotification(StartGameSuccess, data);
    }

    private void OnCreatRoomSuccess(object data)
    {
        SendNotification(CreatRoomSuccess,data);
    }

    private void OnStartGameFailure(object data)
    {
        SendNotification(StartGameFail, data);
    }

    private void OnEnterRoomSuccess(object data)
    {
        SendNotification(EnterRoomSuccess, data);
    }
    private void OnRefreshRoomInfo(object data)
    {
        SendNotification(RefreshRoomInfo, data);
    }

    private void OnRefreshRoomList(object data)
    {
        SendNotification(RefreshRoomList,data);
    }

    private void OnLoginSucess(object data) {
        SendNotification(LoginSuccess, data);
    }

    private void OnLoginFailure(object data) {
        SendNotification(LoginFailure, data);
    }

    private void OnRegisterSuccess(object data) {
        SendNotification(RegisterSuccess);
    }

    private void OnRegisterFailure(object data) {
        SendNotification(RegisterFailure);
    }

}
