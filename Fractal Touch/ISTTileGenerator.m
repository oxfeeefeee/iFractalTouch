//
//  ISTTileGenerator.m
//  FractalPlus
//
//  Created by On Mac No5 on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ISTTileGenerator.h"
#import "ISTFractalTile.h"
#import "ISTMegaFractal.h"
#import "ISTUtility.h"
#import "ISTColorCalculator.h"
#import "ISTColorSelection.h"
#import "ftTilePrioritySorting.h"

@interface ISTTileGenerator()

@property (nonatomic, strong) NSMutableArray* freeTiles;
@property (nonatomic, strong) NSMutableSet* previousFrameTiles;
@property (nonatomic, strong) NSMutableSet* cachedTiles;
@property (nonatomic, strong) NSMutableArray* toBeComputedTiles;
@property (nonatomic, strong) NSMutableArray* toBeReColoredTiles;
@property (nonatomic, strong) NSMutableArray* tempArray;

@property (nonatomic, strong) ISTFractalTile* tileForCompare;
@property (nonatomic, strong) ISTFractalTile* dummyBarrierTile;
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
@property (nonatomic, assign) int framesToUpdateCache;


- (ISTFractalTile*)getPreviousLevelTile: (ISTFractalTile*)currentTile;

@end

@implementation ISTTileGenerator

@synthesize freeTiles = mFreeTiles;
@synthesize previousFrameTiles = mPreviousFrameTiles;
@synthesize cachedTiles = mCachedTiles;
@synthesize tilesLOD = mTilesLOD;
@synthesize previewTiles = mPreviewTiles;
@synthesize toBeComputedTiles = mToBeComputedTiles;
@synthesize toBeReColoredTiles = mToBeReColoredTiles;
@synthesize tempArray = mTempArray;

@synthesize minX = mMinX;
@synthesize maxX = mMaxX;
@synthesize minY = mMinY;
@synthesize maxY = mMaxY;

@synthesize computingQueueSize = mComputingQueueSize;
@synthesize tileForCompare = mTileForCompare;
@synthesize dummyBarrierTile = mDummyBarrierTile;
@synthesize dispatchQueue = mDispatchQueue;
@synthesize colorCalculator = mColorCalculator;
@synthesize framesToUpdateCache = mFramesToUpdateCache;
@synthesize currentLevel = mCurrentLevel;
@synthesize newTileUploaded = mNewTileUploaded;
@synthesize releaseResourceCalled = mReleaseResourceCalled;

@synthesize megaFractal = mMegeFractal;

static int smDefaultTilePoolSize = 200;
static int smLODLevel = 4; 
static int smFramesPerCacheUpdate = 6;

- (ISTTileGenerator*)initWithMegaFractal:(ISTMegaFractal*) megaFractal
{
    if(self = [super init]) 
    {
        mFreeTiles = [[NSMutableArray alloc]init];
        mPreviousFrameTiles = [[NSMutableSet alloc]init];
        mCachedTiles = [[NSMutableSet alloc]init];
        mToBeComputedTiles = [[NSMutableArray alloc]init];
        mToBeReColoredTiles = [[NSMutableArray alloc] init];
        mTempArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < smLODLevel; ++i) {
            [mTempArray addObject:[[NSMutableSet alloc]init]];
        }
        mPreviewTiles = [[NSMutableSet alloc]init];
        mTilesLOD = [NSArray arrayWithArray:mTempArray];
        [mTempArray removeAllObjects];

        mTileForCompare = [[ISTFractalTile alloc]init];
        mDummyBarrierTile = [[ISTFractalTile alloc]init];
        mDummyBarrierTile.dummyBarrier = YES;
        mDispatchQueue = dispatch_queue_create("tileCalc", DISPATCH_QUEUE_CONCURRENT);
        mColorCalculator = [[ISTColorSelection instance].currentCalculator copy];
        mFramesToUpdateCache = smFramesPerCacheUpdate;
        mMegeFractal = megaFractal;
        mComputingQueueSize = 0;
        mNewTileUploaded = NO;
        mReleaseResourceCalled = NO;
    
        for (int i =0; i < smDefaultTilePoolSize; ++i) {
            [mFreeTiles addObject:[[ISTFractalTile alloc]init]];
        }
    }
    return self;
}

