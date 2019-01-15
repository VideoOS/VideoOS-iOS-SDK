//
//  VPUPSVGAPlayer.m
//  VideoPlsUtilsPlatformSDK
//
//  Created by peter on 22/03/2018.
//  Copyright © 2018 videopls. All rights reserved.
//

#import "VPUPSVGAPlayer.h"
#import <SVGAPlayer/SVGA.h>
#import <SVGAPlayer/SVGAVideoEntity.h>
#import <CommonCrypto/CommonCrypto.h>
#import "VPUPSVGAParser.h"

@interface VPUPSVGAPlayer () <SVGAPlayerDelegate>

@property (nonatomic, strong) SVGAPlayer *player;
@property (nonatomic, assign) BOOL isPlayerClear;
@property (nonatomic, strong) SVGAVideoEntity *videoItem;
@property (nonatomic, strong) NSArray *rangeArray;
@property (nonatomic, strong) NSArray *repeatArray;
@property (nonatomic, assign) NSInteger currentPlayRangeIndex;
@property (nonatomic, assign, getter=isAnimating) BOOL animating;
@property (nonatomic, copy) void(^finishedRangeIndexHandle)(NSUInteger);

@end

static VPUPSVGAParser* svgaParser() {
    static VPUPSVGAParser *parser = nil;
    if(!parser) {
        parser = [[VPUPSVGAParser alloc] init];
    }
    return parser;
}

@implementation VPUPSVGAPlayer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (void)load {
    [[VPUPServiceManager sharedManager] registerService:@protocol(VPUPSVGAPlayerProtocol) implClass:[VPUPSVGAPlayer class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _player = [[SVGAPlayer alloc] init];
        _player.delegate = self;
        _player.clearsAfterStop = YES;
    }
    return self;
}

- (void)dealloc {
    
}

- (UIView *)view {
    return _player;
}

- (BOOL)readyToPlay {
    if (self.videoItem) {
        return YES;
    }
    return NO;
}

- (int)fps {
    if (self.readyToPlay) {
        return self.videoItem.FPS;
    }
    return 0;
}

- (int)frames {
    if (self.readyToPlay) {
        return self.videoItem.frames;
    }
    return 0;
}

- (void)setSVGAWithURL:(NSURL *)url readyToPlay:(void (^)(void))playBlock {
    [svgaParser() parseWithURL:url completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
        if (videoItem != nil) {
            self.player.videoItem = videoItem;
            self.videoItem = videoItem;
            self.isPlayerClear = NO;
            if (playBlock) {
                playBlock();
            }
            else {
                [self startAnimation];
            }
        }
    } failureBlock:^(NSError * _Nullable error) {
        
    }];
}

- (void)setSVGAWithData:(NSData *)data cacheKey:(NSString *)cacheKey readyToPlay:(void (^)(void))playBlock {
    [svgaParser() parseWithData:data cacheKey:cacheKey completionBlock:^(SVGAVideoEntity * _Nonnull videoItem) {
        if (videoItem != nil) {
            self.player.videoItem = videoItem;
            self.videoItem = videoItem;
            self.isPlayerClear = NO;
            if (playBlock) {
                playBlock();
            }
            else {
                [self startAnimation];
            }
        }
    } failureBlock:^(NSError * _Nonnull error) {

    }];
}

- (void)setLoops:(int)loops {
    self.player.loops = loops;
}

- (int)loops {
    return self.player.loops;
}

- (void)startAnimation {
    [self startAnimationWithRange:NSMakeRange(0, self.frames) reverse:NO];
}

- (void)startAnimationWithRange:(NSRange)range reverse:(BOOL)reverse {
    if (!self.readyToPlay) {
        return;
    }
    self.animating = YES;
    if (self.isPlayerClear) {
        self.player.videoItem = self.videoItem;
    }
    [self.player startAnimationWithRange:range reverse:reverse];
}

- (void)pauseAnimation {
    self.animating = NO;
    [self.player pauseAnimation];
}

- (void)stopAnimation {
    self.animating = NO;
    self.player.clearsAfterStop = YES;
    self.isPlayerClear = YES;
    [self.player stopAnimation];
}

- (void)stepToFrame:(NSInteger)frame andPlay:(BOOL)andPlay {
    if (!self.readyToPlay) {
        return;
    }
    self.animating = andPlay;
    [self.player stepToFrame:frame andPlay:andPlay];
}

- (void)stepToPercentage:(CGFloat)percentage andPlay:(BOOL)andPlay {
    if (!self.readyToPlay) {
        return;
    }
    self.animating = andPlay;
    [self.player stepToPercentage:percentage andPlay:andPlay];
}

#pragma mark - SVGAPlayerDelegate
- (void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player {
    if (self.delegate && [self.delegate respondsToSelector:@selector(svgaPlayerDidFinishedAnimation:)]) {
        [self.delegate svgaPlayerDidFinishedAnimation:self];
    }

    if (self.finishedRangeIndexHandle) {
        self.finishedRangeIndexHandle(self.currentPlayRangeIndex);
    }
    if (self.currentPlayRangeIndex < (NSInteger)self.rangeArray.count - 1) {
        self.currentPlayRangeIndex++;
        [self playAnimationWithRangesIndex:self.currentPlayRangeIndex];
    }
    else {
        //播放动画结束以后，清空所有状态
        self.isPlayerClear = YES;
        self.animating = NO;
        self.finishedRangeIndexHandle = nil;
        self.player.clearsAfterStop = YES;
        [self.player clear];
    }
}

- (void)svgaPlayerDidAnimatedToFrame:(NSInteger)frame {
    if (self.delegate && [self.delegate respondsToSelector:@selector(svgaPlayerDidAnimatedToFrame:)]) {
        [self.delegate svgaPlayerDidAnimatedToFrame:frame];
    }
}

- (void)svgaPlayerDidAnimatedToPercentage:(CGFloat)percentage {
    if (self.delegate && [self.delegate respondsToSelector:@selector(svgaPlayerDidAnimatedToPercentage:)]) {
        [self.delegate svgaPlayerDidAnimatedToPercentage:percentage];
    }
}

- (void)startAnimationWithRanges:(NSArray *)ranges repeats:(NSArray *)repeats finishedRangeIndexHandle:(void(^)(NSUInteger))handle {
    if (!ranges || ranges.count != repeats.count) {
        return;
    }
    self.currentPlayRangeIndex = 0;
    self.rangeArray = ranges;
    self.repeatArray = repeats;
    if (handle) {
        self.finishedRangeIndexHandle = handle;
    }
    self.player.clearsAfterStop = NO;
    [self playAnimationWithRangesIndex:self.currentPlayRangeIndex];
}

- (void)playAnimationWithRangesIndex:(NSUInteger)index {
    NSValue *rangeValue = [self.rangeArray objectAtIndex:index];
    NSRange range = [rangeValue rangeValue];
    NSUInteger repeat = [[self.repeatArray objectAtIndex:index] unsignedIntegerValue];
    self.loops = (int)repeat;
    [self startAnimationWithRange:range reverse:NO];
}

@end
