//
//  AppDelegate.m
//  UPnPTest
//
//  Created by Florian Bethke on 19.02.15.
//  Copyright (c) 2015 Florian Bethke. All rights reserved.
//

#import "AppDelegate.h"
#import "XMLDictionary.h"
#import "SSDPRequest.h"
#import "UPNPDevice.h"
#import "CMService.h"
#import "AVTService.h"
#import "DIDLMetadata.h"
#import "HTTPServer.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"
#import "DragView.h"
#import "GlobalLogging.h"

@interface AppDelegate ()

// UI Elements
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSPopUpButton *devList;
@property (weak) IBOutlet NSProgressIndicator *wheel;
@property (weak) IBOutlet DragView *dragView;
@property (weak) IBOutlet NSTextField *durLabel;
@property (weak) IBOutlet NSTextField *posLabel;
@property (weak) IBOutlet NSSlider *slider;
@property (weak) IBOutlet NSButton *toggleDrawer;
@property (weak) IBOutlet NSDrawer *queueDrawer;
@property (weak) IBOutlet NSDrawer *sliderDrawer;
@property (weak) IBOutlet NSTableView *queueTable;

// General properties 
@property (nonatomic, strong) HTTPServer *server;
@property (nonatomic, strong) NSString *serverAddress;
@property (nonatomic, strong) UPNPDevice *lastDevice;
@property (nonatomic, strong) NSTimer *tim;
@property (nonatomic, strong) NSMutableArray *fileNames;
@property (nonatomic, strong) NSMutableArray *filePaths;
@property (nonatomic) NSUInteger slideCount;

// Current device state
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *pos;
@property (nonatomic, strong) NSString *dur;
@property (nonatomic, strong) NSString *curURI;
@property (nonatomic, strong) NSString *type;


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Setup logger
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    // Init variables
    _upnpDevices = [[NSMutableDictionary alloc] init];
    _udnList = [[NSMutableArray alloc] init];
    [_wheel startAnimation:nil];
    ssdp = [[SSDPRequest alloc] initWithDelegate:self];
    [_queueTable registerForDraggedTypes:[NSArray arrayWithObject:(NSString*)kUTTypeFileURL]];
    [_queueTable setDoubleAction:@selector(doubleAction:)];
    _fileNames = [[NSMutableArray alloc] init];
    _filePaths = [[NSMutableArray alloc] init];
    _slideCount = 0;
    
    // Send initial SSDP search request
    [ssdp ssdpMSEARCHRequest];
    
    // Start HTTP server
    _server = [[HTTPServer alloc] init];
    
    NSError *error = nil;
    if(![_server start:&error])
    {
        DDLogError(@"Error starting HTTP Server: %@", error);
    }

    // Get server address and save it
    NSArray *addresses = [[NSHost currentHost] addresses];
    NSString *addrString;
    for (NSString *address in addresses) {
        if (![address hasPrefix:@"127"] && [[address componentsSeparatedByString:@"."] count] == 4) {
            addrString = address;
            break;
        } else {
            addrString = @"" ;
        }
    }
    if ([addrString isEqualToString:@""]) {
        DDLogError(@"Error: IP address not available!");
        return;
    }
    
    _serverAddress = [NSString stringWithFormat:@"http://%@:%d", addrString, [_server listeningPort]];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Stop playback
    if (_lastDevice)
        [(AVTService *)[[_lastDevice services] objectForKey:@"AVTService"] stop:@"0"];
    
    // Stop HTTP server
    [_server stop];
}

#pragma mark SSDP Handling