- (ISTFractalTile*)getFreeTile
{
    ISTFractalTile* tile = [mFreeTiles lastObject];
    if (tile) {
        [mFreeTiles removeLastObject];
        return tile;
    }else{
        tile = [[ISTFractalTile alloc]init];
        return tile;
    }
}

extern int c_isMultiCore();

- (void)computeTiles
{
    int maxsize = 1-1;
    if (c_isMultiCore() && [ISTUtility isIAP_SpeedingEnabled]) {
        maxsize = 2-1;
    }
    if (mComputingQueueSize <= maxsize && !mReleaseResourceCalled) {
        [self computeTilesImpl];
    }
}

- (void)computeTilesImpl
{
    if ([mToBeReColoredTiles count] > 0) {
        ISTFractalTile* tile = [mToBeReColoredTiles lastObject];
        [mToBeReColoredTiles removeLastObject];
        if (tile.state == ISTTileStateNeedUpload) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.releaseResourceCalled) {
                    return;
                }
                if (tile.state == ISTTileStateNeedUpload) {
                    [tile uploadToGpu:self.colorCalculator]; 
                    self.newTileUploaded = YES;
                    tile.state = ISTTileStateReady;
                    [self.megaFractal forceRefresh];
                }
                [self computeTiles];});
        }else {
            [self computeTiles];
        }
    }else if ([mToBeComputedTiles count] > 0) {
        ++mComputingQueueSize;
        ISTFractalTile* tile = [mToBeComputedTiles lastObject];
        [mToBeComputedTiles removeLastObject];
        while (tile.dummyBarrier) {
            dispatch_barrier_async(mDispatchQueue, ^{});
            tile = [mToBeComputedTiles lastObject];
            [mToBeComputedTiles removeLastObject];
        }
        ISTFractalTile* previousLevelTile = [self getPreviousLevelTile:tile];
        if( tile.state == ISTTileStateIdle){
            tile.state = ISTTileStateComputing;
            tile.alwaysCache = YES;
            previousLevelTile.alwaysCache = YES;
            dispatch_async(mDispatchQueue, ^
               {
                   [tile compute:previousLevelTile tileGenerator:self];
                   dispatch_async(dispatch_get_main_queue(), ^{
                       if (self.releaseResourceCalled) {
                           return;
                       }
                       tile.alwaysCache = NO;
                       previousLevelTile.alwaysCache = NO;
                       self.computingQueueSize = self.computingQueueSize - 1;
                       if (tile.abortComputingFlag) {
                           tile.state = ISTTileStateIdle;
                           tile.abortComputingFlag = NO;
                       }else {
                           [tile uploadToGpu:self.colorCalculator]; 
                           self.newTileUploaded = YES;
                           tile.state = ISTTileStateReady;
                           [self.megaFractal forceRefresh];
                       }
                       [self computeTiles];
                   });
               });
        }else {
            [self computeTiles];
        }
    }
}

- (void)addTileForProcess:(ISTFractalTile*)tile
{
    if (tile.state == ISTTileStateIdle) {
        [mToBeComputedTiles addObject:tile];
    }else if (tile.state == ISTTileStateNeedUpload) {
        [mToBeReColoredTiles addObject:tile];
    }
}

