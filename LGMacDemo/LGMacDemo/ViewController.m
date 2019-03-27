//
//  ViewController.m
//  LGMacDemo
//
//  Created by liangang zhan on 2018/6/25.
//  Copyright © 2018年 liangang zhan. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController()<GCDAsyncSocketDelegate>
//设置一个服务器
@property (nonatomic,strong)GCDAsyncSocket *myService;
@property (nonatomic,strong)NSMutableArray *socketArr;
@end


@implementation ViewController

- (NSMutableArray *)socketArr {
    if (_socketArr == nil) {
        _socketArr = [NSMutableArray array];
    }
    return _socketArr;
}

- (GCDAsyncSocket *)myService {
    if (_myService == nil) {
        _myService = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _myService;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (IBAction)listenToPort:(id)sender {
    NSError *error = nil;
    
    [self.myService acceptOnPort:self.portTextField.intValue error:&error];

    if (error) {
        NSLog(@"error = %@",[error description]);
    }
}
#pragma mark - 断开连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"断开连接 %@",err);
    if ([self.socketArr containsObject:sock]) {
        [self.socketArr removeObject:sock];
    }
}


-(void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"连接");
    [self.socketArr addObject:newSocket];
    NSLog(@"newSocket = %@",newSocket);
    //tag 是新连接socket的标识，新连接socket调用readDataWithTimeout，下次才能接受
    [newSocket readDataWithTimeout:-1 tag:self.socketArr.count];
}

/*
 writeData
 readDataWithTimeout
 需要一一对应

*/

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"-----%@ %ld",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],tag);
    [sock readDataWithTimeout:-1 tag:tag];
    
    //根据Tag 找到该sock,在调用readDataWithTimeout，方便下一次读取数据
    [self.socketArr[(int)tag - 1] readDataWithTimeout:-1 tag:tag];
    NSLog(@"--didRead---%@ %ld",self.socketArr[(int)tag - 1],tag);

    [self sendMessageToOtherPeopleWithData:data sender:sock withTag:tag];
}

- (void)sendMessageToOtherPeopleWithData:(NSData *)data sender:(GCDAsyncSocket *)senderSock withTag:(long)tag{
    GCDAsyncSocket *receSock;
    for (GCDAsyncSocket *sock in self.socketArr) {
        if (sock != senderSock) {
            receSock = sock;
        }
    }
    [receSock writeData:data withTimeout:-1 tag:tag];

}

- (void)socket:(GCDAsyncSocket*)sock didWriteDataWithTag:(long)tag{
    NSLog(@"发送---%@ %ld",sock,tag);
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"已经连接到%@ 端口%d",host,port);

}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
