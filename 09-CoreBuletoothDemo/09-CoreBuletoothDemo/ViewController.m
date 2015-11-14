//
//  ViewController.m
//  09-CoreBuletoothDemo
//
//  Created by Tsz on 15/11/14.
//  Copyright © 2015年 Tsz. All rights reserved.
/*

 

 
 
 
 
 
 
 
 断开连接(Disconnect)

 */

#import "ViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>
//遵守管理器协议 和 外围设备设备协议
@interface ViewController () <CBCentralManagerDelegate ,CBPeripheralDelegate>

//1、 建立中心设备
@property (nonatomic , strong)CBCentralManager *manager;

//2、一个存储 外部设备的数组「」
@property (nonatomic , strong)NSMutableArray *peripheralArray;

@end

@implementation ViewController

#pragma mark: 管理器懒加载
- (CBCentralManager *)manager{
    
    if (_manager == nil) {
        //Delegate : 设置代理后, 必须实现一个检测状态方法
        //queue : 如果传空, 将会在主队列
        _manager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    }
    return _manager;
}
#pragma mark: 外部设备数组的懒加载
- (NSMutableArray *)peripheralArray{
    if(!_peripheralArray ){
        _peripheralArray = [NSMutableArray array];
    }
    
    return _peripheralArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
   //2、扫描外围设备
    
    [self.manager scanForPeripheralsWithServices:nil options:nil];
    
}

#pragma mark: ---------------CentralManager的代理方法
// 3、扫描外设（Discover Peripheral）

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    //3.1、扫描到的设备列表 ,存储到数组中
    if (![self.peripheralArray containsObject:peripheral]) {
        [self.peripheralArray addObject:peripheral];
    }
    
     NSLog(@"发现了蓝牙设备");
    
    NSLog(@"%zd",self.peripheralArray.count);
    //3.2、用户选择 蓝牙
    [self didSelectPeripheral:peripheral];
    
}

//4、连接外设(Connect Peripheral)
- (void)didSelectPeripheral:(CBPeripheral *)peripheral{
    
    [self.manager connectPeripheral:peripheral options:nil];
    
}

#pragma mark: 必须实现的方法

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
     NSLog(@"state: %ld",central.state);
}

//负责扫描外设
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    //1、设置外设的代理 --> 一旦连接, 将来的事就移交给外设
    peripheral.delegate = self;
    
    //2、外设扫描服务 设置此方法, 才会调用didDiscoverServices
    [peripheral discoverServices:nil];
}


#pragma mark:--Peripheral的代理方法

//5、扫描外设中的服务和特征(Discover Services And Characteristics)

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    //5.1、遍历服务获取特征
    for(CBService  *service  in  peripheral.services){
        
        //根据UUID 唯一标识码  判断是否是我需要的服务
        if ([service.UUID.UUIDString isEqualToString:@"tsz"]) {
            
            //1、根据 UUID可以查找指定的特性, 如果传 nil, 就代表查找所有特征
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

//6、 当扫描到特征的时候, 会调用的代理方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    //1、遍历特征, 来查找指定的特征  特征是service得属性
    for (CBCharacteristic  *character in service.characteristics) {
        
        if ([character.UUID.UUIDString  isEqualToString:@"hello"]) {
            
            //7、利用特征与外设做数据交互(Explore And Interact)
            [peripheral readValueForCharacteristic:character];
        }
    }
}

//8、断开连接
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //停止扫描
    [self.manager stopScan];
}

@end
