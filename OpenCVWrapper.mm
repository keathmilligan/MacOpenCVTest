//
//  OpenCVWrapper.m
//  MacOpenCVTest
//
//  Created by Keath Milligan on 12/29/17.
//  Copyright © 2017 Keath Milligan. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <AppKit/AppKit.h>

#import "OpenCVWrapper.h"


@implementation FindShapeSettings

-(id) init
{
    self = [super init];
    
    [self setInvert:true];
    [self setDarken:100];
    [self setBlur:1];
    [self setContrast:0];
    [self setThreshold:true];
    [self setThresholdValue:50];
    
    return self;
}

@end

@implementation FindCircleSettings

-(id) init
{
    self = [super init];
    
    [self setH1:100];
    [self setH2:40];
    [self setMinDist:40];
    [self setMinSize:30];
    [self setMaxSize:100];
    
    return self;
}

@end

@implementation AnalysisResults

-(id) init
{
    self = [super init];
    return self;
}

@end


NSImage *MatToNSImage(const cv::Mat &cvMat) {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1)
    {
        colorSpace = CGColorSpaceCreateDeviceGray();
    }
    else
    {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
                                        cvMat.rows,                                     // Height
                                        8,                                              // Bits per component
                                        8 * cvMat.elemSize(),                           // Bits per pixel
                                        cvMat.step[0],                                  // Bytes per row
                                        colorSpace,                                     // Colorspace
                                        kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
                                        provider,                                       // CGDataProviderRef
                                        NULL,                                           // Decode
                                        false,                                          // Should interpolate
                                        kCGRenderingIntentDefault);                     // Intent
    
    
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
    NSImage *image = [[NSImage alloc] init];
    [image addRepresentation:bitmapRep];
    
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return image;
}

CGImageRef cgImage(NSImage *img) {
    CGContextRef bitmapCtx = CGBitmapContextCreate(NULL/*data - pass NULL to let CG allocate the memory*/,
                                                   img.size.width,
                                                   img.size.height,
                                                   8 /*bitsPerComponent*/,
                                                   0 /*bytesPerRow - CG will calculate it for you if it's allocating the data.  This might get padded out a bit for better alignment*/,
                                                   [[NSColorSpace genericRGBColorSpace] CGColorSpace],
                                                   kCGBitmapByteOrder32Host|kCGImageAlphaPremultipliedFirst);
    
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:bitmapCtx flipped:NO]];
    [img drawInRect:NSMakeRect(0,0, [img size].width, [img size].height) fromRect:NSZeroRect operation:NSCompositingOperationCopy fraction:1.0];
    [NSGraphicsContext restoreGraphicsState];
    
    CGImageRef imageRef = CGBitmapContextCreateImage(bitmapCtx);
    CGContextRelease(bitmapCtx);
    return imageRef;
}

cv::Mat NSImageToMat(NSImage *img) {
    CGImageRef imageRef = cgImage(img);

    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGFloat cols = img.size.width;
    CGFloat rows = img.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return cvMat;
}

cv::Mat NSImageToGrayscaleMat(NSImage *img) {
    CGImageRef imageRef = cgImage(img);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat cols = img.size.width;
    CGFloat rows = img.size.height;
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channel
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
                                                    cols,                      // Width of bitmap
                                                    rows,                     // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNone |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return cvMat;
}

void adjustImage(cv::Mat &img, bool invert, int darken, int blur, double contrast) {
    // blur it to remove noise
    if (blur > 0) {
        cv::GaussianBlur(img, img, cv::Size(0, 0), blur, blur);
    }
    
    // bump up contrast
    if (contrast != 0.0) {
        img.convertTo(img, -1, contrast, 0);
    }

    // darken
    if (darken != 0) {
        img.convertTo(img, -1, 1, darken);
    }
    
    // invert it
    if (invert) {
        cv::subtract(cv::Scalar::all(255), img, img);
    }
}

@implementation OpenCVWrapper

