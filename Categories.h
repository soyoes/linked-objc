//
//  Categories.h
//  liberobjc
//
//  Created by @soyoes on 10/30/12.
//  Copyright (c) 2012 Liberhood ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#ifndef liberobjc_Categories_h
#define liberobjc_Categories_h

@interface NSArray (liber)
- (double) sum:(NSString *)key;
- (NSArray *) arrayFromJSONFile:(NSString*)file;
//- (BOOL) same;

@end


@interface NSMutableArray (liber)
//- (BOOL) same;
- (double) sum:(NSString *)key;
- (NSMutableArray*) initWithFill:(int)length value:(id)value rows:(int)rows;
@end


@interface NSDictionary (liber)
- (NSDictionary *) dictionaryFromJSONFile:(NSString*)file;

@end

@interface NSDate (liber)
+ (NSDate *) dateFromString:(NSString*)datestr format:(NSString*)format;
+ (long) timestampFromString:(NSString*)datestr format:(NSString*)format;
@end


@interface NSString (liber)
- (BOOL)isValidEmail;
- (BOOL)isValidMobileNumberOfJP;
- (BOOL)isValidZipcodeOfJP;
- (BOOL)contains:(NSString *)string;
- (BOOL)contains:(NSString *)string options:(NSStringCompareOptions) options;
- (NSString *)regexpReplace:(NSString *)pattern replace:(NSString*)replace;
- (UIColor*) colorValue;
- (NSArray *) lines;
- (float) sizeToFit:(CGSize)size font:(NSString*)fontName;
- (id)toJSON;
@end



@interface UIImage(liber)
- (UIImage *)imageAtRect:(CGRect)rect;
+ (UIImage *)imageWithLabel:(UILabel *)label scale:(float)scale;
+ (UIImage *)imageWithAsset:(ALAsset *)asset;
- (UIImage *)imageWithLabelAtPoint:(UILabel *)label point:(CGPoint)pnt;
- (UIImage *)imageWithBorder:(float)borderWidth color:(UIColor*)borderColor;
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)imageWithCorner:(CGFloat)radius toBounds:(CGRect)bounds borderWidth:(float)borderWidth borderColor:(CGColorRef)borderColor;


- (UIImage *)imageByScale:(CGSize)size style:(int)style;
- (UIImage *)imageWithBlendColor:(UIColor*)color;
- (UIImage *)imageWithBlendColor:(UIColor*)color mode:(CGBlendMode)mode;
- (UIImage *)imageWithBlendImage:(NSString*)imgname alpha:(float)alpha;
- (UIImage *)merge:(UIImage*)thumb;

- (UIImage*) colorMix:(float[3][3])matrix contrast:(float)contrast;

- (UIImage*) mirror:(int)height;
- (UIImage*) filters:(NSString*)CIFilterName opts:(NSDictionary*)opts;
+ (void) loadImageFromAssetURL:(NSURL*)url handler:(void(^)(UIImage*,NSDictionary*))handler params:(NSDictionary*)params;

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end


@interface UIView (liber)

-(void)clearPath:(CGMutablePathRef)path;
-(void)drawPoints:(float[])points size:(int)size
        fillColor:(UIColor*)fillColor strokeColor:(UIColor*)strokeColor strokeWidth:(float)strokeWidth;
-(void)drawPath:(CGPathRef)path fillColor:(UIColor*)fillColor strokeColor:(UIColor*)strokeColor strokeWidth:(float)strokeWidth;

@end




#endif
