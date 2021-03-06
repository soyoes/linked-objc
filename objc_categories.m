
#import "objc_categories.h"
//@import ImageIO;
//@import OpenGLES;
//@import Accelerate;
#import <ImageIO/ImageIO.h>
#import <OpenGLES/EAGL.h>
#import <Accelerate/Accelerate.h>
#import <float.h>



#pragma mark - NSArray

@implementation NSArray (liber)
- (double) sum:(NSString *)key{
    double res = 0;
    for (id ele in self) {
        if(key!=nil ){
            if([ele isKindOfClass:[NSDictionary class]] && [[(NSDictionary*)ele allKeys] containsObject:key] ){
                res += [ele[key] doubleValue];
            }
        }else{
            if([ele isKindOfClass:[NSNumber class]]){
                res += [ele doubleValue];
            }
        }
    }
    return res;
}
- (NSArray *) arrayFromJSONFile:(NSString*)file{
    NSString *str = [[NSString alloc] initWithContentsOfFile:file encoding:NSUTF8StringEncoding error:NULL];
    return (NSArray*) [str toJSON];
}

- (BOOL) same{
    id prev = nil;
    for (id o in self) {
        if (prev==nil) {
            prev = o;
        }
        if(![prev isEqual:o]){
            return NO;
        }
        prev = o;
    }
    return YES;
}

@end


@implementation NSMutableArray (liber)
- (double) sum:(NSString *)key{
    NSArray *arr = [NSArray arrayWithArray:self];
    return [arr sum:key];
}
- (NSMutableArray*) initWithFill:(int)length value:(id)value rows:(int)rows{
    if(rows>1){
        NSMutableArray *element = [[NSMutableArray alloc] initWithFill:length value:value rows:1];
        return [[NSMutableArray alloc] initWithFill:length value:[NSMutableArray arrayWithArray:element] rows:1];
    }else{
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:length];
        for (int i=0; i<length; i++) {
            [arr addObject:value];
        }
        return arr;
    }
}
- (BOOL) same{
    NSArray *arr = [NSArray arrayWithArray:self];
    return [arr same];
}

- (void) addStringKeyValue:(NSString*)key value:(id)value separator:(NSString*)separator {
    [self addObject:[NSString stringWithFormat:@"%@%@%@", key, separator, value]];
}

@end

#pragma mark - NSDictionary

@implementation  NSDictionary (liber)
- (NSArray *) dictionaryFromJSONFile:(NSString*)file{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return (NSArray*) [str toJSON];
}
@end

#pragma mark - NSDate

@implementation NSDate (liber)
/**
 
 @example : [NSDate dateFromString:@"1980-08-24 15:30:00" format:@"yyyy-MM-dd HH:mm:ss"];
 */
+ (NSDate *) dateFromString:(NSString*)datestr format:(NSString*)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:format];
    return [formatter dateFromString:datestr];
}

+ (long) timestampFromString:(NSString*)datestr format:(NSString*)format{
    NSDate *d = [self dateFromString:datestr format:format];
    return [d timeIntervalSince1970];
}

@end


#pragma mark - NSString

@implementation NSString (liber)


- (BOOL)isValidEmail{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

-(BOOL) isValidMobileNumberOfJP{
    NSString *regex = @"0[0-9]{2}[-]{0,1}[0-9]{4}[-]{0,1}[0-9]{4}";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:self];
}

-(BOOL) isValidZipcodeOfJP{
    NSString *regex = @"[0-9]{3}[-]{0,1}[0-9]{4}";
    //UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [test evaluateWithObject:self];
}

-(NSArray *) lines{
    NSUInteger length = (NSUInteger)[self length];
    NSUInteger paraStart = 0, paraEnd = 0, contentsEnd = 0;
    NSMutableArray *array = [NSMutableArray array];
    NSRange currentRange;
    while (paraEnd<length){
        [self getParagraphStart:&paraStart end:&paraEnd
                    contentsEnd:&contentsEnd forRange:NSMakeRange(paraEnd, 0)];
        currentRange = NSMakeRange(paraStart, contentsEnd - paraStart);
        [array addObject:[self substringWithRange:currentRange]];
    }
    return array;
}