- (void)addTile:(int)level coordX:(long long)x coordY:(long long)y atLodLevel:(int)lodlevel
{
    NSMutableSet* currentFrameTiles = [mTilesLOD objectAtIndex:lodlevel];
    NSMutableSet* nextLODLevel = nil;
    if (lodlevel > 0) {
        nextLODLevel = [mTilesLOD objectAtIndex:lodlevel - 1];
    }

    //if in the next lod level, we have everything computed, skip
    BOOL canSkip = nextLODLevel != nil;
    if (canSkip) {
        mTileForCompare.level = (int)level+1;
        mTileForCompare.coordinateX = x*2;  
        mTileForCompare.coordinateY = y*2;
        ISTFractalTile* tile = [nextLODLevel member:mTileForCompare];
        if (canSkip && tile && tile.state != ISTTileStateReady) {
            canSkip = NO;
        }
        mTileForCompare.level = (int)level+1;
        mTileForCompare.coordinateX = x*2+1;
        mTileForCompare.coordinateY = y*2;
        tile = [nextLODLevel member:mTileForCompare];
        if (canSkip && tile && tile.state != ISTTileStateReady) {
            canSkip = NO;
        }
        mTileForCompare.level = (int)level+1;
        mTileForCompare.coordinateX = x*2;
        mTileForCompare.coordinateY = y*2+1;
        tile = [nextLODLevel member:mTileForCompare];
        if (canSkip && tile && tile.state != ISTTileStateReady) {
            canSkip = NO;
        }
        mTileForCompare.level = (int)level+1;
        mTileForCompare.coordinateX = x*2+1;
        mTileForCompare.coordinateY = y*2+1;
        tile = [nextLODLevel member:mTileForCompare];
        if (canSkip && tile && tile.state != ISTTileStateReady) {
            canSkip = NO;
        }
    }
    
    mTileForCompare.level = (int)level;
    mTileForCompare.coordinateX = x;
    mTileForCompare.coordinateY = y;
    ISTFractalTile* tile = [mPreviousFrameTiles member:mTileForCompare];
    if (tile) {
        [mPreviousFrameTiles removeObject:tile];
        [currentFrameTiles addObject:tile];
        [self addTileForProcess:tile];
        tile.canSkipRendering = canSkip;
        return;
    }
    
    tile = [mCachedTiles member:mTileForCompare];
    if (tile) {
        [mCachedTiles removeObject:tile];
        [currentFrameTiles addObject:tile];
        [self addTileForProcess:tile];
        tile.canSkipRendering = canSkip;
        return;
    }

    ISTFractalTile* newTile = [self getFreeTile];
    if (!newTile) {
        NSLog(@"Out of tiles!!! %i, %i, %i", level, [mFreeTiles count], [mCachedTiles count]);
    }
    newTile.level = (int)level;
    newTile.coordinateX = x;
    newTile.coordinateY = y; 
    newTile.state = ISTTileStateIdle;
    [currentFrameTiles addObject:newTile];
    [self addTileForProcess:newTile];
    tile.canSkipRendering = canSkip;
}

- (int)addOrderedTileLevel:(int)intLevel minMaxScale:(double)scale atLodLevel:(int)lodlevel
{
    long long cminx = (long long)floor(mMinX*scale);
    long long cmaxx = (long long)floor(mMaxX*scale);
    long long cminy = (long long)floor(mMinY*scale);
    long long cmaxy = (long long)floor(mMaxY*scale);
    
    double centerX = ((mMaxX-mMinX)*0.5 + mMinX)*scale;
    double centerY = ((mMaxY-mMinY)*0.5 + mMinY)*scale;
    ftTilePrioritySorting* sorting = [ftTilePrioritySorting instance];
    [sorting begin];
    for (long long i = cminx; i <= cmaxx; ++i) {
        for (long long j = cminy; j <= cmaxy; ++j) {
            [sorting addTileCoordX:i andY:j andCX:centerX andCY:centerY];
        }
    }
    NSMutableArray* sorted = [sorting sortAndEnd];
    for (ftTileSortingProxy* proxy in sorted){
        [self addTile:intLevel coordX:proxy.x coordY:proxy.y atLodLevel:lodlevel];
    }
    int tileCount = [sorted count];
    if (0){//tileCount >= 4) {
        [mToBeComputedTiles addObject:mDummyBarrierTile];
    }
    return tileCount;
}

