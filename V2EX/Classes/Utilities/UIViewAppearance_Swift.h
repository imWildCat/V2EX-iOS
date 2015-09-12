//
//  UIViewAppearance_Swift.h
//  V2EX
//
//  Created by WildCat on 9/12/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIViewAppearance_Swift)
+ (instancetype)v2_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end