-(UIColor*)colorValue{
    if([self contains:@","]){
        NSString *target = [self regexpReplace:@"(rgb\\(|\\))" replace:@""];
        NSArray *rgbs = [target componentsSeparatedByString:@","];
        if([rgbs count]>=3){
            float alpha = [rgbs count]==4 ? [rgbs[3] floatValue]:1;
            return [UIColor colorWithRed:[rgbs[0] floatValue]/255
                                   green:[rgbs[0] floatValue]/255 blue:[rgbs[0] floatValue]/255 alpha:alpha];
        }
        return [UIColor blackColor];
    }else if([self contains:@"#"]){
        assert('#' == [self characterAtIndex:0]);
        
        NSString *redHex = [NSString stringWithFormat:@"0x%@", [self substringWithRange:NSMakeRange(1, 2)]];
        NSString *greenHex = [NSString stringWithFormat:@"0x%@", [self substringWithRange:NSMakeRange(3, 2)]];
        NSString *blueHex = [NSString stringWithFormat:@"0x%@", [self substringWithRange:NSMakeRange(5, 2)]];
        NSString *alphaHex = ([self length]==9)?[NSString stringWithFormat:@"0x%@", [self substringWithRange:NSMakeRange(7, 2)]]:@"FF";
        
        unsigned redInt = 0;
        NSScanner *rScanner = [NSScanner scannerWithString:redHex];
        [rScanner scanHexInt:&redInt];
        
        unsigned greenInt = 0;
        NSScanner *gScanner = [NSScanner scannerWithString:greenHex];
        [gScanner scanHexInt:&greenInt];
        
        unsigned blueInt = 0;
        NSScanner *bScanner = [NSScanner scannerWithString:blueHex];
        [bScanner scanHexInt:&blueInt];
        
        unsigned alpha = 0;
        NSScanner *aScanner = [NSScanner scannerWithString:alphaHex];
        [aScanner scanHexInt:&alpha];
        return [UIColor colorWithRed:(float)redInt/255 green:(float)greenInt/255 blue:(float)blueInt/255 alpha:(float)alpha/255];
    }else
        return [UIColor clearColor];
}
- (NSString *)regexpReplace:(NSString *)pattern replace:(NSString*)replace{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    return [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replace];
}
- (BOOL)contains:(NSString *)string
         options:(NSStringCompareOptions)options {
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)contains:(NSString *)string {
    return [self contains:string options:0];
}

-(id)toJSON{
    NSString *str =[self regexpReplace:@"\n" replace:@""];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: nil];
}

- (float) sizeToFit:(CGSize)size font:(NSString*)fontName{
    float baseFont=7;
    float fsize = baseFont;
    CGFloat step=1.0f;
    
    BOOL found=NO;
    while (!found) {
        UIFont * f =[UIFont fontWithName:fontName size:fsize];
        //CGSize tSize=[self sizeWithFont:f constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping]; //iOS ~7
        CGSize tSize = [self  sizeWithAttributes: @{NSFontAttributeName:f}]; //iOS7.0+
        if(tSize.height+f.lineHeight>size.height){
            found=YES;
        }else {
            fsize+=step;
        }
    }
    return fsize;
};

- (int) indexOf:(NSString *)text {
    NSRange range = [self rangeOfString:text];
    if ( range.length > 0 ) {
        return range.location;
    } else {
        return -1;
    }
}

- (BOOL) isInt {
    integer_t val; NSScanner* scan = [NSScanner scannerWithString:self];
    return [scan scanInteger:&val] && [scan isAtEnd];
}
//- (BOOL) isInteger {
//    NSInteger * val; NSScanner* scan = [NSScanner scannerWithString:self];
//    return [scan scanInteger:&val] && [scan isAtEnd];
//}
//- (BOOL) isLongLong {
//    long long* val; NSScanner* scan = [NSScanner scannerWithString:self];
//    return [scan scanLongLong:&val] && [scan isAtEnd];
//}
- (BOOL) isFloat {
    float val; NSScanner* scan = [NSScanner scannerWithString:self];
    return [scan scanFloat:&val] && [scan isAtEnd];
}
//- (BOOL) isDouble {
//    double val; NSScanner* scan = [NSScanner scannerWithString:self];
//    return [scan scanDouble:&val] && [scan isAtEnd];
//}
//- (BOOL) isDecimal {
//    NSDecimal * val; NSScanner* scan = [NSScanner scannerWithString:self];
//    return [scan scanDecimal:&val] && [scan isAtEnd];
//}


@end


