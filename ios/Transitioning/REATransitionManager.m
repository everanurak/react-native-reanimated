#import "REATransitionManager.h"

#import <React/RCTUIManager.h>
#import <React/RCTUIManagerObserverCoordinator.h>

#import "REATransition.h"

@interface REATransitionManager () <RCTUIManagerObserver>
@end

@implementation REATransitionManager {
  REATransition *_pendingTransition;
  UIView *_pendingTransitionRoot;
  RCTUIManager *_uiManager;
}

- (instancetype)initWithUIManager:(id)uiManager
{
  if (self = [super init]) {
    _uiManager = uiManager;
  }
  return self;
}

- (void)beginTransition:(REATransition *)transition forView:(UIView *)view
{
  RCTAssertMainQueue();
  if (_pendingTransition != nil) {
    return;
  }
  _pendingTransition = transition;
  _pendingTransitionRoot = view;
  [transition startCaptureInRoot:view];
}

- (void)uiManagerWillPerformMounting:(RCTUIManager *)manager
{
  [manager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    [_pendingTransition playInRoot:_pendingTransitionRoot];
    _pendingTransitionRoot = nil;
    _pendingTransition = nil;
  }];
}

- (void)animateNextTransitionInRoot:(NSNumber *)reactTag withConfig:(NSDictionary *)config
{
  [_uiManager.observerCoordinator addObserver:self];
  [_uiManager prependUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    UIView *view = viewRegistry[reactTag];
    NSArray *transitionConfigs = [RCTConvert NSArray:config[@"transitions"]];
    for (id transitionConfig in transitionConfigs) {
      REATransition *transition = [REATransition inflate:transitionConfig];
      [self beginTransition:transition forView:view];
    }
  }];
  __weak id weakSelf = self;
  [_uiManager addUIBlock:^(RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
    [uiManager.observerCoordinator removeObserver:weakSelf];
  }];
}

@end
