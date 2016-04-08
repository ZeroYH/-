//
//  YHCapture.h
//  AVMetadataObjectTest
//
//  Created by 于仁汇 on 16/3/14.
//  Copyright © 2016年 YRH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YHCapture;

@protocol YHCaptureDelegate <NSObject>

// 代理 用于手机扫描完成后返回结果
- (void)captureView:(YHCapture *)view scanResult:(NSString *)result;

// 识别相册中的图片 (iOS 8)
// 此代理方法处写 将ImagePickerController模态出现
- (void)showImagePickerController:(UIImagePickerController *)imagePickerController;
// 扫描完相册图片之后做操作
- (void)finishPickingMediaWithInfo:(NSString *)result;
@end

@interface YHCapture : UIView

@property (nonatomic, weak) id<YHCaptureDelegate> delegate;
@property (nonatomic, assign, readonly) CGRect scanViewFrame;

// 开始、结束捕获
- (void)startScan;
- (void)stopScan;

// 读取相册中的二维码
- (void)imagePickerController;
@end
