//
//  MinimalExampleAppDelegate.m
//  MinimalExample
//
//  Copyright 2011-2012 Peter Steinberger. All rights reserved.
//

#import "MinimalExampleAppDelegate.h"

@implementation MinimalExampleAppDelegate

@synthesize window = _window;
@synthesize pdfController = _pdfController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //kPSPDFLogLevel = PSPDFLogLevelVerbose;
    
    // create the PSPDFViewController
    _pdfController = [[PSPDFViewController alloc] initWithDocument:nil];
    _pdfController.pageCurlEnabled = YES;
    _pdfController.linkAction = PSPDFLinkActionInlineBrowser;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(saveAnnotations)];
    _pdfController.leftBarButtonItems = @[saveButton];
    
    // create window and set as rootViewController
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:_pdfController];
    [self.window makeKeyAndVisible];
    
    // copy file into documents - needed to allow writing annotatons.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *fileName = @"chinese0.pdf";
        
        NSString *path = [[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Samples"] stringByAppendingPathComponent:fileName];
        NSString *docsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *newPath = [docsFolder stringByAppendingPathComponent:fileName];
        NSError *error = nil;
        if(![[NSFileManager new] fileExistsAtPath:newPath] &&
           ![[NSFileManager new] copyItemAtPath:path toPath:newPath error:&error]) {
            NSLog(@"Error while copying %@: %@", path, error);
        }else {
            // PSPDFViewController is not thread save. Use main thread to change properties.
            dispatch_async(dispatch_get_main_queue(), ^{
                PSPDFDocument *document = [PSPDFDocument PDFDocumentWithURL:[NSURL fileURLWithPath:newPath]];
                _pdfController.document = document;
                NSLog(@"Using file %@", newPath);
                NSLog(@"isEncryped:%d", document.isEncrypted);
            });
        }
    });
    
    return YES;
}

- (void)saveAnnotations {
    NSError *error = nil;
    NSUInteger dirtyAnnotationCount = [[_pdfController.document.annotationParser dirtyAnnotations] count];
    if(![_pdfController.document saveChangedAnnotationsWithError:&error]) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to save annotations.", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil] show];
    }else {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", @"") message:[NSString stringWithFormat:NSLocalizedString(@"Saved %d annotation(s)", @""), dirtyAnnotationCount] delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", @"") otherButtonTitles:nil] show];
    }
}

@end
