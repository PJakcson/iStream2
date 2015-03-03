//
//  DragView.m
//  UPnPTest
//
//  Created by Florian Bethke on 24.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import "DragView.h"
#import "AppDelegate.h"
#import "GlobalLogging.h"

@implementation DragView

- (void)awakeFromNib
{
    [self registerForDraggedTypes:[NSArray arrayWithObjects:
                                   NSColorPboardType, NSFilenamesPboardType, nil]];
    
    NSImage *img = [NSImage imageNamed:@"tv_gray"];
    [self setImage:img];
}

-(NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSImage *img = [NSImage imageNamed:@"tv"];
    [self setImage:img];
    
    return NSDragOperationEvery;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    NSImage *img = [NSImage imageNamed:@"tv_gray"];
    [self setImage:img];
}


-(NSDragOperation) draggingUpdated:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"tv_show-100" ofType:@"png"];
//    NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
//    [self setImage:img];
    
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    
    DDLogInfo(@"%@", [files objectAtIndex:0]);
    
    [(AppDelegate *)[[NSApplication sharedApplication] delegate] addFiles:files];

    return false;
}

@end