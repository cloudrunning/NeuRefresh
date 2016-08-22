//
//  NeuRefreshHeader.h
//  SURefreshDemo
//
//  Created by caozhen@neusoft on 16/8/22.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+NeuRefresh.h"

@interface NeuRefreshHeader : UIView

UIKIT_EXTERN const CGFloat NeuRefreshHeaderHeight;
UIKIT_EXTERN const CGFloat NeuRefreshPointRadius;

@property (nonatomic,copy) void(^handle)();

- (void)endRefreshing;
@end
