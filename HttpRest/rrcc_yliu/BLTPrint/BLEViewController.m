//
//  BLEViewController.m
//  rrcc_distribution
//
//  Created by lawwilte on 9/21/15.
//  Copyright © 2015 ting liu. All rights reserved.
//

#import "BLEViewController.h"

#import "BleManager.h"
#import "BlePeripheral.h"
#import "Commom.h"
#import "Header.h"
#import "BltPrintFormat.h"



@interface BLEViewController ()<UITableViewDelegate,UITableViewDataSource,BleManagerDelegate>{
    
    BleManager    *m_bleManager;
    BlePeripheral *m_current_peripheral;
    CBPeripheral  *ConnectPeripheral;
    NSMutableArray *peripherals;
    __weak IBOutlet UIView *periphereView;//设备backView
    NSTimer *m_timer_threesec;  //3s扫描定时器
    NSTimer *m_timer_Connect;   //10s连接定时器
}

@property (weak, nonatomic) IBOutlet UITableView *peripheralTable;

@end

@implementation BLEViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:@"BLEViewController" bundle:nibBundleOrNil];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"蓝牙打印";
    periphereView.backgroundColor = RGBACOLOR(2, 207, 65, 1);
    self.peripheralTable.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void)viewWillAppear:(BOOL)animated{
    m_bleManager = [BleManager shareInstance];
    m_bleManager.mange_delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated{
    m_bleManager.mange_delegate = nil;
}


-(void)scanresult{
    [_peripheralTable reloadData];
}


#pragma mark -table委托 table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [m_bleManager.m_array_peripheral count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.peripheralTable dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (m_bleManager.m_array_peripheral.count >0){
        BlePeripheral *peripheral = [m_bleManager.m_array_peripheral objectAtIndex:indexPath.row];
        cell.textLabel.text =  [NSString stringWithFormat:@"Name:%@",peripheral.m_peripheralLocaName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"UUID:%@",peripheral.m_peripheralUUID];
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //停止扫描
    [m_timer_threesec invalidate];
    BlePeripheral *peripheral = [m_bleManager.m_array_peripheral objectAtIndex:indexPath.row];
    [m_bleManager.m_manger connectPeripheral:peripheral.m_peripheral options:nil];
    [[Commom sharedInstance] setCurrentPeripheral:peripheral.m_peripheral];
    [m_bleManager.m_manger stopScan];
    ConnectPeripheral = peripheral.m_peripheral;
}


