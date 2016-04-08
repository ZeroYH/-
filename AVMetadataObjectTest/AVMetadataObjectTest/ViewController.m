//
//  ViewController.m
//  AVMetadataObjectTest
//
//  Created by 于仁汇 on 16/3/4.
//  Copyright © 2016年 YRH. All rights reserved.
//

#import "ViewController.h"
#import "YHCapture.h"


@interface ViewController ()<YHCaptureDelegate>
// 声明YHCapture
@property (nonatomic, strong) YHCapture *qrView;
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // 导航按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:(UIBarButtonItemStylePlain) target:self action:@selector(btnEvent:)];
    
    // 创建扫描视图
    self.qrView = [[YHCapture alloc] initWithFrame:self.view.bounds];
    // 设置代理
    _qrView.delegate = self;
    // 添加到视图上
    [self.view addSubview:_qrView];
    
}

// 导航按钮的点击事件
- (void)btnEvent:(UIBarButtonItem *)sender {
    [_qrView imagePickerController];
}

#pragma mark - YHCaptureDelegate
// 通过YHCaptureDelegate代理方法，调用手机相册
- (void)showImagePickerController:(UIImagePickerController *)imagePickerController{
    [self.navigationController presentViewController:imagePickerController animated:YES completion:nil];
}

// 识别完相册中的图片后的代理方法
- (void)finishPickingMediaWithInfo:(NSString *)result{
    NSLog(@"%@", result);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"扫描结果：%@", result] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:true completion:nil];
}

// 扫描完成后的代理方法
- (void)captureView:(YHCapture *)view scanResult:(NSString *)result {
    // 扫描完成后先停止，处理完成后的事件
    [view stopScan];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"扫描结果：%@", result] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // 事件处理完成后再次开启
        [view startScan];
    }]];
    [self presentViewController:alert animated:true completion:nil];
}

@end
