//
//  CustomCollectionViewLayout.m
//  CollectionViewDynamics
//
//  Created by George Henrique Villasboas on 12/13/13.
//  Copyright (c) 2013 Logics Software. All rights reserved.
//

#import "CustomCollectionViewLayout.h"

@interface CustomCollectionViewLayout()

@property (nonatomic, strong, readwrite) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong, readwrite) UIGravityBehavior *gravityBehaviour;
@property (nonatomic, strong, readwrite) UICollisionBehavior *collisionBehaviour;
@property (nonatomic, strong, readwrite) UIDynamicItemBehavior *itemBehaviour;

@end

@implementation CustomCollectionViewLayout

#pragma mark -
#pragma mark Getters overriders
#pragma mark -

#pragma mark -
#pragma mark Setters overriders
#pragma mark -

#pragma mark -
#pragma mark Designated initializers
#pragma mark -

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    
    return self;
}

#pragma mark -
#pragma mark Public methods
#pragma mark -

/**
 *  Remove a item from the given indexPath
 *
 *  @param itemToRemove The intexpath to remove
 *  @param completion   The block to be executed
 */
- (void)removeItemAtIndexPath:(NSIndexPath *)itemToRemove completion:(void (^)(void))completion
{
    UICollectionViewLayoutAttributes *attributes = [self.dynamicAnimator layoutAttributesForCellAtIndexPath:itemToRemove];
    
    [self.collisionBehaviour removeItem:attributes];
    [self.gravityBehaviour removeItem:attributes];
    [self.itemBehaviour removeItem:attributes];
    
    
    [self.collectionView performBatchUpdates:^{
        completion();
        [self.collectionView deleteItemsAtIndexPaths:@[itemToRemove]];
        NSLog(@"numberOfSectionsInCollectionView INSIDE PERFORM BLOCK: %d", [self.collectionView numberOfSections]);
        NSLog(@"numberOfItemsInSection INSIDE PERFORM BLOCK: %d", [self.collectionView numberOfItemsInSection:0]);
    } completion:^(BOOL finished) {
        if (finished) {
        }
    }];
}

#pragma mark -
#pragma mark Private methods
#pragma mark -

/**
 *  Initialize the layout
 */
- (void)initialize
{
    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    
    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[]];
    gravityBehaviour.gravityDirection = CGVectorMake(0, 1);
    self.gravityBehaviour = gravityBehaviour;
    [self.dynamicAnimator addBehavior:gravityBehaviour];
    
    self.collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[]];
    self.collisionBehaviour.collisionMode = UICollisionBehaviorModeEverything;
    self.collisionBehaviour.translatesReferenceBoundsIntoBoundary = YES;
    [self.dynamicAnimator addBehavior:self.collisionBehaviour];
    
    self.itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[]];
    self.itemBehaviour.elasticity = 0.6;
    [self.dynamicAnimator addBehavior:self.itemBehaviour];
}

/**
 *  Add the uikit dynamics to the cell at a given indexpath
 *
 *  @param indexPath The index path to add the dynamics
 */
- (void)addDynamicsToCellAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    CGFloat positionX = [self xPositionForCellWithIndex:indexPath.row];
    CGFloat positionY = [[self randomNumberBetween:0 to:ITEM_SIZE] floatValue];
    
    attributes.frame = CGRectMake(positionX, -positionY, ITEM_SIZE, ITEM_SIZE);
    
    [self.collisionBehaviour addItem:attributes];
//    [self.collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:EDGE_INSETS];
    [self.gravityBehaviour addItem:attributes];
    [self.itemBehaviour addItem:attributes];
}

/**
 *  Generates random number between to other given ones
 *
 *  @param from Lower limit for number generation
 *  @param to   Higher limit for number generation
 *
 *  @return A random number between from and to.
 */
- (NSNumber *)randomNumberBetween:(int)from to:(int)to
{
    int randomNumber = (int)from + arc4random() % (to-from+1);
    return @(randomNumber);
}

/**
 *  Get the x position of the cell in index
 *
 *  @param index The cell index
 *
 *  @return The position in X
 */
- (NSUInteger)xPositionForCellWithIndex:(NSUInteger)index
{
    NSUInteger maxCellsPerLine = (int)CGRectGetWidth(self.collectionView.frame)/ITEM_SIZE;
    return (ITEM_SIZE * (index % maxCellsPerLine)) + [[self randomNumberBetween:0 to:5] integerValue];
}


#pragma mark -
#pragma mark Overridden Methods
#pragma mark -

- (void)prepareLayout
{
    [super prepareLayout];
    
    if (self.collisionBehaviour.items.count == 0 || self.gravityBehaviour.items.count == 0) {
        NSUInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
        for (NSUInteger index = 0; index < numberOfItems; index++){
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [self performSelector:@selector(addDynamicsToCellAtIndexPath:) withObject:indexPath afterDelay:index*0.2];
        }
    }
}

- (CGSize)collectionViewContentSize
{
    return self.collectionView.bounds.size;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.deleteIndexPaths = [NSMutableArray array];
    self.insertIndexPaths = [NSMutableArray array];
    
    [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
        if (updateItem.updateAction == UICollectionUpdateActionInsert){
            [self addDynamicsToCellAtIndexPath:updateItem.indexPathAfterUpdate];
            [self.insertIndexPaths addObject:updateItem.indexPathAfterUpdate];
        }
        else if (updateItem.updateAction == UICollectionUpdateActionDelete){
            [self.deleteIndexPaths addObject:updateItem.indexPathBeforeUpdate];
        }
    }];
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    
    // release the insert and delete index paths
    // We dont want strong pointers to them
    self.deleteIndexPaths = nil;
    self.insertIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // Must call super
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    // So far, calling super hasn't been strictly necessary here, but leaving it in
    // for good measure
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if ([self.deleteIndexPaths containsObject:itemIndexPath]){
        // only change attributes on deleted cells
        if (!attributes)
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        
        // Configure attributes ...
        attributes.alpha = 0.0;
        //        attributes.center = CGPointMake(self.center.x, self.center.y);
        attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
    }else{
        attributes.alpha = 1.0;
    }
    
    return attributes;
}


#pragma mark -
#pragma mark Target/Actions
#pragma mark -

#pragma mark -
#pragma mark Delegates
#pragma mark -

#pragma mark -
#pragma mark Notification center
#pragma mark -

@end