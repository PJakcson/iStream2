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

@interface DragView ()

@property (nonatomic, strong) NSImage *dropImg;

@end

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
    // Save old img
    _dropImg = [self image];
    
    if ([(AppDelegate *)[[NSApplication sharedApplication] delegate] hasValidDevice]) {
        
        // Set new image
        NSImage *img = [NSImage imageNamed:@"tv"];
        [self setImage:img];
        
        return NSDragOperationCopy;
    }
    else
        return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    // Restore old image
    [self setImage:_dropImg];
}


//-(NSDragOperation) draggingUpdated:(id<NSDraggingInfo>)sender
//{
//    return NSDragOperationCopy;
//}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    // Restore old image
    [self setImage:_dropImg];
    
    // Add droped files to queue
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    
    [(AppDelegate *)[[NSApplication sharedApplication] delegate] addFiles:files];

    return false;
}

- (void)mouseDown:(NSEvent *)theEvent
{    
    [(AppDelegate *)[[NSApplication sharedApplication] delegate] togglePause];
}

@end