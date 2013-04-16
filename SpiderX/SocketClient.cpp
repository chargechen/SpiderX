//
//  SocketClient.cpp
//  SpiderX
//
//  Created by 陈 卓权 on 13-4-14.
//
//
//#include <iostream>
//#include "SocketClient.h"
//#define MAX_RECV_SIZE 1024
//using namespace std;
//#include "cocos2d.h"
//
//
//void SocketClient::init(){
//    const char* serverIp="192.168.1.139";
//    //定义客户端的ip，写客户端的ip
//    int serverPort=9999;
//    //定义客户端的端口
//    //处理异常
//    try {
//        address.SetHostName(serverIp, false);
//        //false的意思是是否用这个ip与网络连接
//        m_socket=new TCPClientSocket(address,serverPort);
//    } catch (SocketException &excep) {
//        cout<<"Socket Exception:"<<(const  char *)excep<<endl;
//    }
//    catch(...){
//        //这是c++里面的例外处理，catch(...)的意思是其他例外的出现
//        cout<<"other error"<<endl;
//    }
//    //socket连接成功
//    /*创建接收数据的线程*/
//    if(pthread_create(&pthead_rec, NULL, reciveData, m_socket)!=0){
//        //pthead_recx线程标示，reciveData回调函数， m_socket传入的参数
//        cout<<"创建reciveData失败"<<endl;
//    }
//}
//void* SocketClient::reciveData(void* pthread){
//    TCPClientSocket *mysocket=(TCPClientSocket*)pthread;
//    while (1) {
//        cout<<"reciveData"<<endl;
//        unsigned char pcRecvBuf[MAX_RECV_SIZE];
//        //在栈中建立的数组，用于盛放接收来的数据
//        try {
//            int iBytesRec=mysocket->RecvData(pcRecvBuf, MAX_RECV_SIZE);
//            cout<<"收到服务端传来"<<iBytesRec<<endl;
//            pcRecvBuf[iBytesRec]=0;
//            // 处理收到的数据，如果他的最后一位是0，则表示接收数据完成
//            cout<<pcRecvBuf<<endl;
//            
//            //客户端向服务器发送信息_c
//            char *_c="ddddddd\n";
//            mysocket->SendData(_c, 8);
//            //发送字符串，字符串长度
//        } catch (SocketException &excep) {
//            cout<<"收到参数意外"<<endl;
//            cocos2d::CCLog("recvDatas Error: %s \n\n",(const char*)excep);
//            
//        }catch (...){
//            cout<<"其他例外"<<endl;
//            cocos2d::CCLog("recvDatas Error\n\n");
//        }
//        cocos2d::CCLog("net disconnect \n\n");
//    }
//    
//}