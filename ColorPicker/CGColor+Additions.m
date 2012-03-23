//
//  NSColor+Additions.m
//  iSequence
//
//  Created by Emmanuel Valentin on 09/03/11.
//  Copyright 2011 NeoPixl. All rights reserved.
//

#import "CGColor+Additions.h"


@implementation UIColor(Additions)



+ (UIColor *)colorWithRGBHexString:(NSString *)string {
   
   UIColor *result = nil;
   
	unsigned int colorCode = 0;
	
   unsigned char redByte, greenByte, blueByte;
	
	if (nil != string)
	{
		NSScanner *scanner = [NSScanner scannerWithString:string];
		(void) [scanner scanHexInt:&colorCode];
	}
   
	redByte		= (unsigned char) (colorCode >> 16);
	greenByte	= (unsigned char) (colorCode >> 8);
	blueByte	= (unsigned char) (colorCode);
	
   result = [UIColor
             colorWithRed:		(float)redByte	/ 0xff
             green:	(float)greenByte/ 0xff
             blue:	(float)blueByte	/ 0xff
             alpha:1.0];
	
   return result;

}

-(NSString *)RGBHexString {
   
   CGFloat red, green,blue, alpha;
   [self getRed:&red green:&green blue:&blue alpha:&alpha];

   
   return [NSString stringWithFormat:@"%02x%02x%02x", 
           (int)(red * 255), 
           (int)(green * 255), 
           (int)(blue * 255)];
   
}




+(UIColor *)colorBylinearInterpolationFromColor:(UIColor *) startColor toColor:(UIColor *) endColor percentage:(CGFloat)percent {
   CGFloat p = MAX(MIN(percent, 1.0f),0.0f);
   CGFloat sRed,sBlue,sGreen,sAlpha;
   CGFloat eRed,eBlue,eGreen,eAlpha;
   
   [startColor getRed:&sRed green:&sGreen blue:&sBlue alpha:&sAlpha];
   [endColor getRed:&eRed green:&eGreen blue:&eBlue alpha:&eAlpha];
   
   return [UIColor colorWithRed:sRed + ((eRed - sRed) * p) 
                          green:sGreen + ((eGreen - sGreen) * p) 
                           blue:sBlue + ((eBlue - sBlue) * p)
                          alpha:sAlpha + ((eAlpha - sAlpha) * p)];
}

+(UIColor *)colorByChromaticInterpollationFromColor:(UIColor *) startColor toColor:(UIColor *) endColor percentage:(CGFloat)percent {
   CGFloat p = MAX(MIN(percent, 1.0f),0.0f);
   CGFloat sHue,sSat,sBright,sAlpha;
   CGFloat eHue,eSat,eBright,eAlpha;
   
   [startColor getHue:&sHue saturation:&sSat brightness:&sBright alpha:&sAlpha];
   [endColor getRed:&eHue green:&eSat blue:&eBright alpha:&eAlpha];
   
   return [UIColor colorWithHue:sHue + ((eHue - sHue) * p) 
                     saturation:sSat + ((eSat - sSat) * p)
                     brightness:sBright + ((eBright - sBright) * p) 
                          alpha:sAlpha + ((eAlpha - sAlpha) * p)];
}

@end


void linearInterpolation(CGFloat sr, CGFloat sg, CGFloat sb, CGFloat sa, CGFloat er, CGFloat eg, CGFloat eb, CGFloat ea, CGFloat percent, CGFloat * rr, CGFloat * rg, CGFloat * rb, CGFloat * ra) {
   CGFloat p = MAX(MIN(percent, 1.0f),0.0f);
   *rr = sr + ((er - sr) * p);
   *rg = sg + ((eg - sg) * p);
   *rb = sb + ((eb - sb) * p);
   *ra = sa + ((ea - sa) * p);
}

void componentInterpollation(CGFloat percent, CGFloat sHue, CGFloat sSat, CGFloat sBri, CGFloat sAlp, CGFloat eHue, CGFloat eSat, CGFloat eBri, CGFloat eAlp, CGFloat * oHue, CGFloat * oSat, CGFloat * oBri, CGFloat * oAlp) {
   
   CGFloat p = MAX(MIN(percent, 1.0f),0.0f);
   
   if (oHue) *oHue = sHue + ((eHue - sHue) * p);
   if (oSat) *oSat = sSat + ((eSat - sSat) * p);
   if (oBri) *oBri = sBri + ((eBri - sBri) * p);
   if (oAlp) *oAlp = sAlp + ((eAlp - sAlp) * p);
}