+(NSString *) openCVVersionString
{
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

+(AnalysisResults *) analyzeImage:(NSImage *)src original:(NSImage *)original
{
    AnalysisResults *results = [[AnalysisResults alloc] init];
    
    return results;
}

+(void) findShapes:(NSImage *)src settings:(FindShapeSettings *)settings
 completionHandler:(void (^)(NSImage *result, NSImage *proc, NSImage *debug, int resultCount, int max))completionHandler
{
    // save a copy of the original image
    cv::Mat imgOriginal = NSImageToMat(src);
    cv::Mat imgDebug = NSImageToMat(src);
    imgDebug.convertTo(imgDebug, -1, 1, -100);

    // convert src image to grayscale Mat
    cv::Mat img = NSImageToMat(src);
    cv::Mat red, green, blue, gray;
    cv::extractChannel(img, red, 2);
    cv::extractChannel(img, green, 1);
    cv::extractChannel(img, blue, 0);
    cv::cvtColor(img, gray, CV_BGR2GRAY);
    adjustImage(red, settings.invert, settings.darken, settings.blur, settings.contrast);
    adjustImage(green, settings.invert, settings.darken, settings.blur, settings.contrast);
    adjustImage(blue, settings.invert, settings.darken, settings.blur, settings.contrast);
    adjustImage(gray, settings.invert, settings.darken/2, settings.blur, settings.contrast);
//    cv::threshold(red, red, settings.thresholdValue, 255, CV_THRESH_BINARY);
//    cv::threshold(green, green, settings.thresholdValue, 255, CV_THRESH_BINARY);
//    cv::threshold(blue, blue, settings.thresholdValue, 255, CV_THRESH_BINARY);
//    cv::Mat test;
    cv::add(red, green, img);
    cv::add(img, blue, img);
    cv::add(img, gray, img);
//    cv::cvtColor(img, img, CV_BGR2GRAY);

    // adjust brightness/contrast/etc
//    adjustImage(img, settings.invert, settings.darken, settings.blur, settings.contrast);
    
    // threshold
    if (settings.threshold) {
        cv::threshold(img, img, settings.thresholdValue, 255, CV_THRESH_BINARY);
//        cv::adaptiveThreshold(img, img, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 21, settings.thresholdValue);
    }
    
    // find the white shapes
//    cv::inRange(img, cv::Scalar(100,100,100), cv::Scalar(255,255,255), img);
    
    // find contours
    std::vector<std::vector<cv::Point>> contours;
    std::vector<cv::Vec4i> hierarchy;
    cv::findContours(img, contours, hierarchy, cv::RETR_TREE, cv::CHAIN_APPROX_SIMPLE);
    
    int imgArea = img.rows * img.cols;
    int maxArea = imgArea / 200;
    int minArea = imgArea / 5000;
    NSLog(@"img area: %d min: %d max: %d", imgArea, minArea, maxArea);
    
//    // copy the candidate areas to blank mat
//    cv::Mat dst = cv::Mat(imgOriginal.rows, imgOriginal.cols, imgOriginal.type(), cvScalar(128, 128, 128));
//    int discovered = 0;
//    int max = 0;
//    for (int i = 0; i < contours.size(); i++) {
//        cv::Rect boundingRect = cv::boundingRect(contours[i]);
//        int area = boundingRect.size().area();
//        NSLog(@"%d", area);
//        if (area > minArea && area < maxArea) {
//            discovered++;
//            int expandX = boundingRect.width * 0.4;
//            int expandY = boundingRect.height * 0.4;
//            int newWidth = boundingRect.width + expandX;
//            int newHeight = boundingRect.height + expandY;
//            if (newWidth > max) {
//                max = newWidth;
//            }
//            if (newHeight > max) {
//                max = newHeight;
//            }
//            cv::Rect copyRect = cv::Rect(boundingRect.x - expandX/2, boundingRect.y - expandY/2, newWidth, newHeight);
//            imgOriginal(copyRect).copyTo(dst(copyRect));
//
//            // show the disvoered shapes on the debug image
//            cv::drawContours(imgDebug, contours, i, cvScalar(0,255,0), 4, cv::LINE_8);
//            cv::rectangle(imgDebug, copyRect.tl(), copyRect.br(), cvScalar(255,0,0), 4, cv::LINE_8);
//        }
//    }

    cv::Mat dst = cv::Mat(imgOriginal.rows, imgOriginal.cols, imgOriginal.type(), cvScalar(0, 0, 0));
    int discovered = 0;
    int max = 0;
    for (int i = 0; i < contours.size(); i++) {
        cv::Rect boundingRect = cv::boundingRect(contours[i]);
        int area = boundingRect.size().area();
        if (area > minArea && area < maxArea) {
            discovered++;
            double delta = (double)boundingRect.width / (double)boundingRect.height;
            if (delta >= 0.9 && delta <= 1.1) {
                // shape is squarish, count as part of average
                int radius;
                if (boundingRect.width > boundingRect.height) {
                    radius = boundingRect.width / 2;
                } else {
                    radius = boundingRect.height / 2;
                }
                if (radius > max) {
                    max = radius;
                }
            }
            cv::drawContours(dst, contours, i, cvScalar(255,255,255), 4, cv::LINE_8);
            cv::rectangle(imgDebug, boundingRect.tl(), boundingRect.br(), cvScalar(255,0,0), 4, cv::LINE_8);
        }
    }
    
    // convert and return processed image
    NSImage *result = MatToNSImage(dst);
    NSImage *proc = MatToNSImage(img);
    NSImage *debug = MatToNSImage(imgDebug);
    
    completionHandler(result, proc, debug, discovered, max);
}

+(void) findCircles:(NSImage *)src ref:(NSImage *)ref settings:(FindCircleSettings *) settings
  completionHandler:(void (^)(NSImage *result, NSImage *proc, NSImage *debug, int resultCount))completionHandler
{
    // save a copy of the original image
    cv::Mat imgRef = NSImageToMat(ref);

    // convert src image to grayscale Mat
    cv::Mat img = NSImageToGrayscaleMat(src);

    // adjust brightness/contrast/etc
//    adjustImage(img, settings.invert, settings.darken, settings.blur, settings.contrast);

    // find the circles
    std::vector<cv::Vec3f> circles;
    cv::HoughCircles(img, circles, CV_HOUGH_GRADIENT, 2, settings.minDist, settings.h1, settings.h2, settings.minSize, settings.maxSize);

    // draw the detected circles
    cv::Mat imgDebug = img.clone();
    cv::cvtColor(imgDebug, imgDebug, cv::COLOR_GRAY2BGR);
    for (int i = 0; i < circles.size(); i++) {
        cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
        int radius = cvRound(circles[i][2]);
        NSLog(@"radius: %d", radius);
        // circle center
        cv::circle(imgRef, center, 20, cvScalar(255,0,0), -1, cv::LINE_8, 0 );
        // circle outline
        cv::circle(imgDebug, center, radius, cvScalar(0,255,0), 8, cv::LINE_8, 0 );
    }
    
    // convert and return processed image
    NSImage *result = MatToNSImage(imgRef);
    NSImage *proc = MatToNSImage(img);
    NSImage *debug = MatToNSImage(imgDebug);

    completionHandler(result, proc, debug, (int)circles.size());
}

@end