#pragma mark - UIImage

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};
@implementation UIImage (liber)


-(UIImage *)imageAtRect:(CGRect)rect{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    return subImage;
}

+ (UIImage *)imageWithLabel:(UILabel *)label scale:(float)scale{
    CGRect bounds = CGRectMake(0,0,label.frame.size.width*scale, label.frame.size.height * scale);
    UIGraphicsBeginImageContext(bounds.size);
    //NSLog(@"fontsize=%f",label.font.pointSize);
    
    UIFont *f = [UIFont fontWithName:label.font.fontName size:label.font.pointSize*scale];
    UILabel *lb = [[UILabel alloc] initWithFrame:bounds];
    lb.text = label.text;
    lb.font = f;
    lb.textColor = label.textColor;
    [lb drawTextInRect:bounds];
    UIImage *img= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


+ (UIImage *)imageWithAsset:(ALAsset *)asset{
    UIImage *result = nil;
    NSData *data = nil;
    ALAssetRepresentation * repr = [asset defaultRepresentation];
    int size = (int)[repr size];
    uint8_t *buffer = (uint8_t *)malloc(sizeof(uint8_t)*size);
    if (buffer != NULL) {
        NSError *error = nil;
        NSUInteger bytesRead = [repr getBytes:buffer fromOffset:0 length:(int)size error:&error];
        data = [NSData dataWithBytes:buffer length:bytesRead];
        free(buffer);
    }
    
    if ([data length]) {
        CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
        NSMutableDictionary *options = [NSMutableDictionary dictionary];
        [options setObject:(id)kCFBooleanTrue forKey:(__bridge id)kCGImageSourceCreateThumbnailFromImageIfAbsent];
        CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
        if (imageRef) {
            result = [UIImage imageWithCGImage:imageRef scale:[repr scale] orientation:(UIImageOrientation)[repr orientation]];
            CGImageRelease(imageRef);
        }
        if (sourceRef) CFRelease(sourceRef);
    }
    
    return result;
}

- (UIImage *)imageWithLabelAtPoint:(UILabel *)label point:(CGPoint)pnt{
    UIGraphicsBeginImageContext(self.size);
    [self drawAtPoint:CGPointMake(0, 0)];
    
    CGRect textRect = CGRectMake(pnt.x, pnt.y, label.frame.size.width,label.frame.size.height);
    if(label.backgroundColor != [UIColor clearColor]){
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, label.backgroundColor.CGColor);
        CGContextFillRect(context, textRect);
    }
    
    [label drawTextInRect:textRect];
    UIImage *img= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIImage *)imageWithBorder:(float)borderWidth color:(UIColor*)borderColor{
    CGRect rect = CGRectMake(0, 0, self.size.width+2*borderWidth,self.size.height+2*borderWidth);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, borderColor.CGColor);
    CGContextFillRect(context, rect);
    [self drawAtPoint:CGPointMake(borderWidth, borderWidth)];
    UIImage *img= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
/*
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}


- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
    
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor)
            scaleFactor = widthFactor;
        else
            scaleFactor = heightFactor;
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    
    // this is actually the interesting part:
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) NSLog(@"could not scale image");
    
    
    return newImage ;
}
*/

/**
 style : 0:fit, 1:fit+crop, 2:fill
 */
- (UIImage *)imageByScale:(CGSize)size style:(int)style{
    CGFloat w = self.size.width,
            h = self.size.height,
            tw = size.width,
            th = size.height;
    CGRect r;
    switch (style) {
        case 0:
            r = (w/h>tw/th)?CGRectMake(0, 0, tw, h/w*tw)
            :CGRectMake(0,0,w/h*th, th);
            break;
        case 1:
            r= (w/h>tw/th)?CGRectMake(0, 0, w*th/h, th)
            :CGRectMake(0,0,tw, h*tw/w);
            break;
        case 2:
            r= CGRectMake(0,0,tw,th);
            break;
    }
    
    UIGraphicsBeginImageContext(r.size);
    [self drawInRect:r];
    UIImage *res = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return res;
}

