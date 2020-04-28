using Google.Protobuf;
using GameProto;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using UnityEngine;

public static class Endian {
    public static short SwapInt16(this short n) {
        return (short)(((n & 0xff) << 8) | ((n >> 8) & 0xff));
    }

    public static ushort SwapUInt16(this ushort n) {
        return (ushort)(((n & 0xff) << 8) | ((n >> 8) & 0xff));
    }

    public static int SwapInt32(this int n) {
        return (int)(((SwapInt16((short)n) & 0xffff) << 0x10) |
        (SwapInt16((short)(n >> 0x10)) & 0xffff));
    }

    public static uint SwapUInt32(this uint n) {
        return (uint)(((SwapUInt16((ushort)n) & 0xffff) << 0x10) |
        (SwapUInt16((ushort)(n >> 0x10)) & 0xffff));
    }

    public static long SwapInt64(this long n) {
        return (long)(((SwapInt32((int)n) & 0xffffffffL) << 0x20) |
        (SwapInt32((int)(n >> 0x20)) & 0xffffffffL));
    }

    public static ulong SwapUInt64(this ulong n) {
        return (ulong)(((SwapUInt32((uint)n) & 0xffffffffL) << 0x20) |
        (SwapUInt32((uint)(n >> 0x20)) & 0xffffffffL));
    }
}

public class NetworkManager : SingletonMonoBehaviour<NetworkManager>
{
    #region Variables
    private readonly byte HEADLEN = 5;
    private readonly byte PREFIXLEN = 1;
    private string curIp;
    private int curPort;
    private bool isConnected = false;

    private Socket clientSocket = null;
    private Thread receiveThread = null;

    private const int BUFFSIZE = 4096;
    private byte[] buffer = new byte[BUFFSIZE];
    private int recv_p = 0, work_p = 0;

    #endregion

    private void _Close() {
        if (!isConnected) return;
        isConnected = false;
        if (receiveThread != null) {
            receiveThread.Abort();
            receiveThread = null;
        }

        if (clientSocket != null && clientSocket.Connected) {
            clientSocket.Close();
            clientSocket = null;
        }
    }

    public void Close() {
        _Close();
    }

    private void OnConnectSuccess(IAsyncResult iar) {
        try {
            Socket client = (Socket)iar.AsyncState;
            client.EndConnect(iar);
            receiveThread = new Thread(new ThreadStart(ReceiveMessage));
            receiveThread.IsBackground = true;
            receiveThread.Start();
            isConnected = true;
            Debug.Log("Successfully connected with " + curIp);
        } catch (Exception) {
            _Close();
        }
    }

    private void OnConnectTimeout() {
        Debug.LogWarning("Connection Timeout!");
        _Close();
    }

    private void OnConnectFail() {
        Debug.LogWarning("Connection Failed!");
        _Close();
    }

    private void OnConnect() {
        try {
            clientSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            IPAddress ipAddress = IPAddress.Parse(curIp);
            IPEndPoint ipEndpoint = new IPEndPoint(ipAddress, curPort);
            // async connect
            IAsyncResult result = clientSocket.BeginConnect(ipEndpoint, new AsyncCallback(OnConnectSuccess), clientSocket);
            bool success = result.AsyncWaitHandle.WaitOne(5000, true);
            if (!success) {
                OnConnectTimeout();
            }
        } catch (Exception exp) {
            Debug.LogError("OnConnect():" + exp.Message);
            OnConnectFail();
        }
    }

    public void Connect(string _curIp, int _curPort) {
        if (!isConnected) {
            curIp = _curIp;
            curPort = _curPort;
            OnConnect();
        }
    }

    private void ReConnect() {
        if (!isConnected) {
            OnConnect();
        }
    }

    // 从服务器接收信息的独立线程
    public void ReceiveMessage() {
        while (true) {
            if (!clientSocket.Connected) {
                isConnected = false;
                ReConnect();
                break;
            }
            try {
                int ret = clientSocket.Receive(buffer, recv_p, BUFFSIZE - recv_p, SocketFlags.None);
                recv_p += ret;
                if (recv_p >= BUFFSIZE) {
                    // 接收到的消息超出缓冲区，拷贝到缓冲区起始位置
                    //Debug.LogFormat("OUT OF BUFFER {0} -> {1}, move to 0 -> {2} ", work_p, recv_p, ret);
                    Buffer.BlockCopy(buffer, work_p, buffer, 0, ret);
                    work_p = 0;
                    recv_p = ret;
                    continue;
                }
                while (work_p < recv_p) {
                    // 目前没有用处的标志号
                    byte prefix = buffer[work_p];
                    uint length = BitConverter.ToUInt32(buffer, work_p+PREFIXLEN);

                    // 本次接收到的消息不完整，加上下一次的消息一起处理
                    if (recv_p - work_p < length + HEADLEN) break;

                    Debug.LogFormat("ReceiveMessage: prefix: {0}, length: {1}", prefix, length);
                    byte[] content = new byte[length];
                    Buffer.BlockCopy(buffer, work_p + HEADLEN, content, 0, (int)length);

                    try {
                        ServerMsg msg = ServerMsg.Parser.ParseFrom(content);
                        Debug.LogFormat("Message Received: type={0} fid={1} str={2}", msg.Type, msg.Fid, msg.Str);
                        // 将消息存放到消息中心，在MyFacade脚本中监听感兴趣的消息并发送通知
                        // 已测试不可通过MyFacde.GetInstance().SendNotification()发送信息，与ReceiveMesaage()作为独立线程有关
                        ServerEventData serverEventData = new ServerEventData {
                            code = msg.Type,
                            data = msg
                        };
                        MessageCenter.Instance.ServerDataQueue.Enqueue(serverEventData);
                        
                    } catch (InvalidProtocolBufferException exp) {
                        Debug.LogErrorFormat("{0} Parsing failed ReceiveMessage() ", exp.Message);
                    }

                    work_p += HEADLEN + (int)length;
                }
            } catch (Exception exp) {
                if (clientSocket != null && clientSocket.Connected) {
                    Debug.LogWarning("ReceiveNetMessage():" + exp.Message);
                    clientSocket.Close();
                    clientSocket = null;
                }
                break;
            }
        }
    }

    // 向服务器发送信息的统一方法
    public void Send(ByteString data) {
        try {
            // Debug.Log(data.ToStringUtf8());
            byte[] content = data.ToByteArray();
            uint length = (uint)content.Length;
            // 暂时无用标志号
            byte version = 0;
            byte[] length2byte = BitConverter.GetBytes(length);
            byte[] pack = new byte[HEADLEN + content.Length];

            pack[0] = version;
            length2byte.CopyTo(pack, PREFIXLEN);
            content.CopyTo(pack, HEADLEN);

            // Debug.Log(pack.Length);
            clientSocket.Send(pack);
        } catch (Exception exp) {
            Debug.LogError("Send(): " + exp.Message);
        }
    }

    protected override void OnDestroy() {
        _Close();
        base.OnDestroy();
    }

    private void OnApplicationQuit() {
        _Close();
    }
}
