# Project Hand Plus
A online co-op game made with Unity Engine.



### 小组成员

陈柏铭 / 廖青山 / 孙宋源 / 王梓涵 / 应尚威 / 章朝哲

客户端开发：陈柏铭 / 王梓涵 / 应尚威 / 章朝哲

服务端开发：廖青山 / 孙宋源

&nbsp;

### 客户端文件组织（暂定）

**实现的功能在此处进行说明**

**[ Scripts / ]**存放一般（无法归入下列分类）的脚本

**[ Scripts / Protoc / ]** 存放Protoc文件

**[ Scripts / Managers / ]** 存放单例Manager，在PureMVC框架下应该不多

MessageCenter -> 可对网络事件进行监听的事件系统，由于客户端本地事件由Facade内部通知系统实现，消息中心不提供对客户端本地事件进行监听的功能

NetManager -> 连接服务器，发送消息，接收来自服务器消息

**[ Scripts / PureMVC / StartUp/ ]**该模块下的Launcher.cs脚本初始化客户端必要的单例，与服务端建立连接，连接ip地址与端口port可以在Login场景Inspector指定 

**[ Scripts / PureMVC / 需求A / … / ]** 根据需求存放Proxy、Model、View、Meidator、Command等脚本，**如出现复用情况放在其中一处即可，最好在此处进行说明**

需求A 复用 需求B xxx.cs 脚本

&nbsp;

### PureMVC使用笔记【补充修正欢迎】

#### **对应关系**

Model(存储数据)   <------   Proxy(提供编辑数据的方法，处理仅于所属数据有关的域逻辑) 

View(存储UI组件的引用)   <------   Mediator(监听指定通知，对UI组件进行编辑)

Command：特定通知到来时处理对应的业务逻辑

Facade(发音注意 /fə'sɑ:d/)：

初始化Model / View / Controller，初始注册Proxy / Mediator / Command

*业务逻辑：不完全被归为纯数据、纯UI的逻辑，或是两边都不沾边的逻辑

&nbsp;

#### 对应访问对象

**Facade：** 外部脚本可以通过Facade类的单例对象发送通知

YourFacade.GetInstance().SendNotification()

存在Facade对象的脚本可以：

1. 发送事件 Facade.SendNotification()
2. 注册组件 Facade.RegisterProxy() / Facade.RegisterMediator() / Facade.RegisterCommand()
3. 注销组件 Facade.RemoveProxy() / Facade.RemoveMediator()  / Facade.RemoveCommand()
4. 获取组件 Facade.RetrieveProxy() / Facade.RetrieveMediator()

&nbsp;

**Model、View、Controller：**

Model、View为用户自己定义的数据结构，一般不需要定义方法，所以也不存在访问问题，Controller在目前看到的项目里就只是Command的概念集合，不存在脚本（不确定）

&nbsp;

**Proxy：**

**存在Facade引用对象**

类内Data对象可以存放对应Model的引用，在构造函数中赋值

当存在多个Model（如多个玩家的数据）可以自己定义Model引用的数组，Proxy和Model的多对一关系是因为对同样的数据结构所采取的处理方式是相同的

**注意事项：** 尽量不获取Mediator。Model层不关心View层的表现，不应该在这里获取并使用Mediator，而是利用发送通知的方法进行View层更新

&nbsp;

**Mediator：**

**存在Facade引用对象**

类内ViewComponent对象可以存放对应View的引用，在构造函数中赋值

当存在多个View可以自己定义View引用的数组，跟上面一样的意思

**注意事项：** 可以读取Proxy，但不建议通过Proxy编辑Model层。此场景大多数情况下属于事务逻辑，建议发送通知后交给指定的Command来处理。

&nbsp;

**Command：**

**存在Facade引用对象**

Command的生命周期相对较短，在通知到来时创建，所以Facade也没有对应的Retrieve方法

&nbsp;

#### 收发通知

可以发送通知的：Proxy / Mediator / Command / Facade

可以监听（处理）通知的：Mediator（在ListNotificationInterests方法中指定），Command（通过Facade对象指定）

示例：

```c#
// LoginPanelMediator.cs 指定
public override IList<string> ListNotificationInterests() {
        return new List<string>() { MyFacade.LoginSucceed, MyFacade.LoginFailed};
    }

// LoginPanelMediator.cs 处理通知
public override void HandleNotification(INotification notification) {
        switch (notification.Name) {
            case MyFacade.LoginSucceed:
                ((LoginPanelView)ViewComponent).messageText.text = "succeed";
                break;
            case MyFacade.LoginFailed:
                ((LoginPanelView)ViewComponent).messageText.text = "failed";
                break;
            default:
                break;
        }
    }
    
// MyFacade.cs
protected override void InitializeController() {
        base.InitializeController();
        RegisterCommand(StartUp, typeof(StartUpCommand));
        RegisterCommand(Login, typeof(LoginCommand));
    }
// 其他组件也可通过Facade.RegisterCommand
```

