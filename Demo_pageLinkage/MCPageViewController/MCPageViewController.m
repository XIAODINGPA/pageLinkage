//
//  MCPageViewController.m
//  Demo_pageViewController管理多页面
//
//  Created by goulela on 2017/8/17.
//  Copyright © 2017年 MC. All rights reserved.
//

#import "MCPageViewController.h"


@interface MCPageViewController ()
<
UIScrollViewDelegate,UIPageViewControllerDelegate,UIPageViewControllerDataSource
>
{
    NSInteger _curPage;
}
@property (nonatomic, strong) UIScrollView * titleScrollView;
//标题滚动视图
@property (nonatomic, strong) UIView * indicatorView;
//分页控制器
@property (nonatomic, strong) UIPageViewController * pageVC;


@property (nonatomic, strong) UIView * lineView;

/**
 *  标题按钮的数组
 *  用来改变按钮的状态
 */
@property (nonatomic, strong) NSMutableArray * titleButtonArrayM;

@end

@implementation MCPageViewController

#define kReuseCell @"cell"
#define kWidth          self.view.bounds.size.width
#define kHeigth         self.view.bounds.size.height


// 避免子类重写viewDidLoad方法导致不能实现下面的两个方法
- (void)achieve {
    [self reference_baseSetting];
    [self reference_initUI];
}

#pragma mark - 系统代理
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [_vcArray indexOfObject:viewController];
    if (index == _vcArray.count -1) {
        return nil;
    }
    return _vcArray[index+1];
}
//返回上一页
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [_vcArray indexOfObject:viewController];
    if (index == 0) {
        return nil;
    }
    return _vcArray[index-1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    UIViewController *sub = pageViewController.viewControllers[0];
    NSInteger index = 0;
    for (UIViewController *VC in _vcArray) {
        
        if ([VC isEqual:sub]) {
            _curPage = index;
        }
        index++;
    }
    
    UIButton * btn = (UIButton *)[self.view.window viewWithTag:_curPage + 1000];
    [self titleButtonClicked:btn];
    
    [self setScrollViewOffSet:btn];
}


//设置偏移
- (void)setScrollViewOffSet:(UIButton *)sender {
    
    //
    int count = kWidth * 0.5 / self.blockWidth;
    
    if (count % 2 == 0) {
        count --;
    }
    
    CGFloat offsetX = sender.frame.origin.x - count * self.blockWidth;
    if (offsetX<0) {
        offsetX=0;
    }
    CGFloat maxOffsetX= _titleScrollView.contentSize.width - kWidth;
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    [UIView animateWithDuration:.2 animations:^{
        [_titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }];
}


#pragma mark - 点击事件
- (void)titleButtonClicked:(id)sender {
    NSInteger tagNum = [sender tag];
    
    _curPage = tagNum - 1000;
    
    if (_curPage < 0) {
        _curPage = 1;
    }
    
    NSString * title = [self.titleArray objectAtIndex:_curPage];
    CGFloat width = [title boundingRectWithSize:CGSizeMake(1000, self.blockFont) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.blockFont]} context:nil].size.width;
    
    
    for (UIButton * button in self.titleButtonArrayM) {
        if (tagNum != button.tag) {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        } else {
            [UIView animateKeyframesWithDuration:0.2
                                           delay:0.0
                                         options:UIViewKeyframeAnimationOptionLayoutSubviews
                                      animations:^{
                                          _indicatorView.center = CGPointMake(button.center.x, _indicatorView.center.y);
                                          _indicatorView.bounds = CGRectMake(0, 0, width, 1.5);
                                      }
                                      completion:^(BOOL finished) {
                                          [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                                      }];
        }
    }
    [_pageVC setViewControllers:@[_vcArray[_curPage]] direction:_curPage>tagNum animated:YES completion:^(BOOL finished) {
        _curPage = tagNum;
    }];
}

- (void)jumpToVC:(UIButton *)btn {
    //要跳转到的vc索引
    //direction：0代表前进，1代表后退
    [self titleButtonClicked:btn];
    
    NSInteger toPage = btn.tag - 1000;
    [_pageVC setViewControllers:@[_vcArray[toPage]] direction:_curPage>toPage animated:YES completion:^(BOOL finished) {
        _curPage = toPage;
    }];
}