- (void)findPreviewTiles
{
    NSMutableSet* topLodTiles = [mTilesLOD lastObject];
    for (ISTFractalTile* tile in topLodTiles) {
        long long x = tile.coordinateX;
        long long y = tile.coordinateY;
        int level = tile.level;
        while (level > 0) {
            level -= 1;
            x = x >=0? x/2 : (x-1)/2;
            y = y >=0? y/2 : (y-1)/2;
            mTileForCompare.level = level;
            mTileForCompare.coordinateX = x;
            mTileForCompare.coordinateY = y;
            ISTFractalTile* foundTile = [mPreviousFrameTiles member:mTileForCompare];
            if (foundTile && [foundTile isComputed]) {
                [mPreviousFrameTiles removeObject:foundTile];
                [mPreviewTiles addObject:foundTile];
                [self addTileForProcess:foundTile];
                break;
            }
            foundTile = [mCachedTiles member:mTileForCompare];
            if (foundTile && [foundTile isComputed]) {
                [mCachedTiles removeObject:foundTile];
                [mPreviewTiles addObject:foundTile];
                [self addTileForProcess:foundTile];
                break;
            }
        }
    }
}

- (BOOL)tileIsUseful:(ISTFractalTile*)tile margin:(double)margin
{
    int tileLevel = tile.level;
    double tileX = tile.coordinateX;
    double tileY = tile.coordinateY;
    
    double scale = mMegeFractal.scale;
    double tilesScale = pow(2.0, tileLevel);
    double scaleRatio = tilesScale/scale;
    double locX = -mMegeFractal.locationX * scaleRatio;
    double locY = -mMegeFractal.locationY * scaleRatio;
    double halfWidth = margin * [ISTUtility screenWidth] /2.0;
    double halfHeight = margin * [ISTUtility screenHeight] /2.0;
    double tileSize = IST_TILE_SIZE / [ISTUtility screenScale];
    double cminx = (locX - halfWidth)/tileSize;
    double cmaxx = (locX + halfWidth)/tileSize;
    double cminy = (locY - halfHeight)/tileSize;
    double cmaxy = (locY + halfHeight)/tileSize;
    
    return tileX >= cminx && tileX <= cmaxx && tileY >= cminy && tileY <= cmaxy;
}

- (BOOL)shouldCacheTile:(ISTFractalTile*)tile
{
    if (tile.alwaysCache) {
        return YES;
    }else if (tile.state == ISTTileStateIdle) {
        return NO;
    }
    return [self tileIsUseful:tile margin:1.5];
}

// 1. move all un-interested tiles in mCachedTiles to mFreeTiles
// 2. move all tiles in mPreviousFrameTiles to mCachedTiles
// 3. clear mPreviousFrameTiles
- (void)updateCachedTile
{
    if (mFramesToUpdateCache == 0) {
        [mTempArray removeAllObjects];
        for (ISTFractalTile* tile in mCachedTiles) {
            if (![self shouldCacheTile:tile]) {
                [mTempArray addObject:tile];
            }else if(tile.state == ISTTileStateComputing && ! [self tileIsUseful:tile margin:1.01]){
                tile.abortComputingFlag = YES;
            }
        }

        for (ISTFractalTile* tile in mTempArray) {
            [mCachedTiles removeObject:tile];
            [tile trash];
            [mFreeTiles addObject:tile];
        }
        mFramesToUpdateCache = smFramesPerCacheUpdate;
    }else {
        --mFramesToUpdateCache;
    }
    
    [mCachedTiles addObjectsFromArray:[mPreviousFrameTiles allObjects]];
    [mPreviousFrameTiles removeAllObjects]; 
}

