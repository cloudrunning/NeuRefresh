//
//  UIScrollView+NeuRefresh.h
//  SURefreshDemo
//
//  Created by caozhen@neusoft on 16/8/22.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SURefreshHeader;
@interface UIScrollView (NeuRefresh)
@property (nonatomic,weak,readonly) SURefreshHeader *header;

- (void)addRefreshHeaderWithHandle:(void(^)())handle;
@end
