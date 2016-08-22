//
//  UIScrollView+NeuRefresh.m
//  SURefreshDemo
//
//  Created by caozhen@neusoft on 16/8/22.
//  Copyright © 2016年 KevinSu. All rights reserved.
//

#import "UIScrollView+NeuRefresh.h"
#import <objc/runtime.h>
#import "SURefreshHeader.h"
@implementation UIScrollView (NeuRefresh)

- (void)addRefreshHeaderWithHandle:(void (^)())handle {
    
    SURefreshHeader *header = [[SURefreshHeader alloc]init];
    header.handle = handle;
    self.header = header;
    [self insertSubview:header atIndex:0];
}

- (void)setHeader:(SURefreshHeader *)header {
    
    objc_setAssociatedObject(self, @selector(header), header,OBJC_ASSOCIATION_ASSIGN);
}

- (SURefreshHeader *)header {
    
    return objc_getAssociatedObject(self, @selector(header));
}

#pragma mark ---- swizzle
+ (void)load {
    
    Method mehtod1 = class_getClassMethod([self class], NSSelectorFromString(@"dealloc"));
    Method method2 = class_getClassMethod([self class], NSSelectorFromString(@"neu_dealloc"));
    method_exchangeImplementations(mehtod1, method2);
}

- (void)neu_dealloc {
    
    self.header = nil;
    [self neu_dealloc];
}
@end