- (void)update
{
    if (mReleaseResourceCalled) {
        return;
    }
    
    //put all current_tiles to previous_tiles
    for (NSMutableSet* oneLevelOfLOD in mTilesLOD) {
        [mPreviousFrameTiles unionSet:oneLevelOfLOD];
        [oneLevelOfLOD removeAllObjects];
    }
    [mPreviousFrameTiles unionSet:mPreviewTiles];
    [mPreviewTiles removeAllObjects];
    
    [mToBeReColoredTiles removeAllObjects];
    [mToBeComputedTiles removeAllObjects];
    
    double scale = mMegeFractal.scale;
    double locX = -mMegeFractal.locationX;
    double locY = -mMegeFractal.locationY;
    double level = ceil(log2(scale));
    double tilesScale = pow(2.0, level);
    double scaleRatio = scale/tilesScale;
    double halfWidth = [ISTUtility screenWidth]/2.f;
    double halfHeight = [ISTUtility screenHeight]/2.f;
    double tileSize = IST_TILE_SIZE * scaleRatio / [ISTUtility screenScale];
    mMinX = (locX - halfWidth-1.0f)/tileSize;
    mMaxX = (locX + halfWidth+1.0f)/tileSize;
    mMinY = (locY - halfHeight-1.0f)/tileSize;
    mMaxY = (locY + halfHeight+1.0f)/tileSize;
    
    mCurrentLevel = (int)level;
    int lodLevels = [mTilesLOD count];
    for (int i = 0; i < lodLevels; ++i) {
        double minmaxScale = 1.0/pow(2.0, i);
        [self addOrderedTileLevel:mCurrentLevel-i minMaxScale:minmaxScale atLodLevel:i];
    }
    
    [self findPreviewTiles];
    
    [self computeTiles];
    [self updateCachedTile];
}

- (void)onColorChangeKeepCache: (BOOL) keepCache;
{
    mColorCalculator = [ISTColorSelection instance].currentCalculator;
    
    if (!keepCache) {
        [self trashAllTiles];
        return;
    }

    for (ISTFractalTile *tile in mPreviewTiles) {
        [tile onColorChange:self.colorCalculator uploadNow:YES];
    }
    
    for (NSMutableSet* oneLevelOfLOD in mTilesLOD) {
        for (ISTFractalTile* tile in oneLevelOfLOD) {
            [tile onColorChange:self.colorCalculator uploadNow:YES];
        }
    }
    
    for (ISTFractalTile* tile in mCachedTiles){
        [tile onColorChange:self.colorCalculator uploadNow:NO];
    }
}

- (ISTFractalTile*)getPreviousLevelTile: (ISTFractalTile*)currentTile;
{
    long long x = currentTile.coordinateX >=0? currentTile.coordinateX/2 : (currentTile.coordinateX-1)/2;
    long long y = currentTile.coordinateY >=0? currentTile.coordinateY/2 : (currentTile.coordinateY-1)/2;
    int level = currentTile.level - 1;
    mTileForCompare.coordinateX = x;
    mTileForCompare.coordinateY = y;
    mTileForCompare.level = level;
    int lodLevel = mCurrentLevel - level;
    if (lodLevel >= [mTilesLOD count]) {
        return nil;
    }
    NSMutableSet* tiles = [mTilesLOD objectAtIndex:lodLevel];
    ISTFractalTile* t = [tiles member:mTileForCompare];
    if ([t isComputed]) {
        return t;
    }else {
        return  nil;
    }
}

- (void)trashAllTiles
{
    for (ISTFractalTile *tile in mPreviewTiles) {
        [tile trash];
    }
    for (NSMutableSet* oneLevelOfLOD in mTilesLOD) {
        for (ISTFractalTile* tile in oneLevelOfLOD) {
            [tile trash];
        }
    }
    for (ISTFractalTile *tile in mCachedTiles) {
        [tile trash];
    }
}


- (void)pauseCalculation
{
    
}

- (void)resumeCalculation
{

}

- (void)releaseResource
{
    [self trashAllTiles];
    mReleaseResourceCalled = YES;
    mDispatchQueue = nil;
}

- (void)dealloc
{
}


@end
