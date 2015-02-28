//
//  DragView.m
//  UPnPTest
//
//  Created by Flo on 24.02.15.
//  Copyright (c) 2015 florianbethke. All rights reserved.
//

#import "DragView.h"
#import "AppDelegate.h"

@implementation DragView

- (void)awakeFromNib
{
    [self registerForDraggedTypes:[NSArray arrayWithObjects:
                                   NSColorPboardType, NSFilenamesPboardType, nil]];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tv-100_gray" ofType:@"png"];
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
    [self setImage:img];
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tv-100" ofType:@"png"];
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
    [self setImage:img];
    
    return NSDragOperationEvery;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"tv-100_gray" ofType:@"png"];
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
    [self setImage:img];
}


-(NSDragOperation) draggingUpdated:(id<NSDraggingInfo>)sender
{
//    NSLog(@"draggingUpdated");
    return NSDragOperationEvery;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"tv_show-100" ofType:@"png"];
//    NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
//    [self setImage:img];
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    
    NSLog(@"%@", [files objectAtIndex:0]);
    
    [(AppDelegate *)[[NSApplication sharedApplication] delegate] playFile:[files objectAtIndex:0]];

    return true;
}

@end