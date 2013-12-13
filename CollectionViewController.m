//
//  CollectionViewController.m
//  CollectionViewDynamics
//
//  Created by George Henrique Villasboas on 12/13/13.
//  Copyright (c) 2013 Logics Software. All rights reserved.
//

#import "CollectionViewController.h"
#import "CustomCollectionViewLayout.h"
#import "Cell.h"

NSString *kCellID = @"CELLID";

@interface CollectionViewController ()
@property NSInteger fetchedItens;
@end

@implementation CollectionViewController

#pragma mark -
#pragma mark Getters overriders
#pragma mark -

#pragma mark -
#pragma mark Setters overriders
#pragma mark -

#pragma mark -
#pragma mark Designated initializers
#pragma mark -

#pragma mark -
#pragma mark Public methods
#pragma mark -

#pragma mark -
#pragma mark Private methods
#pragma mark -

/**
 *  Make the inicial configuration for the Collection View
 */
- (void)configureCVLayout
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.collectionView addGestureRecognizer:tapRecognizer];
}

#pragma mark -
#pragma mark ViewController life cycle
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureCVLayout];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.fetchedItens = 5;
}


#pragma mark -
#pragma mark Overriden methods
#pragma mark -

#pragma mark -
#pragma mark Storyboards Segues
#pragma mark -

#pragma mark -
#pragma mark Target/Actions
#pragma mark -

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    CustomCollectionViewLayout *customLayout = (CustomCollectionViewLayout *)self.collectionView.collectionViewLayout;
    CGPoint initialPanPoint = [sender locationInView:self.collectionView];
    NSIndexPath *tappedCellPath = [self.collectionView indexPathForItemAtPoint:initialPanPoint];
    Cell *cell = (Cell *)[self.collectionView cellForItemAtIndexPath:tappedCellPath];
    
    if (cell) {
        NSIndexPath *indexPath = tappedCellPath;
        
        NSLog(@"numberOfSectionsInCollectionView BEFORE PERFORM BLOCK: %d", [self.collectionView numberOfSections]);
        NSLog(@"numberOfItemsInSection BEFORE PERFORM BLOCK: %d", [self.collectionView numberOfItemsInSection:0]);
        NSLog(@"FETCHED ITEMS BEFORE PERFORM BLOCK: %d", self.fetchedItens);
        [customLayout removeItemAtIndexPath:indexPath completion:^{
            self.fetchedItens--;
            NSLog(@"FETCHED ITEMS INSIDE PERFORM BLOCK: %d", self.fetchedItens);
        }];
        NSLog(@"numberOfSectionsInCollectionView AFTER PERFORM BLOCK: %d", [self.collectionView numberOfSections]);
        NSLog(@"numberOfItemsInSection AFTER PERFORM BLOCK: %d", [self.collectionView numberOfItemsInSection:0]);
        NSLog(@"FETCHED ITEMS AFTER PERFORM BLOCK: %d", self.fetchedItens);
    }
}

#pragma mark -
#pragma mark Delegates
#pragma mark -

#pragma mark Collection View Datasources

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"%s COUNT: %d", __FUNCTION__, 1);
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"%s COUNT: %d", __FUNCTION__, self.fetchedItens);
    return self.fetchedItens;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    
    NSLog(@"%s IP: %@", __FUNCTION__, indexPath);
    
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID forIndexPath:indexPath];
    cell.indexPathLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    
    return cell;
}

#pragma mark -
#pragma mark Notification center
#pragma mark -


@end