-(void)gotSSDPResponseWithLocation:(NSString *)location UDN:(NSString *)UDN
{
    DDLogInfo(@"Response: %@", location);
    
    // Check if device is already known
    UPNPDevice *device = [_upnpDevices objectForKey:UDN];
    if (device == nil)
    {
        // Create new device
        device = [[UPNPDevice alloc] init];
        [device setUDN:UDN];
        [device setLocation:location];

        // Get device description file and parse it
        NSURL *locUrl = [NSURL URLWithString:location];
        NSURLRequest* urlRequest=[NSURLRequest requestWithURL:locUrl
                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
                                              timeoutInterval:0.5];
        NSHTTPURLResponse *urlResponse;
        NSData *dat = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:nil];
        if ([urlResponse statusCode] != 200)    // Check availability
        {
            DDLogError(@"Error: Description file is unavailable!");
            return;
        }

        DDLogVerbose(@"Device description: %@", [[NSString alloc] initWithData:dat encoding:NSUTF8StringEncoding]);
        XMLDictionaryParser *XMLParser = [XMLDictionaryParser sharedInstance];
        NSDictionary *dict = [XMLParser dictionaryWithData:dat];
        
        // Get device name
        [device setFriendlyName:[[dict objectForKey:@"device"] objectForKey:@"friendlyName"]];
        
        // Get host address from location string
        NSString *host = [[[location stringByReplacingOccurrencesOfString:@"http://" withString:@""] componentsSeparatedByString:@"/"] objectAtIndex:0];
        host = [NSString stringWithFormat:@"http://%@/",host];
        DDLogInfo(@"Host: %@", host);
        
        // Get supported services
        NSArray *services = [[[dict objectForKey:@"device"] objectForKey:@"serviceList"] objectForKey:@"service"];
        
        if (![services isKindOfClass:[NSArray class]])
            return;
        for (NSDictionary *service in services)
        {
            if ([[service objectForKey:@"serviceId"] isEqualToString:@"urn:upnp-org:serviceId:ConnectionManager"]){
                CMService *upnpservice = [[CMService alloc] init];
                [upnpservice setUpnpNameSpace:[service objectForKey:@"serviceType"]];
                [upnpservice setControlURL:[service objectForKey:@"controlURL"]];
                [upnpservice setEventURL:[service objectForKey:@"eventSubURL"]];
                [upnpservice setHost:host];
                [device addService:upnpservice];
            }
            else if ([[service objectForKey:@"serviceId"] isEqualToString:@"urn:upnp-org:serviceId:AVTransport"]){
                AVTService *upnpservice = [[AVTService alloc] init];
                [upnpservice setUpnpNameSpace:[service objectForKey:@"serviceType"]];
                [upnpservice setControlURL:[service objectForKey:@"controlURL"]];
                [upnpservice setEventURL:[service objectForKey:@"eventSubURL"]];
                [upnpservice setHost:host];
                [device addService:upnpservice];
            }
        }
        
        // Check if required services are available
        if (![device checkValidity]){
            [_upnpDevices setObject:device forKey:UDN]; // Add device so we don't query it again
            DDLogInfo(@"Found invalid device: %@ at %@", [device friendlyName], host);
            return;
        }
        else
            DDLogInfo(@"Found valid device: %@ at %@", [device friendlyName], host);
        
        // Subscribe to event
//        [[[device services] objectForKey:@"AVTService"] subscribe];
        
        
        // Get protocol info
        [device updateProtocolInfo];
        if (ddLogLevel >= LOG_LEVEL_VERBOSE)
            [device printInfoVerbose];
        
        // Add device to dictionary
        [_upnpDevices setObject:device forKey:UDN];
        [_udnList addObject:UDN];
        
        // Perform UI operations on main thread
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Update PopUp Button
            if ([_udnList count] == 1) {  // First object was just added
                [_devList removeAllItems];
                [_devList setEnabled:true];
                [_wheel stopAnimation:nil];
            }
            [_devList addItemWithTitle:[device friendlyName]];
            [[_devList lastItem] setTag:[_udnList count]-1];
        });
    }
}