#pragma mark_BleManagerDelegate
-(void)bleMangerConnectedPeripheral:(BOOL)isConnect{
    if (isConnect == YES){
        [m_timer_Connect invalidate];
        [m_bleManager.m_manger stopScan];
        [[[UIAlertView alloc] initWithTitle:@"蓝牙设备已连接" message: @"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil] show];
        [BltPrintFormat ShareBLTPrint].ConnectState = @"1";
    }
}


-(void)bleMangerReceiveDataPeripheralData:(NSData *)data from_Characteristic:(CBCharacteristic *)curCharacteristic{
    
    NSLog(@"接收到外设特征值为:%@ 发送的数据:%@",[curCharacteristic.UUID  UUIDString],data);

}

-(void)bleMangerDisConnectedPeripheral:(CBPeripheral *)_peripheral{
    
    if ([_peripheral isEqual:[Commom sharedInstance].currentPeripheral]){
        [[[UIAlertView alloc] initWithTitle:@"设备已失去连接" message: @"请重新连接!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil] show];
        [BltPrintFormat ShareBLTPrint].ConnectState = @"0";
        [self scanPeripheralResule:nil]; //调用扫描
    }
}


-(void)connectPeripheralFailed{
    [self scanPeripheralResule:nil];
}


#pragma mark ButtonAction
-(IBAction)scanPeripheralResule:(UIButton*)sender{
    
    NSArray *services = [[NSArray alloc]init];
    [m_bleManager.m_manger scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES,CBCentralManagerScanOptionSolicitedServiceUUIDsKey : services }];
    m_timer_threesec=[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(scanresult) userInfo:nil repeats:YES];
}


-(IBAction)disConnect:(UIButton*)sender{
    
    [[BleManager shareInstance] disConnectPeripheral];
}


#pragma mark 打印订单详情

-(void)PrintWithInfoDic:(NSDictionary *)InfoDic{
    [self PrintOrderInfo:InfoDic];
}


#pragma 打印订单详情
-(void)PrintOrderInfo:(NSDictionary*)PrintDic{
    
    //订单标题
    NSString *Title;
    NSString *string1 = @"人人菜场\n\n";
    Title = [[BltPrintFormat ShareBLTPrint] PrintTitleInCenter:string1];
    //鲜店名称
    [[Utility Share] readUserInfoFromDefault];
    NSDictionary *StoreDic = nil;//[[Utility Share]storeDic];
    NSString *StoreStr;
    NSString *StoreName = [NSString stringWithFormat:@"%@%@\n",@"鲜店: ",[StoreDic objectForJSONKey:@"shop_name"]];
    
    StoreStr = [[BltPrintFormat ShareBLTPrint] PrintTitleInCenter:StoreName];
    //分割线
    NSString *StarsHader  = [NSString stringWithFormat:@"%@\n",@"********************************"];
    NSString *StarsFoot   = [NSString stringWithFormat:@"%@\n",@"********************************"];
    NSString *StarsEnd    = [NSString stringWithFormat:@"%@\n",@"********************************"];
    //订单号
    NSString *OrderCode   = [NSString stringWithFormat:@"订单: %@\n",[[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"ordercode"]];
    //用户名字
    NSString *CustomerName = [NSString stringWithFormat:@"姓名: %@\n",[[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"contact"]];
    //手机号
    NSString *TelNumber  = [NSString stringWithFormat:@"手机: %@\n",[[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"tel"]];
    //地址
    NSString *Address    = [NSString stringWithFormat:@"地址: %@\n",[[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"address"]];
    //预约时间
    NSString *Svtime     = [NSString stringWithFormat:@"预约时间: %@\n",[[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"svtime"]];
    //商品列表标题
    NSString *OrderTitle = [NSString stringWithFormat:@"%@%@%@%@\n",@" 产品  ",@"  规格  ",@"  数量  ",@"  小计"];
    //商品列表
    NSMutableArray *Names = [[NSMutableArray alloc] init];
    NSMutableArray *Nums  = [[NSMutableArray alloc] init];
    NSMutableArray *Prices= [[NSMutableArray alloc] init];
    NSMutableArray *Weight= [[NSMutableArray alloc] init];
    NSMutableArray *ItemList = [[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"itemList"];
    for (int i = 0;i<ItemList.count;i++){
        NSString *NameStr = [[ItemList objectAtIndex:i] objectForJSONKey:@"skuname"];
        [Names addObject:NameStr];
        
        NSString *NumStr  = [[ItemList objectAtIndex:i] objectForJSONKey:@"ordercount"];
        [Nums addObject:NumStr];
        
        NSString *PriceStr = [[ItemList objectAtIndex:i] objectForJSONKey:@"price"];
        [Prices addObject:PriceStr];
        
        NSString *WeightStr= [[ItemList objectAtIndex:i] objectForJSONKey:@"avgweight"];
        [Weight addObject:WeightStr];
    }
    //商品列表
    NSString *ListStr = [[BltPrintFormat ShareBLTPrint] AppendNames:Names Nums:Nums Prices:Prices Weight:Weight];
    //发货数量
    //计算物品的订单个数
    NSInteger numCoun = 0;
    for (int i=0;i<Nums.count;i++){
        NSInteger num = [[Nums objectAtIndex:i]  integerValue];
        numCoun   += num;
    }
    NSString *ItemCount =  [NSString stringWithFormat:@"%@%ld\n",@"发货数量: ",(unsigned long)numCoun];
    //支付方式
    NSString *PaymentStr ;
    if ([[[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"payment"] isEqualToString:@"1"]){
        PaymentStr = @"支付方式: 现金支付\n";
    }else{
        PaymentStr = @"支付方式: 在线支付\n";
    }
    //总付金额
    NSString *TotalPrice = [[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"price"];
    NSString *TotalPriceStr = [NSString stringWithFormat:@"%@%@\n",@"总付金额: ￥",TotalPrice];
    //赠品活动
    NSString *Gift = [[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"gift"];
    //测试
    NSString *GiftStr;
    if (Gift.length !=0){
        GiftStr = [NSString stringWithFormat:@"%@%@\n",@"赠品活动: ",Gift];
    }else{
        GiftStr = @"";
    }
    //红包抵扣
    float Voucher  = [[[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"voucher"] floatValue];
    NSString *VoucherStr;
    if (Voucher !=0){
        VoucherStr = [NSString stringWithFormat:@"%@%.2f\n",@"红包抵扣: -￥",Voucher];
    }else{
        VoucherStr = @"";
    }
    //预售折扣
    float presell_discount = [[[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"presell_discount"]floatValue];
    NSString *PresellStr;
    if (presell_discount !=0){
        PresellStr = [NSString stringWithFormat:@"%@%.2f\n",@"预售折扣: -￥",presell_discount];
    }else{
        PresellStr = @"";
    }
    //满减活动金额
    float Discount = [[[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"discount"] floatValue];
    NSString *DiscountStr;
    if (Discount != 0){
        DiscountStr  = [NSString stringWithFormat:@"%@%@%.2f\n",@"满减活动:",@" -￥",Discount];
    }else{
        DiscountStr = @"";
    }
    //实付金额
    NSString *CustPrice = [[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"custprice"];
    NSString *ActPriceStr  = [NSString stringWithFormat:@"%@%@\n",@"实付金额: ￥",CustPrice];
    //备注信息
    NSString *Remarkinfo = [[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"remark"];
    NSString *RemarkStr;
    if (Remarkinfo.length == 0){
        RemarkStr = @"订单备注:\n";
    }else{
        RemarkStr = [NSString stringWithFormat:@"%@%@\n",@"订单备注: ",[[PrintDic objectForJSONKey:@"CallInfo"] objectForJSONKey:@"remark"]];
    }
    //欢迎语句
    NSString *Welcom = [NSString stringWithFormat:@"%@\n",@"非常感谢您光临本店!"];
    //客服电话
    NSString *ServerTime = [NSString stringWithFormat:@"%@\n",@"客服电话: 4000285927"];
    //打单日期
    NSString *PrintTime = [NSString stringWithFormat:@"%@%@\n",@"打单日期: ",[[Utility Share] GetNowTime]];
    
    //打印的字符串
    NSArray *PrintArray = @[Title,StoreStr,StarsHader,OrderCode,CustomerName,TelNumber,Address,Svtime,StarsFoot,OrderTitle,ListStr,@"\n",ItemCount,PaymentStr,TotalPriceStr,DiscountStr,GiftStr,VoucherStr,PresellStr,ActPriceStr,RemarkStr,StarsEnd,Welcom,ServerTime,PrintTime];
    NSString *PrintStr = [PrintArray componentsJoinedByString:@""];
    if ([PrintStr length]){
        NSString *printed = [PrintStr  stringByAppendingFormat:@"%c%c%c", '\n', '\n', '\n'];
        [self PrintWithFormat:printed];
    }
}

- (void)doPrintWithInfoDic:(NSMutableDictionary *)infoDic {
    
    //订单标题
    NSString *Title;
    NSString *string1 = @"鲜店\n\n";
    Title = [[BltPrintFormat ShareBLTPrint] PrintTitleInCenter:string1];
    
    //鲜店名称
    NSString *StoreStr;
    NSString *StoreName = [NSString stringWithFormat:@"%@%@\n",@"鲜店名称: ",infoDic[@"clientname"]];
    
    StoreStr = [[BltPrintFormat ShareBLTPrint] PrintTitleInCenter:StoreName];
    //分割线
    NSString *StarsHader  = [NSString stringWithFormat:@"%@\n",@"********************************"];
    NSString *StarsFoot   = [NSString stringWithFormat:@"%@\n",@"********************************"];
    NSString *StarsEnd    = [NSString stringWithFormat:@"%@\n",@"********************************"];
    //订单号
    NSString *OrderCode   = [NSString stringWithFormat:@"订单号: %@\n",infoDic[@"ordercode"]];
    //用户名字
    NSString *CustomerName = [NSString stringWithFormat:@"店主姓名: %@\n",infoDic[@"contact"]];
    //手机号
    NSString *TelNumber  = [NSString stringWithFormat:@"店主手机: %@\n",infoDic[@"tel"]];
    
    //商品列表标题
    NSString *OrderTitle = [NSString stringWithFormat:@"%@%@%@%@\n",@" 产品  ",@"  规格  ",@"  数量  ",@"  小计"];
    //商品列表
    NSMutableArray *Names = [[NSMutableArray alloc] init];
    NSMutableArray *Nums  = [[NSMutableArray alloc] init];
    NSMutableArray *Prices= [[NSMutableArray alloc] init];
    NSMutableArray *Weight= [[NSMutableArray alloc] init];
    NSMutableArray *ItemList = infoDic[@"itemlist"];
    
    [ItemList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ProductsModel *model = (ProductsModel *)obj;
        [Names addObject:model.skuname];
        [Nums addObject:model.ordercount];
        [Prices addObject:model.total];//price
        [Weight addObject:model.avgweight];
    }];
    
    //商品列表
    NSString *ListStr = [[BltPrintFormat ShareBLTPrint] AppendNames:Names Nums:Nums Prices:Prices Weight:Weight];
    //发货数量
    //计算物品的订单个数
    NSInteger numCoun = 0;
    for (int i=0;i<Nums.count;i++){
        NSInteger num = [[Nums objectAtIndex:i]  integerValue];
        numCoun   += num;
    }
    NSString *ItemCount =  [NSString stringWithFormat:@"%@%ld\n",@"发货数量: ",(unsigned long)numCoun];
    
    //配送方式
    NSString *DeliveryTitle = [NSString stringWithFormat:@"配送方式: %@\n",infoDic[@"delivery_title"]];
    //配送地址
    NSString *Address    = [NSString stringWithFormat:@"配送地址: %@\n",infoDic[@"order_address"]];
    //预约时间
    NSString *Svtime     = [NSString stringWithFormat:@"配送时间: %@\n",infoDic[@"svtime"]];

    
    //支付方式
    NSString *PaymentStr = [NSString stringWithFormat:@"支付方式: %@\n",infoDic[@"payment_title"]];
    
    //总付金额
    NSString *TotalPriceStr = [NSString stringWithFormat:@"%@%@\n",@"总付金额: ￥",infoDic[@"price"]];
    //赠品活动
    NSString *Gift = infoDic[@"gift"];
    
    //测试
    NSString *GiftStr;
    if (Gift.length !=0){
        GiftStr = [NSString stringWithFormat:@"%@%@\n",@"赠品活动: ",Gift];
    }else{
        GiftStr = @"";
    }
    
    //红包抵扣
    float Voucher  = [infoDic[@"voucher"] floatValue];
    NSString *VoucherStr;
    if (Voucher !=0){
        VoucherStr = [NSString stringWithFormat:@"%@%.2f\n",@"红包抵扣: -￥",Voucher];
    }else{
        VoucherStr = @"";
    }
    
    //预售折扣
    float presell_discount = [infoDic[@"presell_discount"] floatValue];
    NSString *PresellStr;
    if (presell_discount !=0){
        PresellStr = [NSString stringWithFormat:@"%@%.2f\n",@"预售折扣: -￥",presell_discount];
    }else{
        PresellStr = @"";
    }
    
    //满减活动金额
    float Discount = [infoDic[@"discount"] floatValue];
    NSString *DiscountStr;
    if (Discount != 0){
        DiscountStr  = [NSString stringWithFormat:@"%@%@%.2f\n",@"满减活动:",@" -￥",Discount];
    }else{
        DiscountStr = @"";
    }
    
    //实付金额
    NSString *ActPriceStr  = [NSString stringWithFormat:@"%@%@\n",@"实付金额: ￥",infoDic[@"custprice"]];
    //备注信息
    NSString *Remarkinfo = infoDic[@"remark"];
    NSString *RemarkStr;
    if (Remarkinfo.length == 0){
        RemarkStr = @"订单备注: 无\n";
    }else{
        RemarkStr = [NSString stringWithFormat:@"%@%@\n",@"订单备注: ",Remarkinfo];
    }
    
    //欢迎语句
    NSString *Welcom = [NSString stringWithFormat:@"%@\n",@"非常感谢您光临本店!"];
    //客服电话
    NSString *ServerTime = [NSString stringWithFormat:@"%@\n",@"客服电话: 4000285927"];
    //打单日期
    NSString *PrintTime = [NSString stringWithFormat:@"%@%@\n",@"打单日期: ",[[Utility Share] GetNowTime]];
    
    //打印的字符串
    NSArray *PrintArray = @[Title,StoreStr,StarsHader,OrderCode,CustomerName,TelNumber,StarsFoot,OrderTitle,ListStr,@"\n",ItemCount,DeliveryTitle,Address,Svtime,PaymentStr,TotalPriceStr,DiscountStr,GiftStr,VoucherStr,PresellStr,ActPriceStr,RemarkStr,StarsEnd,Welcom,ServerTime,PrintTime];
    NSString *PrintStr = [PrintArray componentsJoinedByString:@""];
    if ([PrintStr length]){
        NSString *printed = [PrintStr  stringByAppendingFormat:@"%c%c%c", '\n', '\n', '\n'];
        [self PrintWithFormat:printed];
    }

    
}


- (void) PrintWithFormat:(NSString *)printContent{
#define MAX_CHARACTERISTIC_VALUE_SIZE 32
    NSData  *data	= nil;
    NSUInteger i;
    NSUInteger strLength;
    NSUInteger cellCount;
    NSUInteger cellMin;
    NSUInteger cellLen;
    Byte caPrintFmt[5];
    /*初始化命令：ESC @ 即0x1b,0x40*/
    caPrintFmt[0] = 0x1b;
    caPrintFmt[1] = 0x40;
    /*字符设置命令：ESC ! n即0x1b,0x21,n*/
    caPrintFmt[2] = 0x1b;
    caPrintFmt[3] = 0x21;
    caPrintFmt[4] = 0x00;
    NSData *cmdData =[[NSData alloc] initWithBytes:caPrintFmt length:5];
    [[BleManager shareInstance] sendData:cmdData type:CBCharacteristicWriteWithResponse];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    strLength = [printContent length];
    if (strLength < 1) {
        return;
    }
    cellCount = (strLength%MAX_CHARACTERISTIC_VALUE_SIZE)?(strLength/MAX_CHARACTERISTIC_VALUE_SIZE + 1):(strLength/MAX_CHARACTERISTIC_VALUE_SIZE);
    for (i=0; i<cellCount; i++) {
        cellMin = i*MAX_CHARACTERISTIC_VALUE_SIZE;
        if (cellMin + MAX_CHARACTERISTIC_VALUE_SIZE > strLength) {
            cellLen = strLength-cellMin;
        }else {
            cellLen = MAX_CHARACTERISTIC_VALUE_SIZE;
        }
        NSRange rang = NSMakeRange(cellMin, cellLen);
        NSString *strRang = [printContent substringWithRange:rang];
        data = [strRang dataUsingEncoding: enc];
        [[BleManager shareInstance] sendData:data type:CBCharacteristicWriteWithResponse];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