/*
 * RGB-HSL transforms.
 * Ken Fishkin, Pixar Inc., January 1989.
 */

/*
 * given r,g,b on [0 ... 1],
 * return (h,s,l) on [0 ... 1]
 */
void RGBtoHSL( CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *l ) {
   CGFloat v;
   CGFloat m;
   CGFloat vm;
   CGFloat r2, g2, b2;
   
   r /= 255;
   g /= 255;
   b /= 255;
   
   v = MAX(r,g);
   v = MAX(v,b);
   m = MIN(r,g);
   m = MIN(m,b);
   
   if ((*l = (m + v) / 2.0) <= 0.0) return;
   if ((*s = vm = v - m) > 0.0) {
		*s /= (*l <= 0.5) ? (v + m ) :
      (2.0 - v - m) ;
   } else
      return;
   
   
   r2 = (v - r) / vm;
   g2 = (v - g) / vm;
   b2 = (v - b) / vm;
   
   if (r == v)
		*h = (g == m ? 5.0 + b2 : 1.0 - g2);
   else if (g == v)
      *h = (b == m ? 1.0 + r2 : 3.0 - b2);
   else
      *h = (r == m ? 3.0 + g2 : 5.0 - r2);
   
   *h /= 6;
}

void HSLtoRGB( CGFloat *r, CGFloat *g, CGFloat *b, CGFloat h, CGFloat sl, CGFloat l ) {
   CGFloat v;
   
   v = (l <= 0.5) ? (l * (1.0 + sl)) : (l + sl - l * sl);
   if (v <= 0) {
		*r = *g = *b = 0.0;
   } else {
		double m;
		double sv;
		int sextant;
		double fract, vsf, mid1, mid2;
      
		m = l + l - v;
		sv = (v - m ) / v;
		h *= 6.0;
		sextant = h;	
		fract = h - sextant;
		vsf = v * sv * fract;
		mid1 = m + vsf;
		mid2 = v - vsf;
		switch (sextant) {
			case 0: *r = v; *g = mid1; *b = m; break;
			case 1: *r = mid2; *g = v; *b = m; break;
			case 2: *r = m; *g = v; *b = mid1; break;
			case 3: *r = m; *g = mid2; *b = v; break;
			case 4: *r = mid1; *g = m; *b = v; break;
			case 5: *r = v; *g = m; *b = mid2; break;
		}
   }
   *r *= 255;
   *g *= 255;
   *b *= 255;
}

void RGBtoHSV( CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *v )
{
	float min, max, delta;
	min = MIN( r, MIN(g, b) );
	max = MAX( r, MAX(g, b) );
	*v = max;				// v
	delta = max - min;
	if( max != 0 )
		*s = delta / max;		// s
	else {
		// r = g = b = 0		// s = 0, v is undefined
		*s = 0;
		*h = -1;
		return;
	}
	if( r == max )
		*h = ( g - b ) / delta;		// between yellow & magenta
	else if( g == max )
		*h = 2 + ( b - r ) / delta;	// between cyan & yellow
	else
		*h = 4 + ( r - g ) / delta;	// between magenta & cyan
	*h *= 60;				// degrees
	if( *h < 0 )
		*h += 360;
}

void HSVtoRGB( CGFloat *r, CGFloat *g, CGFloat *b, CGFloat h, CGFloat s, CGFloat v )
{
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}


CGColorRef createDarkerCGColor(CGColorRef color, CGFloat factor ) {
   
   CGFloat darker[3];
   CGFloat *components = (CGFloat *)CGColorGetComponents(color);
   CGFloat componentCount = CGColorGetNumberOfComponents(color);

   if (factor < 0 ) {
      factor = 0;
   }

   if (componentCount == 4) {
      CGFloat h,s,v;
      RGBtoHSL(components[0], components[1], components[2], &h, &s, &v);
      v = v * factor;
      HSLtoRGB(&darker[0], &darker[1], &darker[2], h, s, v);
      return CGColorCreate(CGColorGetColorSpace(color), (CGFloat[]){darker[0], darker[1], darker[2], components[3]});
   }
   
   return CGColorCreateCopy(color);
}