-(void)removeDevice:(NSString *)UDN
{
    // Check if device was known
    NSUInteger idx = [_udnList indexOfObject:UDN];
    if (idx != NSNotFound)
    {
        // Remove device from dictionary / array
        [_udnList removeObjectAtIndex:idx];
        [_upnpDevices removeObjectForKey:UDN];
        DDLogInfo(@"Removed device: %@", UDN);
        
        // Remove device from UI (on main thread)
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_devList removeItemAtIndex:idx];
            
            // Fix tags of remaining devices
            NSInteger count = [_devList numberOfItems];
            if (count == 0)
                [_devList addItemWithTitle:@"No device found"];
            for (NSUInteger i=idx; i<count;i++)
            {
                [[_devList itemAtIndex:i] setTag:i-1];
            }
        });
        
        // Set _lastDevice to nil if it was just removed
        if (_lastDevice)
        {
            if ([[_lastDevice UDN] isEqualToString:UDN]) {
                [self setDisabled];
                _state = nil;
            }
        }
    }
}

#pragma mark UPNP Handling

- (void)addFiles:(NSArray *)files
{
    // Enable files for HTTP serving
    [_server addFilePaths:files];
    
    // Start modal if neccessary
    if (_state && ![_state isEqualToString:@"STOPPED"]) {
        [NSApp activateIgnoringOtherApps:YES];
        NSAlert *alert = [[NSAlert alloc] init];
        NSString *msg = [NSString stringWithFormat:@"%lu new file(s)!", (unsigned long)[files count]];
        [alert setMessageText:msg];
        [alert setInformativeText:@"Play new file(s) immediately or add to them to playback queue?"];
        [alert addButtonWithTitle:@"Play"];
        [alert addButtonWithTitle:@"Add to Queue"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse rc) {
            switch(rc) {
                case NSAlertFirstButtonReturn:
                    // Delete queue and start playing
                    DDLogInfo(@"Play new file(s)");
                    [_filePaths removeAllObjects];
                    [_fileNames removeAllObjects];
                    [self playFile:[files firstObject]];
                    
                    // Set next file if available, otherwise close drawer
                    if ([files count]>1)
                        [self nextFile:[files objectAtIndex:1]];
                    else
                        [_queueDrawer close];
                    break;
                    
                case NSAlertSecondButtonReturn:
                    DDLogInfo(@"Queue new file(s)");
                    
                    // Set next file if neccessary (currently playing last file in queue)
                    NSUInteger idx = [_fileNames indexOfObject:[[_curURI componentsSeparatedByString:@"/"] lastObject]];
                    if (idx != NSNotFound && idx == [_fileNames count]-1)
                        [self nextFile:[files firstObject]];
                    break;
                    
                case NSAlertThirdButtonReturn:
                    // Do nothing, just return
                    DDLogInfo(@"Cancel adding new files");
                    return;
            }
            
            // Update file lists
            [self updateFileLists:files];
        }];

    }
    else {
        // Update file lists
        [self updateFileLists:files];
        
        // Play file
        [self playFile:[files firstObject]];
        if ([files count]>1)
            [self nextFile:[files objectAtIndex:1]];

    }
}

- (void)updateFileLists:(NSArray *)files
{
    // Save full filepaths
    [_filePaths addObjectsFromArray:files];
    
    // Save filenames (last component of string)
    for (NSString *file in files)
        [_fileNames addObject:[[file componentsSeparatedByString:@"/"] lastObject]];
    
    // Update GUI
    [_queueTable reloadData];
    
    if ([_filePaths count]>1) {
        [_queueDrawer open];
    }
}

