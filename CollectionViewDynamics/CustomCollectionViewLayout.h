//
//  CustomCollectionViewLayout.h
//  CollectionViewDynamics
//
//  Created by George Henrique Villasboas on 12/13/13.
//  Copyright (c) 2013 Logics Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ITEM_SIZE 100
#define EDGE_INSETS UIEdgeInsetsMake(-ITEM_SIZE, 0, 0, 0)

@interface CustomCollectionViewLayout : UICollectionViewLayout

///---------------------------------------
/// @name arrays to keep track of insert, delete index paths
///---------------------------------------

@property (nonatomic, strong) NSMutableArray *deleteIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertIndexPaths;

///---------------------------------------
/// @name Dynamics
///---------------------------------------

@property (nonatomic, strong, readonly) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong, readonly) UIGravityBehavior *gravityBehaviour;
@property (nonatomic, strong, readonly) UICollisionBehavior *collisionBehaviour;
@property (nonatomic, strong, readonly) UIDynamicItemBehavior *itemBehaviour;

/**
 *  Remove a item from the given indexPath
 *
 *  @param itemToRemove The intexpath to remove
 *  @param completion   The block to be executed
 */
- (void)removeItemAtIndexPath:(NSIndexPath *)itemToRemove completion:(void (^)(void))completion;

@end
