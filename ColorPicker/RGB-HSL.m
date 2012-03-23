
/*
* RGB-HSL transforms.
* Ken Fishkin, Pixar Inc., January 1989.
* from "Graphics Gems", Academic Press, 1990
*/
#import "RGB-HSL.h"


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