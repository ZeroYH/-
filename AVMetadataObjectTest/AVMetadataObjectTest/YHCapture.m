//
//  YHCapture.m
//  AVMetadataObjectTest
//
//  Created by 于仁汇 on 16/3/14.
//  Copyright © 2016年 YRH. All rights reserved.
//

#import "YHCapture.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface YHCapture ()<AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation YHCapture {
    //输入输出的中间桥梁
    AVCaptureSession *_session;
    
    // 扫描的框架
    UIImageView *_scanView;
    UIImageView *_lineView;
    
    //
    UIImagePickerController *_picker;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    
    // 扫描区域样子
    // 设置扫描的frame
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat scanW = 200;
    
    CGRect scanFrame = CGRectMake(width / 2. - scanW / 2. , height / 2. - scanW / 2., scanW, scanW);
    _scanViewFrame = scanFrame;
    // 扫描框
    UIImage *scanImage = [UIImage imageNamed:@"scanscanBg"];
    _scanView = [[UIImageView alloc] initWithImage:scanImage];
    _scanView.backgroundColor = [UIColor clearColor];
    _scanView.frame = scanFrame;
    [self addSubview:_scanView];
    
    // 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // 闪光灯
    if ([device hasFlash] && [device hasTorch]) {
        [device lockForConfiguration:nil];
        [device setFlashMode:AVCaptureFlashModeAuto];
        [device setTorchMode:AVCaptureTorchModeAuto];
        [device unlockForConfiguration];
    }
    // 创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    // 创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    // 设置代理 刷新线程
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 扫描采集区域设置
    output.rectOfInterest = [self rectOfInterestByScanViewRect:_scanView.frame];
    // 初始化链接对象
    _session = [[AVCaptureSession alloc] init];
    // 采集率(此处为高质量)
    _session.sessionPreset = AVCaptureSessionPresetHigh;
    
    if (input) {
        [_session addInput:input];
    }
    if (output) {
        [_session addOutput:output];
        // 设置扫码支持的编码格式
        NSMutableArray *array = [NSMutableArray array];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [array addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [array addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [array addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [array addObject:AVMetadataObjectTypeCode128Code];
        }
        
        output.metadataObjectTypes = array;
    }
    // 视频抓屏预览层
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.bounds;
    [self.layer insertSublayer:layer above:0];
    
    [self bringSubviewToFront:_scanView];
    // 添加模糊效果
    [self setOverView];
    // 扫描开始
    [_session startRunning];
    // 线条动画
    [self loopDrawLine];
}

#pragma mark - 扫描采集区域的大小设置
// 扫描采集区域的大小设置
- (CGRect)rectOfInterestByScanViewRect:(CGRect)rect {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat x = (height - CGRectGetHeight(rect)) / 2 / height;
    CGFloat y = (width - CGRectGetWidth(rect)) / 2 / width;
    
    CGFloat w = CGRectGetHeight(rect) / height;
    CGFloat h = CGRectGetWidth(rect) / width;
    
    return CGRectMake(x, y, w, h);
}

#pragma mark - 添加模糊效果
- (void)setOverView {
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    CGFloat x = CGRectGetMinX(_scanView.frame);
    CGFloat y = CGRectGetMinY(_scanView.frame);
    CGFloat w = CGRectGetWidth(_scanView.frame);
    CGFloat h = CGRectGetHeight(_scanView.frame);
    
    [self creatView:CGRectMake(0, 0, width, y)];
    [self creatView:CGRectMake(0, y, x, h)];
    [self creatView:CGRectMake(0, y + h, width, height - y - h)];
    [self creatView:CGRectMake(x + w, y, width - x - w, h)];

}
// 模糊视图
- (void)creatView:(CGRect)rect {
    CGFloat alpha = 0.5;
    UIColor *backColor = [UIColor grayColor];
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = backColor;
    view.alpha = alpha;
    [self addSubview:view];
}

#pragma mark - 线条动画
- (void)loopDrawLine {
    UIImage *lineImage = [UIImage imageNamed:@"scanLine"];
    CGFloat x = CGRectGetMinX(_scanView.frame);
    CGFloat y = CGRectGetMinY(_scanView.frame);
    CGFloat w = CGRectGetWidth(_scanView.frame);
    CGFloat h = CGRectGetHeight(_scanView.frame);
    //用于线条移动
    CGRect start = CGRectMake(x, y, w, 2);
    CGRect end = CGRectMake(x, y + h - 2, w, 2);
    
    if (!_lineView) {
        _lineView = [[UIImageView alloc] initWithImage:lineImage];
        _lineView.frame = start;
        [self addSubview:_lineView];
    } else {
        _lineView.frame = start;
    }
    
    __weak typeof(self) temp = self;
    [UIView animateWithDuration:2 animations:^{
        _lineView.frame = end;
    } completion:^(BOOL finished) {
        [temp loopDrawLine];
    }];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        if (_delegate != nil && [_delegate respondsToSelector:@selector(captureView:scanResult:)]) {
            [_delegate captureView:self scanResult:metadataObject.stringValue];
        }
    }
}

#pragma mark - 开始、结束捕获
- (void)startScan {
    [_session startRunning];
}

- (void)stopScan {
    [_session stopRunning];
}

#pragma mark - 读取相册中的二维码
- (void)imagePickerController {
    
    // 调用手机的相册
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    _picker.allowsEditing = true;
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(showImagePickerController:)]) {
        [_delegate showImagePickerController:_picker];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:true completion:^{
        // 利用CoreImage读取二维码的功能只有在iOS8之后才支持
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if (!image) {
            image = info[UIImagePickerControllerOriginalImage];
        }
        
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        
        // kCIContextUseSoftwareRenderer : 软件渲染 -- 可以消除 "BSXPCMessage received error for message: Connection interrupted" 警告
        // kCIContextPriorityRequestLow : 低优先级在 GPU 渲染-- 设置为false可以加快图片处理速度
        //CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(true), kCIContextPriorityRequestLow : @(false)}];
        
        CIContext *context = [CIContext contextWithOptions:nil];

        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:nil];
        CIImage *ciImage = [CIImage imageWithData:imageData];
        
        NSArray *array = [detector featuresInImage:ciImage];
        // 含有识别后的信息
        CIQRCodeFeature *feature = [array firstObject];
        if (_delegate != nil && [_delegate respondsToSelector:@selector(finishPickingMediaWithInfo:)]) {
            [_delegate finishPickingMediaWithInfo:feature.messageString];
        }

    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
