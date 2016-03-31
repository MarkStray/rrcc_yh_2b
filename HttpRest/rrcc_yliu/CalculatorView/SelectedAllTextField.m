//
//  SelectedAllTextField.m
//  rrcc_yh
//
//  Created by user on 16/1/5.
//  Copyright © 2016年 ting liu. All rights reserved.
//

#import "SelectedAllTextField.h"

@implementation SelectedAllTextField

//- (CGRect) caretRectForPosition:(UITextPosition*) position {
//    return CGRectZero;
//}
//
//- (NSArray *)selectionRectsForRange:(UITextRange *)range {
//    return nil;
//}

#if 0

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(paste:) ||
        action == @selector(cut:) ||
        action == @selector(copy:) ||
        action == @selector(select:) ||
        action == @selector(selectAll:) ||
        action == @selector(delete:) ||
        action == @selector(makeTextWritingDirectionLeftToRight:) ||
        action == @selector(makeTextWritingDirectionRightToLeft:) ||
        action == @selector(toggleBoldface:) ||
        action == @selector(toggleItalics:) ||
        action == @selector(toggleUnderline:) ||
        action == @selector(increaseSize:) ||
        action == @selector(decreaseSize:)
        ) {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

#else

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {

    UIMenuController *menuController = [UIMenuController sharedMenuController];

    if (menuController) {

        [UIMenuController sharedMenuController].menuVisible = NO;

    }

    return NO;

}

#endif

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
