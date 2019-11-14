//
//  SJNormalAlertView.m
//  HNTransport
//
//  Created by 刘江 on 2018/7/13.
//  Copyright © 2018年 com.liangla. All rights reserved.
//

#import "SJNormalAlertView.h"
#import "LLWebViewHelper.h"
#define kAlertWidth [UIScreen mainScreen].bounds.size.width*285/375
#define ScreenScale [UIScreen mainScreen].bounds.size.width/375
#define ParagraphLineSpacing 2
@interface SJNormalAlertView ()
@property (nonatomic, assign)CGFloat originTitleRowHeight;
//@property (nonatomic, assign)CGFloat originContentRowHeight;
@property (nonatomic, assign)CGFloat originContentHeight;

//@property (nonatomic, assign)NSInteger rowCount;

@end

@implementation SJNormalAlertView
@synthesize passMsg;

- (UIView *)produceSJNormalAlertViewWithTitle:(NSString *)title content:(NSString *)content bottomClickItem:(NSArray *)bottomClickItem {
    _contentView = [[LLWebViewHelper rootBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].lastObject;
    self.title.text = title;
    self.contentLab.text = content;
    //    self.rowCount = 1;
    self.originTitleRowHeight = CGRectGetHeight(self.title.frame);
    //    self.originContentRowHeight = CGRectGetHeight(self.contentLab.frame);
    self.originContentHeight = CGRectGetHeight(self.contentLab.frame);
    _contentView.frame = CGRectMake(0, 0, kAlertWidth, CGRectGetHeight(_contentView.frame));
    [self adjustSubviews];
    [self assignClickTitles:bottomClickItem];
    
    //set default style
    NSMutableArray *clickItemStyle = [NSMutableArray arrayWithObjects:@{NSFontAttributeName:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor colorWithRed:4/255.f green:137/255.f blue:255/255.f alpha:1]}, nil];
    for (int i = 1; i < bottomClickItem.count; i++) {
        [clickItemStyle insertObject:@{NSFontAttributeName:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium], NSForegroundColorAttributeName:[UIColor colorWithRed:153/255.f green:153/255.f blue:153/255.f alpha:1]} atIndex:0];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineSpacing = ParagraphLineSpacing;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [self configTitleStyle:@{NSFontAttributeName:[UIFont systemFontOfSize:18], NSForegroundColorAttributeName:[UIColor colorWithRed:34/255.f green:34/255.f blue:34/255.f alpha:1]} contentStyle:@{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:1], NSParagraphStyleAttributeName:paragraphStyle} clickItemsStyle:[clickItemStyle copy]];
    
    return _contentView;
}

- (void)configTitleStyle:(NSDictionary *)titleAttributes contentStyle:(NSDictionary *)contentAttributes clickItemsStyle:(NSArray <NSDictionary *> *)clickItemAttributes {
    if ([titleAttributes isKindOfClass:[NSDictionary class]] && [titleAttributes allKeys].count > 0 && [self.title.text isKindOfClass:[NSString class]] && [self.title.text length] > 0) {
        NSMutableAttributedString *att = [self.title.attributedText mutableCopy];
        [att addAttributes:titleAttributes range:NSMakeRange(0, self.title.attributedText.string.length)];
        self.title.attributedText = [att copy];
    }
    if ([contentAttributes isKindOfClass:[NSDictionary class]] && [contentAttributes allKeys].count > 0 && [self.contentLab.text isKindOfClass:[NSString class]] && [self.contentLab.text length] > 0) {
        NSMutableAttributedString *att = [self.contentLab.attributedText mutableCopy];
        [att addAttributes:contentAttributes range:NSMakeRange(0, self.contentLab.attributedText.string.length)];
        self.contentLab.attributedText = [att copy];
    }
    if ([clickItemAttributes isKindOfClass:[NSArray class]] && [clickItemAttributes count] > 0) {
        NSArray *btns = @[_button1, _button2];
        for (int i = 0; i < btns.count && i < clickItemAttributes.count; i++) {
            NSMutableAttributedString *att = [[btns[i] titleLabel].attributedText mutableCopy];
            [att addAttributes:clickItemAttributes[i] range:NSMakeRange(0, [btns[i] titleLabel].attributedText.string.length)];
            [btns[i] setAttributedTitle:[att copy] forState:UIControlStateNormal];
        }
    }
    [self adjustSubviews];
}

