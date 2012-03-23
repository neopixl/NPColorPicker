//
//  NSColor+Additions.h
//  iSequence
//
//  Created by Emmanuel Valentin on 09/03/11.
//  Copyright 2011 NeoPixl. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIColor(Additions)

+(UIColor *)colorWithRGBHexString:(NSString *)string;
-(NSString *)RGBHexString;

+(UIColor *)colorBylinearInterpolationFromColor:(UIColor *) startColor toColor:(UIColor *) endColor percentage:(CGFloat)percent;
+(UIColor *)colorByChromaticInterpollationFromColor:(UIColor *) startColor toColor:(UIColor *) endColor percentage:(CGFloat)percent;


@end

// darker: 0 > factor < 1 
// lighter factor > 1
CGColorRef createDarkerCGColor(CGColorRef color, CGFloat factor );

void RGBtoHSL( CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *l );
void HSLtoRGB( CGFloat *r, CGFloat *g, CGFloat *b, CGFloat h, CGFloat sl, CGFloat l );
void RGBtoHSV( CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *v );
void HSVtoRGB( CGFloat *r, CGFloat *g, CGFloat *b, CGFloat h, CGFloat s, CGFloat v );

void componentInterpollation(CGFloat percent, CGFloat sHue, CGFloat sSat, CGFloat sBri, CGFloat sAlp, CGFloat eHue, CGFloat eSat, CGFloat eBri, CGFloat eAlp, CGFloat * oHue, CGFloat * oSat, CGFloat * oBri, CGFloat * oAlp);

void linearInterpolation(CGFloat sr, CGFloat sg, CGFloat sb, CGFloat sa, CGFloat er, CGFloat eg, CGFloat eb, CGFloat ea, CGFloat pos, CGFloat * rr, CGFloat * rg, CGFloat * rb, CGFloat * ra);