#pragma mark - 实现方法
- (void)reference_baseSetting {
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_barColor == nil) {
        _barColor = [UIColor whiteColor];
    }
    
    if (_barHeight < 40) {
        _barHeight = 40;
    }
    
    if (_blockWidth < 50) {
        _blockWidth = 50;
    }
    
    if (_blockFont < 14) {
        _blockFont = 18;
    }
    
    if (_blockColor == nil) {
        _blockColor = [UIColor whiteColor];
    }
    
    if (_blockNormalColor == nil) {
        _blockNormalColor = [UIColor grayColor];
    }
    
    if (_blockSelectedColor == nil) {
        _blockSelectedColor = [UIColor redColor];
    }
    
    if (_currentPage < 0) {
        _currentPage = 0;
    }
    
}

- (void)reference_initUI {
    self.titleScrollView.frame = CGRectMake(0, 0, kWidth, self.barHeight);
    [self.view addSubview:self.titleScrollView];
    
    self.lineView.frame = CGRectMake(0, self.barHeight, kWidth, 1);
    [self.view addSubview:self.lineView];
    
    self.pageVC.view.frame = CGRectMake(0, self.barHeight + 1, kWidth, kHeigth - self.barHeight);
    [self.view addSubview:self.pageVC.view];
    
    
    //创建按钮
    for (int i = 0; i<self.titleArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(i*self.blockWidth, 0, self.blockWidth, self.barHeight);
        btn.backgroundColor = self.blockColor;
        btn.titleLabel.font = [UIFont systemFontOfSize:self.blockFont];
        [btn setTitle:[NSString stringWithFormat:@"%@",self.titleArray[i]] forState:UIControlStateNormal];
        [btn setTitleColor:self.blockNormalColor forState:UIControlStateNormal];
        [btn setTitleColor:self.blockSelectedColor forState:UIControlStateNormal];
        btn.tag = 1000 + i;
        //添加点击事件
        [btn addTarget:self action:@selector(jumpToVC:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleButtonArrayM addObject:btn];
        [_titleScrollView addSubview:btn];
    }
    
    
    [self titleButtonClicked:self.titleButtonArrayM[0]];
    
    
    NSString * title = [self.titleArray objectAtIndex:0];
    CGFloat width = [title boundingRectWithSize:CGSizeMake(1000, self.blockFont) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.blockFont]} context:nil].size.width;
    self.indicatorView.frame = CGRectMake((self.blockWidth - width)/2 + self.currentPage * self.blockWidth, self.barHeight-1.5, width, 1.5);
    [self.titleScrollView addSubview:self.indicatorView];
}




#pragma mark - setter & getter
- (UIScrollView *)titleScrollView {
    if (_titleScrollView == nil) {
        self.titleScrollView = [[UIScrollView alloc] init];
        self.titleScrollView.showsHorizontalScrollIndicator = NO;
        self.titleScrollView.backgroundColor = self.barColor;
        self.titleScrollView.contentSize = CGSizeMake(self.blockWidth*self.titleArray.count, 0);
        self.titleScrollView.contentSize = CGSizeMake(self.blockWidth*self.titleArray.count, 0);
    } return _titleScrollView;
}

- (UIView *)indicatorView {
    if (_indicatorView == nil) {
        self.indicatorView = [[UIView alloc] init];
        self.indicatorView.backgroundColor = self.blockSelectedColor;
    } return _indicatorView;
}

- (UIView *)lineView {
    if (_lineView == nil) {
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor grayColor];
    } return _lineView;
}

- (NSMutableArray *)titleButtonArrayM {
    if (_titleButtonArrayM == nil) {
        self.titleButtonArrayM = [NSMutableArray arrayWithCapacity:0];
    } return _titleButtonArrayM;
}

- (UIPageViewController *)pageVC {
    if (!_pageVC) {
        self.pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        
        self.pageVC.delegate = self;
        self.pageVC.dataSource = self;
        
        [self.pageVC setViewControllers:@[self.vcArray[0]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
        
        // 遍历pageVC.view的子视图,找到scrollView.设置代理
        for (UIView * view in self.pageVC.view.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                [view setValue:self forKey:@"delegate"];
            }
        }
    } return _pageVC;
}



@end