- (void)playFile:(NSString *)filePath
{
    // Stop last file
    if (_lastDevice)
        [(AVTService *)[[_lastDevice services] objectForKey:@"AVTService"] stop:@"0"];
    
    // Stop timer
    if (_tim)
        [_tim invalidate];
    
    // Build address
    NSString *filename = [[filePath componentsSeparatedByString:@"/"] lastObject];
    NSString *address = [NSString stringWithFormat:@"%@/%@", _serverAddress, filename];
    
    // Play!
    NSString *currentUDN = [_udnList objectAtIndex:[[_devList selectedItem] tag]];
    _lastDevice = [_upnpDevices objectForKey:currentUDN];
    [_wheel startAnimation:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        bool result = [_lastDevice playFile:filePath atAddress:address];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_wheel stopAnimation:nil];
            if (result) {
                NSImage *img = [NSImage imageNamed:@"tv_play"];
                [_dragView setImage:img];
                _curURI = address;
                _type = [[[DIDLMetadata getMIMEType:filePath] componentsSeparatedByString:@"/"] firstObject];
                
                // Select row in table view
                NSUInteger idx = [_filePaths indexOfObject:filePath];
                if (idx != NSNotFound) {
                    NSIndexSet *idxset = [NSIndexSet indexSetWithIndex:idx];
                    [_queueTable selectRowIndexes:idxset byExtendingSelection:NO];
                }
                
                // Start timer
                _tim = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(update:)
                                                      userInfo:nil
                                                       repeats:true];
                
                // If (multiple!) image files: Enable slideshow timer
                NSString *mime = [DIDLMetadata getMIMEType:filePath];
                NSString *category = [[mime componentsSeparatedByString:@"/"] firstObject];
                if ([category isEqualToString:@"image"]) {
                    DDLogInfo(@"Playing image file!");
//                    sleep(10);
//                    [[[_lastDevice services] objectForKey:@"AVTService"] next:@"0"];
                }
            }
            else {
                NSImage *img = [NSImage imageNamed:@"tv_err"];
                [_dragView setImage:img];
                [_lastDevice printInfoVerbose];
                _lastDevice = nil;
            }
        });
        
    });
    
}

- (void)nextFile:(NSString *)filePath
{
    // Build address
    NSString *filename = [[filePath componentsSeparatedByString:@"/"] lastObject];
    NSString *address = [NSString stringWithFormat:@"%@/%@", _serverAddress, filename];
    DDLogInfo(@"Setting next URI: %@", address);
    
    // Set next file
    if (_lastDevice)
        [_lastDevice nextFile:filePath atAddress:address];
    
}

- (void)setDisabled
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Set UI to disabled state
        NSImage *img = [NSImage imageNamed:@"tv"];
        [_dragView setImage:img];
        [_toggleDrawer setEnabled:false];
        [_toggleDrawer setState:NSOffState];
        [_slider setEnabled:false];
        [_slider setDoubleValue:0.0];
        [_posLabel setStringValue:@"0:00:00"];
        [_durLabel setStringValue:@"0:00:00"];
        [_queueTable reloadData];
        
        if (![_state isEqualToString:@"STOPPED"]) {
            // Close all drawers
            [_sliderDrawer close];
            [_queueDrawer close];
            
            // Delete queue
            [_fileNames removeAllObjects];
            [_filePaths removeAllObjects];
            _slideCount = 0;
            
            // Reset last device
            _lastDevice = nil;
        }
    });
}