- (IBAction)clickAction1:(UIButton *)sender {
    self.passMsg = sender.currentTitle;
    //    self.msg = sender.currentTitle;
}

- (IBAction)clickAction2:(UIButton *)sender {
    self.passMsg = sender.currentTitle;
}

- (void)adjustSubviews {
    //width
    CGRect titleFrame = self.title.frame;
    titleFrame.size.width = CGRectGetWidth(self.contentView.frame)-60;
    self.title.frame = titleFrame;
    CGRect contentFrame = self.contentLab.frame;
    contentFrame.size.width = CGRectGetWidth(self.contentView.frame)-32;
    self.contentLab.frame = contentFrame;
    
    CGFloat titleRowH = [self calculateCharacterRowHeight:self.title];
    //    CGFloat contentRowH = [self calculateCharacterRowHeight:self.contentLab];
    CGFloat contentH = [self calculateCharacterRowHeight:self.contentLab];
    
    CGFloat titleAccum = titleRowH-_originTitleRowHeight;
    //    CGFloat contentAccum = [self needLines:self.contentLab]*contentRowH  - _originContentRowHeight*self.rowCount;
    CGFloat contentAccum = contentH - _originContentHeight;
    
    CGRect mod = self.contentView.frame;
    mod.size.height += (titleAccum+contentAccum);
    
    self.contentView.frame = mod;
    
    self.originTitleRowHeight = titleRowH;
    //    self.originContentRowHeight = contentRowH;
    //    self.rowCount = [self needLines:self.contentLab];
    self.originContentHeight = contentH;
    
}

- (void)assignClickTitles:(NSArray *)items {
    if (items.count == 1) {
        self.buttonW.constant = kAlertWidth/2.f;
        [self.button1 setTitle:items.firstObject forState:UIControlStateNormal];
        self.button1.titleLabel.textAlignment = NSTextAlignmentCenter;
    }else if (items.count > 1){
        [self.button1 setTitle:items[0] forState:UIControlStateNormal];
        [self.button2 setTitle:items[1] forState:UIControlStateNormal];
    }
    
}


- (NSInteger)needLines:(UILabel *)label {
    //创建一个labe
    UILabel *labelCopy = [[UILabel alloc] initWithFrame:label.frame];
    labelCopy.text = label.text;
    labelCopy.font = label.font;
    //font和当前label保持一致
    NSString * text = labelCopy.text;
    NSInteger sum = 0;
    //总行数受换行符影响，所以这里计算总行数，需要用换行符分隔这段文字，然后计算每段文字的行数，相加即是总行数。
    NSArray * splitText = [text componentsSeparatedByString:@"\n"];
    for (NSString * sText in splitText) {
        labelCopy.text = sText;
        //获取这段文字一行需要的size
        CGSize textSize = [labelCopy systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        //size.width/所需要的width 向上取整就是这段文字占的行数
        NSInteger lines = ceilf(textSize.width/CGRectGetWidth(labelCopy.frame));
        //当是0的时候，说明这是换行，需要按一行算。
        lines = lines == 0?1:lines;
        sum += lines;
    }
    return sum;
}

- (CGFloat)calculateCharacterRowHeight:(UILabel *)label {
    if (!label || label.text.length < 1) {
        return 0.f;
    }
    CGFloat boundingHeight = [UIScreen mainScreen].bounds.size.height*0.8;
    NSString *text = label.text;
    NSMutableDictionary *style = [NSMutableDictionary dictionaryWithObjectsAndKeys:label.font, NSFontAttributeName, nil];
    if (label.numberOfLines == 1) { ///标题
        if (text.length > 10) {
            text = [text substringToIndex:10];
        }
        boundingHeight = CGRectGetHeight(label.frame);
    }else {///内容
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineSpacing = ParagraphLineSpacing;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [style setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    }
    return [text boundingRectWithSize:CGSizeMake(CGRectGetWidth(label.frame), boundingHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:style context:nil].size.height;
}

@end