- (UIImage *)imageRotatedByRadians:(CGFloat)radians{
    return [self imageRotatedByDegrees:RadiansToDegrees(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, DegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}


- (UIImage *)imageWithCorner:(CGFloat)radius toBounds:(CGRect)bounds borderWidth:(float)borderWidth borderColor:(CGColorRef)borderColor{
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 1.0);
    
    [[UIBezierPath bezierPathWithRoundedRect:bounds
                                cornerRadius:radius] addClip];
    if(borderWidth>0){
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, borderColor);
        CGContextFillRect(context, bounds);
        bounds = CGRectMake(borderWidth, borderWidth, bounds.size.width-2*borderWidth, bounds.size.height-2*borderWidth);
        [[UIBezierPath bezierPathWithRoundedRect:bounds
                                    cornerRadius:radius] addClip];
    }
    
    [self drawInRect:bounds];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}



- (UIImage *)imageWithBlendColor:(UIColor*)color{
    return [self imageWithBlendColor:color mode:kCGBlendModeOverlay];
}
- (UIImage *)imageWithBlendColor:(UIColor*)color mode:(CGBlendMode)mode{
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions (self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
        [self drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0f];
        CGContextSetBlendMode(context, mode);
        [color setFill];
        CGContextFillRect(context, rect);
        [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return tintedImage;
    }
}

- (UIImage*) imageWithBlendImage:(NSString*)imgname alpha:(float)alpha{
    @autoreleasepool {
        CGSize size = self.size;
        UIImage * mask =[[UIImage imageNamed:imgname] imageByScale:size style:2];
        UIGraphicsBeginImageContext(size);
        [self drawAtPoint:CGPointZero blendMode:kCGBlendModeOverlay alpha:1.0];
        [mask drawAtPoint:CGPointZero blendMode:kCGBlendModeOverlay alpha:alpha];
        UIImage* res = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return res;
    }
}

- (UIImage*) merge:(UIImage*)thumb{
    UIGraphicsBeginImageContext(self.size);
    
    [self drawAtPoint:CGPointMake(0, 0)];
    [thumb drawAtPoint:CGPointMake(0, 0)];
    
    UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return result;
}



- (UIImage*) colorMix:(float[3][3])matrix contrast:(float)contrast{
    @autoreleasepool {
        CGSize size = self.size;
        UIGraphicsBeginImageContext(size);
        [self drawInRect:CGRectMake(0,0,size.width,size.height) blendMode:kCGBlendModeSourceOut alpha:1.0f];
        CGContextRef ctx = UIGraphicsGetCurrentContext();

        UInt8* data = (UInt8*)CGBitmapContextGetData(ctx);
        int r, g, b;
        int numComponents = 4;
        int bytesInContext = (int)CGBitmapContextGetHeight(ctx) * (int)CGBitmapContextGetBytesPerRow(ctx);
        for (int i = 0; i < bytesInContext; i += numComponents) {
            r = MIN(255,MAX(0,(((float)data[i]/255.0f-0.5)*contrast+0.5)*255));
            g = MIN(255,MAX(0,(((float)data[i+1]/255.0f-0.5)*contrast+0.5)*255));
            b = MIN(255,MAX(0,(((float)data[i+2]/255.0f-0.5)*contrast+0.5)*255));
            //mix
            data[i]   = MIN(255,(int)(r * matrix[0][0]) + (g *matrix[0][1]) + (b *matrix[0][2]));
            data[i+1] = MIN(255,(int)(r * matrix[1][0]) + (g *matrix[1][1]) + (b *matrix[1][2]));
            data[i+2] = MIN(255,(int)(r * matrix[2][0]) + (g *matrix[2][1]) + (b *matrix[2][2]));
        }
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //free(data);
        return img;
    }
}

- (UIImage*) mirror:(int)height{
    if(height == 0)
		return nil;
    CGRect bound = CGRectMake(0,0,self.size.width ,self.size.height);
	// create a bitmap graphics context the size of the image
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	// create the bitmap context
	CGContextRef context = CGBitmapContextCreate (NULL, self.size.width, height, 8,
														0, colorSpace,
														(kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
	CGColorSpaceRelease(colorSpace);

	
	// create a 2 bit CGImage containing a gradient that will be used for masking the
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMask=NULL;
    colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, 1, height,
															   8, 0, colorSpace, kCGImageAlphaNone);
	
	CGFloat colors[] = {0.0, 1.0, 1.0, 1.0};
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, height);
	
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,
								gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	
	gradientMask = CGBitmapContextCreateImage(gradientBitmapContext);
	CGContextRelease(gradientBitmapContext);
    
    CGContextClipToMask(context, CGRectMake(0.0, 0.0, bound.size.width, height), gradientMask);
	CGImageRelease(gradientMask);
	
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// draw the image into the bitmap context
	CGContextDrawImage(context, bound, self.CGImage);
	
	// create CGImageRef of the main view bitmap content, and then release that bitmap context
	CGImageRef reflectionImage = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	// convert the finished reflection image to a UIImage
	UIImage *theImage = [UIImage imageWithCGImage:reflectionImage];
	
	// image is retained by the property setting above, so we can release the original
	CGImageRelease(reflectionImage);
	
	return theImage;
}

- (UIImage*) filters:(NSString*)CIFilterName opts:(NSDictionary*)opts{
    @autoreleasepool {
        static CIImage *cimg;
        cimg=[CIImage imageWithCGImage:self.CGImage];
        CIFilter *filter = [CIFilter filterWithName:CIFilterName];
        [filter setValue:cimg forKey:kCIInputImageKey];
        for (NSString*key in opts) {
            [filter setValue:opts[key] forKey:key];
        }
        
        static CIImage* outputImage;
        outputImage = [filter outputImage];

        //CIContext *context = [CIContext contextWithOptions:nil];
        static EAGLContext *glesContext;
        if(!glesContext) glesContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        CIContext *context = [CIContext contextWithEAGLContext:glesContext options:@{kCIContextUseSoftwareRenderer:@NO}];
        
        CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
        UIImage*img = [UIImage imageWithCGImage:cgimg scale:self.scale orientation:self.imageOrientation];
        CGImageRelease(cgimg);
        [filter setValue:nil forKey:kCIInputImageKey];
        //filter = nil;
        return img;
    }
}

+ (void) loadImageFromAssetURL:(NSURL*)url handler:(void(^)(UIImage*,NSDictionary*))handler params:(NSDictionary*)params{
    @autoreleasepool {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:url resultBlock:^(ALAsset *asset){
            UIImage * res = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage] scale:0.5 orientation:UIImageOrientationUp];
            handler(res, params);
            res = nil;
        } failureBlock:^(NSError *error){handler(nil,params);}];
    }
}


