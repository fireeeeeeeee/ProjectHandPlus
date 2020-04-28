using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using GameProto;

public struct ServerEventData {
    public ServerEventCode code;
    // 如果未来服务器发来的消息也只有ServerMsg类型也可以考虑直接把data改为ServerMsg类型
    public object data;
}

//public struct GLEventData {
//    public GLEventCode code;
//    public object data;
//}

public delegate void ServerEventCallback(object data);
//public delegate void GLEventCallback(object data);

public class MessageCenter : SingletonMonoBehaviour<MessageCenter> {

    private Dictionary<ServerEventCode, ServerEventCallback> ServerEventDict = new Dictionary<ServerEventCode, ServerEventCallback>();
    public Queue<ServerEventData> ServerDataQueue = new Queue<ServerEventData>();

    public void AddObserver(ServerEventCode code, ServerEventCallback callback) {
        if (ServerEventDict.ContainsKey(code)) {
            ServerEventDict[code] += callback;
        } else {
            ServerEventDict.Add(code, callback);
        }
    }

    public void RemoveObserver(ServerEventCode code, ServerEventCallback callback) {
        if (ServerEventDict.ContainsKey(code)) {
            ServerEventDict[code] -= callback;
            if (ServerEventDict[code] == null) {
                ServerEventDict.Remove(code);
            }
        }
    }

    void Update()
    {
        while (ServerDataQueue.Count > 0) {
            lock (ServerDataQueue) {
                ServerEventData tmpServerEventData = ServerDataQueue.Dequeue();
                if (ServerEventDict.ContainsKey(tmpServerEventData.code)) {
                    ServerEventDict[tmpServerEventData.code](tmpServerEventData.data);
                }
            }
        }
    }
}
