//
//  OpenCVWrapper.h
//  MacOpenCVTest
//
//  Created by Keath Milligan on 12/29/17.
//  Copyright © 2017 Keath Milligan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FindShapeSettings : NSObject
@property bool invert;
@property int darken;
@property int blur;
@property double contrast;
@property bool threshold;
@property double thresholdValue;
@end

@interface FindCircleSettings : NSObject
@property int h1;
@property int h2;
@property int minDist;
@property int minSize;
@property int maxSize;
@end

@interface AnalysisResults : NSObject
@property int average;
@end

@interface OpenCVWrapper : NSObject

// Get OpenCV Version
+(NSString *) openCVVersionString;

+(AnalysisResults *) analyzeImage:(NSImage *)src original:(NSImage *)original;

+(void) findShapes:(NSImage *)src settings:(FindShapeSettings *)settings
 completionHandler:(void (^)(NSImage *result, NSImage *proc, NSImage *debug, int resultCount, int max))completionHandler;

+(void) findCircles:(NSImage *)src ref:(NSImage *)ref settings:(FindCircleSettings *)settings
  completionHandler:(void (^)(NSImage *result, NSImage *proc, NSImage *debug, int resultCount))completionHandler;

@end