- (UIImage *)applyLightEffect{
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyExtraLightEffect{
    UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyDarkEffect{
    UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
    return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor{
    const CGFloat EffectColorAlpha = 0.6;
    UIColor *effectColor = tintColor;
    int componentCount = (int) CGColorGetNumberOfComponents(tintColor.CGColor);
    if (componentCount == 2) {
        CGFloat b;
        if ([tintColor getWhite:&b alpha:NULL]) {
            effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
        }
    }
    else {
        CGFloat r, g, b;
        if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
            effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
        }
    }
    return [self applyBlurWithRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}


- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (u_int32_t) radius, (u_int32_t)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, (u_int32_t)radius, (u_int32_t)radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, (u_int32_t)radius, (u_int32_t)radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}


@end


#pragma mark - UIView

@implementation UIView (liber)


-(void)clearPath:(CGMutablePathRef)path{
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSaveGState(context);
    
    //Very important!!!!
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGContextRestoreGState(context);
}


-(void)drawPoints:(float[])points size:(int)size
        fillColor:(UIColor*)fillColor strokeColor:(UIColor*)strokeColor strokeWidth:(float)strokeWidth{
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSaveGState(context);
    
    CGContextBeginPath(context);
    
    CGContextMoveToPoint(context,points[0],points[1]);
    size *= 2;
    for (int i = 2; i < size; i+=2) {
        CGContextAddLineToPoint(context, points[i], points[i+1]);
    }
    CGContextAddLineToPoint(context,points[0],points[1]);
    CGContextClosePath(context);
    
    if (fillColor!=nil){
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        CGContextFillPath(context);
    }
    if (strokeColor!=nil && strokeWidth>0){
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);
}

-(void)drawPath:(CGPathRef)path fillColor:(UIColor*)fillColor strokeColor:(UIColor*)strokeColor strokeWidth:(float)strokeWidth{
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(context, YES);
    CGContextSaveGState(context);
    
    CGContextAddPath(context, path);
    
    if (fillColor!=nil){
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        CGContextFillPath(context);
    }
    if (strokeColor!=nil && strokeWidth>0){
        CGContextSetStrokeColorWithColor(context, strokeColor.CGColor);
        CGContextSetLineWidth(context, strokeWidth);
        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);
}

@end