- (void)update:(NSTimer *)t
{
    // Get play state if _lastDevice exists
    if (_lastDevice) {
        AVTService *avt = [[_lastDevice services] objectForKey:@"AVTService"];
        NSDictionary *positionInfo = [avt getPositionInfo:@"0"];
        NSDictionary *transportInfo = [avt getTransportInfo:@"0"];
        NSDictionary *mediaInfo = [avt getMediaInfo:@"0"];
        
        // Try again, then disable
        if (!positionInfo || !transportInfo) {
            sleep(3);
            positionInfo = [avt getPositionInfo:@"0"];
            transportInfo = [avt getTransportInfo:@"0"];
            if (!positionInfo || !transportInfo) {
                _state = @"";
                [self setDisabled];
                DDLogInfo(@"Disabling in Update!");
                return;
            }
        }
        
        // Image slideshow...
        if ([_type isEqualToString:@"image"]) {
            _slideCount++;
            [_slider setEnabled:false];
            DDLogInfo(@"Image: %lu", (unsigned long) _slideCount);
            if (_slideCount == 10) {
                NSString *filename = [[_curURI componentsSeparatedByString:@"/"] lastObject];
                NSUInteger idx = [_fileNames indexOfObject:filename];
                DDLogInfo(@"Next Info: %@, Idx: %lu", filename, (unsigned long)idx);
                if (idx == NSNotFound) {    // TODO: Auch an anderen Stellen!
                    NSString *escFileName = [filename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    idx = [_fileNames indexOfObject:escFileName];
                    DDLogInfo(@"Next Info: %@, Idx: %lu", escFileName, (unsigned long)idx);
                }
                    
                if (idx != NSNotFound && [_fileNames count] > idx+1) {
                    [self playFile:[_filePaths objectAtIndex:idx+1]];
                    _slideCount = 0;
                }
            }
        }
        else
            [_slider setEnabled:true];

        
        // Check if current URI has changed
        NSString *newURI = [mediaInfo objectForKey:@"CurrentURI"];
        if (![_curURI isEqualToString:newURI]) {
            NSString *filename = [[newURI componentsSeparatedByString:@"/"] lastObject];
            NSUInteger idx = [_fileNames indexOfObject:filename];
            if (filename != nil && ![filename isEqualToString:@""]) {   // Fix for wrong CurrentURI in Kodi
                _curURI = newURI;
            }
            if (idx != NSNotFound)
                _type = [[[DIDLMetadata getMIMEType:[_filePaths objectAtIndex:idx]] componentsSeparatedByString:@"/"] firstObject];
            
            // Set next file in queue
            if (idx != NSNotFound && idx < [_fileNames count]-1) {
                [self nextFile:[_filePaths objectAtIndex:idx+1]];
            }
            
            // Select row in table view
            if (idx != NSNotFound) {
                NSIndexSet *idxset = [NSIndexSet indexSetWithIndex:idx];
                [_queueTable selectRowIndexes:idxset byExtendingSelection:NO];
            }
        }
        
        NSString *oldstate = _state;
        _state = [transportInfo objectForKey:@"CurrentTransportState"];
        _pos = [positionInfo objectForKey:@"RelTime"];
        _dur = [positionInfo objectForKey:@"TrackDuration"];
        
        // Update GUI (in main thread)
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update state image
            if (![_state isEqualToString:oldstate]) {
                // Case transitioning
                if ([_state isEqualToString:@"STOPPED"]) {
                    [self setDisabled];
                    DDLogInfo(@"Disabling because Stopped!");
                } else if ([_state isEqualToString:@"PLAYING"]) {
                    NSImage *img = [NSImage imageNamed:@"tv_play"];
                    [_dragView setImage:img];
                    [_toggleDrawer setEnabled:true];
                    [_slider setEnabled:true];
                } else if ([_state isEqualToString:@"PAUSED_PLAYBACK"]) {
                    NSImage *img = [NSImage imageNamed:@"tv_pause"];
                    [_dragView setImage:img];
                }
            }
            
            // Update drawer
            if (_pos && _dur) {
                [_posLabel setStringValue:_pos];
                [_durLabel setStringValue:_dur];
                float fraction = [self fraction:_pos withDuration:_dur]*100;
                if (fraction != 0)
                    [_slider setFloatValue:fraction];
            }
        });
    }
}

// TODO: Use NSDate?
-(float)fraction:(NSString *)pos withDuration:(NSString *)dur
{
    NSArray *comp = [pos componentsSeparatedByString:@":"];
    float pos_sec = [[comp objectAtIndex:0] floatValue]*3600 + [[comp objectAtIndex:1] floatValue]*60 + [[comp objectAtIndex:2] floatValue];
    
    comp = [dur componentsSeparatedByString:@":"];
    float dur_sec = [[comp objectAtIndex:0] floatValue]*3600 + [[comp objectAtIndex:1] floatValue]*60 + [[comp objectAtIndex:2] floatValue];
    
    return pos_sec/dur_sec;
}

