//
//  EJDefaultLoadingView.m
//  EJDemo
//
//  Created by iOnRoad on 15/8/25.
//  Copyright (c) 2015年 iOnRoad. All rights reserved.
//

#import "EJDefaultLoadingView.h"

@interface EJDefaultLoadingView ()

@property(strong,nonatomic) UIView *ej_containerView;
@property(strong,nonatomic) UIActivityIndicatorView *ej_indicatorView;
@property(strong,nonatomic) UILabel *ej_loadingTextLabel;
@property(strong,nonatomic) NSTimer *ej_loadingTimer;
@property(assign,nonatomic) NSInteger ej_timerCount;
@property(strong,nonatomic) NSMutableArray *ej_loadingTextsArray;

@end

@implementation EJDefaultLoadingView

-(void)dealloc{
    NSLog(@"LPDefaultLoadingView dealloc.");
    [self ej_invalidateLoadingTimer];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alpha = 0.1;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
        
        CGFloat width = 30;
        CGFloat offsetX = 20;
        //ContainerView
        _ej_containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width+2*offsetX, width+2*offsetX)];
        self.ej_containerView.layer.masksToBounds = YES;
        self.ej_containerView.layer.cornerRadius = 12.0;
        self.ej_containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        [self addSubview:self.ej_containerView];
        self.ej_containerView.center = CGPointMake(self.center.x, self.center.y - 64);
        
        _ej_indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.ej_indicatorView.frame = CGRectMake(offsetX, 8, width, width);
        [self.ej_containerView addSubview:self.ej_indicatorView];
        
        //Loading TextLabel
        _ej_loadingTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, width+15, _ej_containerView.frame.size.width, 20)];
        self.ej_loadingTextLabel.backgroundColor = [UIColor clearColor];
        self.ej_loadingTextLabel.textColor = [UIColor whiteColor];
        self.ej_loadingTextLabel.font = [UIFont systemFontOfSize:14];
        [self.ej_containerView addSubview:self.ej_loadingTextLabel];
        [self ej_setLoadingTextLabelFrame];
        
        _ej_loadingTextsArray = [NSMutableArray array];
        [self ej_fillLoadingTextsArray];
    }
    return self;
}

- (void)ej_setLoadingTextLabelFrame{
    self.ej_loadingTextLabel.text = [NSString stringWithFormat:@"%@..." ,self.ej_loadingMsg];
    [self.ej_loadingTextLabel sizeToFit];
    CGRect frame = self.ej_loadingTextLabel.frame;
    CGFloat x = (self.ej_containerView.frame.size.width - self.ej_loadingTextLabel.frame.size.width)/2;
    frame.origin.x  = x>0?x:0;
    frame.size.width = x>0?self.ej_loadingTextLabel.frame.size.width:self.ej_containerView.frame.size.width;
    self.ej_loadingTextLabel.frame = frame;
}

- (void)setEj_loadingMsg:(NSString *)loadingMsg{
    [super setEj_loadingMsg:loadingMsg];
    [self ej_setLoadingTextLabelFrame];
    [self ej_fillLoadingTextsArray];
}

- (void)ej_fillLoadingTextsArray{
    [self.ej_loadingTextsArray removeAllObjects];
    NSString *text1 = [NSString stringWithFormat:@"%@.",self.ej_loadingMsg];
    NSString *text2 = [NSString stringWithFormat:@"%@..",self.ej_loadingMsg];
    NSString *text3 = [NSString stringWithFormat:@"%@...",self.ej_loadingMsg];
    [self.ej_loadingTextsArray addObject:text1];
    [self.ej_loadingTextsArray addObject:text2];
    [self.ej_loadingTextsArray addObject:text3];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    self.ej_containerView.center = CGPointMake(window.center.x, window.center.y - 64);
}

- (void)ej_startAnimation{
    [super ej_startAnimation];
    
    [self.ej_indicatorView startAnimating];//开始播放动画
    [self ej_startLoadingTextAnimation];
    self.alpha = 0.0;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 1.0;
    }];
}

- (void)ej_stopAnimation{
    [super ej_stopAnimation];
    
    [self.ej_indicatorView stopAnimating];    //停止动画
    [self ej_stopLoadingTextAnimation];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.alpha = 0.0;
    }];
}

- (void)ej_startLoadingTextAnimation{
    [self ej_invalidateLoadingTimer];
    self.ej_timerCount = 0;
    _ej_loadingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(handleLoadingTextAnimation:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.ej_loadingTimer forMode:NSRunLoopCommonModes];
    [self handleLoadingTextAnimation:self.ej_loadingTimer];
}

- (void)handleLoadingTextAnimation:(NSTimer *)timer{
    if(self.ej_timerCount<self.ej_loadingTextsArray.count){
        self.ej_loadingTextLabel.text = self.ej_loadingTextsArray[self.ej_timerCount];
    }
    self.ej_timerCount++;
    if(self.ej_timerCount>=self.ej_loadingTextsArray.count){
        self.ej_timerCount = 0;
    }
}

- (void)ej_stopLoadingTextAnimation{
    [self ej_invalidateLoadingTimer];
    self.ej_loadingTextLabel.text = self.ej_loadingMsg;
}

- (void)ej_invalidateLoadingTimer{
    if(self.ej_loadingTimer){
        [self.ej_loadingTimer invalidate];
        self.ej_loadingTimer = nil;
    }
}

@end
