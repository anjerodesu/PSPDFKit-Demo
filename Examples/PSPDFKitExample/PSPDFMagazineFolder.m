//
//  PSPDFMagazineFolder.m
//  PSPDFKitExample
//
//  Copyright 2011-2012 Peter Steinberger. All rights reserved.
//

#import "AppDelegate.h"
#import "PSPDFMagazineFolder.h"
#import "PSPDFMagazine.h"

@implementation PSPDFMagazineFolder

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Static

+ (PSPDFMagazineFolder *)folderWithTitle:(NSString *)title {
    PSPDFMagazineFolder *folder = [[[self class] alloc] init];
    folder.title = title;
    return folder;
}

// only deregister if delegate belongs to us
- (void)removeMagazineFolderReferences {
    for (PSPDFMagazine *magazine in _magazines) {
        if (magazine.folder == self) {
            magazine.folder = nil;
        }
    }
}

- (void)addMagazineFolderReferences {
    for (PSPDFMagazine *magazine in _magazines) {
        magazine.folder = self;
    }    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)init {
    if ((self = [super init])) {
        _magazines = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self removeMagazineFolderReferences];
}

- (NSString *)description {
    NSString *description = [NSString stringWithFormat:@"<PSPDFMagazineFolder %@, %d magazines>", self.title, [self.magazines count]];
    return description;
}

- (NSUInteger)hash {
    return [self.title hash];
}

- (BOOL)isEqual:(id)other {
    if ([other isKindOfClass:[self class]]) {
        if (![self.title isEqual:[other title]] || !self.title || ![other title]) {
            return NO;
        }
        return YES;
    }
    else return NO;  
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (BOOL)isSingleMagazine {
    return [self.magazines count] == 1; 
}

- (PSPDFMagazine *)firstMagazine {
    PSPDFMagazine *firstMagazine = [self.magazines count] ? (self.magazines)[0] : nil; 
    return firstMagazine;
}

- (void)addMagazine:(PSPDFMagazine *)magazine {
    [_magazines addObject:magazine];
    magazine.folder = self;
    [self sortMagazines];
}

- (void)removeMagazine:(PSPDFMagazine *)magazine {
    magazine.folder = nil;
    [_magazines removeObject:magazine];
    [self sortMagazines];
}

- (void)sortMagazines {
    [_magazines sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:NO]]];
}

- (void)setMagazines:(NSArray *)magazines {
    if (magazines != _magazines) {
        [self removeMagazineFolderReferences];
        _magazines = [magazines mutableCopy];
        [self addMagazineFolderReferences];
        [self sortMagazines];
    }
}

@end