// TODO: Use NSDate?
-(NSString *)position:(float)fraction withDuration:(NSString *)dur
{
    NSArray *comp = [dur componentsSeparatedByString:@":"];
    int dur_sec = [[comp objectAtIndex:0] floatValue]*3600 + [[comp objectAtIndex:1] floatValue]*60 + [[comp objectAtIndex:2] floatValue];
    int pos_sec = dur_sec*fraction;
    
    int h = pos_sec/3600;
    int m = (pos_sec%3600)/60;
    int s = (pos_sec%60);
    
    NSString *h_str = [NSString stringWithFormat:@"%i", h];
    if (h<10)
        h_str = [NSString stringWithFormat:@"0%i", h];
    
    NSString *m_str = [NSString stringWithFormat:@"%i", m];
    if (m<10)
        m_str = [NSString stringWithFormat:@"0%i", m];
    
    NSString *s_str = [NSString stringWithFormat:@"%i", s];
    if (s<10)
        s_str = [NSString stringWithFormat:@"0%i", s];
    
    return [NSString stringWithFormat:@"%@:%@:%@",h_str,m_str,s_str];
}

#pragma mark IBActions

- (IBAction)updateSSDP:(id)sender
{
    [ssdp ssdpMSEARCHRequest];
}

- (IBAction)seek:(id)sender
{
    float fraction = [_slider floatValue]/100;
    NSDate *newFireDate = [[_tim fireDate] dateByAddingTimeInterval:3.0];   // Workaround for slow clients
    [_tim setFireDate:newFireDate];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *pos = [self position:fraction withDuration:_dur];
        [[[_lastDevice services] objectForKey:@"AVTService"] seek:@"0" Unit:@"REL_TIME" Target:pos];
    });
}

#pragma mark Table View (Queue)

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_fileNames count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSUInteger cnt = [_fileNames count];
    if (cnt && cnt >= rowIndex)
        return [_fileNames objectAtIndex:rowIndex];
    
    return @"";
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return NO;
}

- (void)doubleAction:(id)sender
{
    NSInteger row = [_queueTable clickedRow];
    if (row != -1) {
        // Play new file
        [self playFile:[_filePaths objectAtIndex:row]];

        // Set next file if available
        if ([_filePaths count]>row+1)
            [self nextFile:[_filePaths objectAtIndex:row+1]];
    }
}

- (BOOL)tableView:(NSTableView *)aTableView
       acceptDrop:(id<NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)operation
{
    // Get list of files
    NSPasteboard *pboard = [info draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    NSRange idxrange = NSMakeRange(row, [files count]);
    NSIndexSet *idxset = [NSIndexSet indexSetWithIndexesInRange:idxrange];
    
    // Enable files for HTTP serving
    [_server addFilePaths:files];
    
    // Save full filepaths
    [_filePaths insertObjects:files atIndexes:idxset];
    
    // Save filenames (last component of string)
    NSMutableArray *filenames = [[NSMutableArray alloc] init];
    for (NSString *file in files)
        [filenames addObject:[[file componentsSeparatedByString:@"/"] lastObject]];
    [_fileNames insertObjects:filenames atIndexes:idxset];
    
    // Update next file if neccessary
    NSUInteger idx = [_fileNames indexOfObject:[[_curURI componentsSeparatedByString:@"/"] lastObject]];
    if (idx != NSNotFound && idx == row-1)
        [self nextFile:[files firstObject]];
    
    // Update GUI
    [_queueTable reloadData];
    DDLogInfo(@"Added files: %@ at row: %lu", files, (long)row);
    
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
    if (operation == NSTableViewDropAbove)
        return NSDragOperationCopy;
    
    return NSDragOperationNone;
}


@end
