//
//  Shopping2AmorDialog.m
//  FlameDragon
//
//  Created by sui toney on 12-9-11.
//  Copyright 2012 ms. All rights reserved.
//

#import "Shopping2AmorDialog.h"

#import "Shopping2ShowProductDialog.h"
#import "Shopping2SelectAmorTargetDialog.h"
#import "Shopping2ConfirmDialog.h"
#import "Shopping2MessageDialog.h"
#import "Shopping2ShowItemsDialog.h"

@implementation Shopping2AmorDialog

// Override Method
-(void) generateButtonArray
{
	[buttonArray addObject:[self button_BuyAmor]];
	[buttonArray addObject:[self button_Sell]];
	[buttonArray addObject:[self button_Equip]];
	[buttonArray addObject:[self button_GiveItem]];
	
}

-(void) onBuyAmor
{
	
	NSLog(@"onBuyAmor");
	
	// NSMutableArray *list = [self getProductList:chapterRecord.chapterId Type:DataDepotShopType_AmorShop];
	ShopDefinition *shop = [[DataDepot depot] getShopDefinition:chapterRecord.chapterId Type:DataDepotShopType_AmorShop];
	
	// Shopping2ShowProductDialog *dialog = [[Shopping2ShowProductDialog alloc] initWithList:shop.itemList];
	Shopping2ShowItemsDialog *dialog = [[Shopping2ShowItemsDialog alloc] initWithItemList:shop.itemList pageIndex:0];
	
	[self showDialog:dialog Callback:@selector(onBuyAmor_SelectedAmor:)];
	[dialog release];
}

-(void) onBuyAmor_SelectedAmor:(NSNumber *)num
{
	int selectedNum = [num intValue];
	
	if (selectedNum < 0) {
		switch (selectedNum) {
			case -1:
				// Cancel
				return;
			case -2:
				// Go Up Page
				lastPageIndex --; break;
			case -3:
				// Go Down Page
				lastPageIndex ++; break;
			default:
				break;
		}
		
		ShopDefinition *shop = [[DataDepot depot] getShopDefinition:chapterRecord.chapterId Type:DataDepotShopType_AmorShop];
		
		Shopping2ShowItemsDialog *dialog = [[Shopping2ShowItemsDialog alloc] initWithItemList:shop.itemList pageIndex:lastPageIndex];
		[self showDialog:dialog Callback:@selector(onBuyAmor_SelectedAmor:)];
		[dialog release];
		
		return;
	} 
	
	NSLog(@"onBuyAmor_SelectedAmor : %d", selectedNum);
	
	ShopDefinition *shop = [[DataDepot depot] getShopDefinition:chapterRecord.chapterId Type:DataDepotShopType_AmorShop];
	NSNumber *itemId  = [shop.itemList objectAtIndex:selectedNum];
	
	ItemDefinition *item = [[DataDepot depot] getItemDefinition:[itemId intValue]];
	
	// Confirm Message
	NSString *message = [NSString stringWithFormat:[FDLocalString confirm:54], item.name, item.price];
	
	Shopping2ConfirmDialog *dialog = [[Shopping2ConfirmDialog alloc] initWithMessage:message];
	[self showDialog:dialog Callback:@selector(onBuyAmor_ConfirmedAmor:)];
	[dialog release];
}

-(void) onBuyAmor_ConfirmedAmor:(NSNumber *)num
{
	int selectedNum = [num intValue];
	
	if (selectedNum <= 0) {
		// Cancelled
		
		[self onBuyAmor];
		return;
	}
	
	lastSelectedItemIndex = selectedNum;
	
	ItemDefinition *item = [self getItemDefinition:chapterRecord.chapterId Type:DataDepotShopType_AmorShop Index:lastSelectedItemIndex];
	if (chapterRecord.money < item.price) {
		
		// If not enough money
		NSString *message = [FDLocalString message:63];
		Shopping2MessageDialog *dialog = [[Shopping2MessageDialog alloc] initWithMessage:message];
		[self showDialog:dialog Callback:nil];
		[dialog release];
	}
	else {
		Shopping2SelectAmorTargetDialog *dialog = [[Shopping2SelectAmorTargetDialog alloc] init];
		[self showDialog:dialog Callback:@selector(onBuyAmor_SelectedTarget:)];
		[dialog release];
	}
}

-(void) onBuyAmor_SelectedTarget:(NSNumber *)num
{
	int selectedNum = [num intValue];
	
	if (selectedNum < 0) {
		// Cancelled
		
		return;
	} 
	
	lastSelectedCreatureIndex = selectedNum;
	
	CreatureRecord *friend = [[chapterRecord friendRecords] objectAtIndex:lastSelectedCreatureIndex];
	
	// Check if the item list is full
	if ([friend.data.itemList count] >= 8) {
		
		NSString *message = [FDLocalString message:62];
		Shopping2MessageDialog *dialog = [[Shopping2MessageDialog alloc] initWithMessage:message];
		[self showDialog:dialog Callback:nil];
		[dialog release];
		
		return;
	} else {
		
		// Confirm Message
		NSString *message = [FDLocalString confirm:56];
		Shopping2ConfirmDialog *dialog = [[Shopping2ConfirmDialog alloc] initWithMessage:message];
		[self showDialog:dialog Callback:@selector(onBuyAmor_Done:)];
		[dialog release];
	}
}

-(void) onBuyAmor_Done:(NSNumber *)num
{
	int selectedNum = [num intValue];
	
	NSLog(@"Amor Bought");
	
	// Buy that amor
	ItemDefinition *item = [self getItemDefinition:chapterRecord.chapterId Type:DataDepotShopType_AmorShop Index:lastSelectedItemIndex];
	chapterRecord.money -= item.price;
	
	if (selectedNum == 1) {
		// Equip this item
		
		
	}
}

@end
