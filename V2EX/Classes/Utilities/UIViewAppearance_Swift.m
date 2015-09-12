//
//  UIViewAppearance_Swift.m
//  V2EX
//
//  Created by WildCat on 9/12/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

#include "UIViewAppearance_Swift.h"

@implementation UIView (UIViewAppearance_Swift)
+ (instancetype)v2_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}
@end