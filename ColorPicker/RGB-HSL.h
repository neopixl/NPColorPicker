


/*
 * RGB-HSL transforms.
 * Ken Fishkin, Pixar Inc., January 1989.
 */


void RGBtoHSL( CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *l ) ;
void HSLtoRGB( CGFloat *r, CGFloat *g, CGFloat *b, CGFloat h, CGFloat sl, CGFloat l ) ;

void RGBtoHSV( CGFloat r, CGFloat g, CGFloat b, CGFloat *h, CGFloat *s, CGFloat *v );
void HSVtoRGB( CGFloat *r, CGFloat *g, CGFloat *b, CGFloat h, CGFloat s, CGFloat v );