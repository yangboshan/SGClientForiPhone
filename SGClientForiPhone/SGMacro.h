//
//  SGMacro.h
//  SGClientForiPhone
//
//  Created by yangboshan on 15/5/7.
//  Copyright (c) 2015年 yangbs. All rights reserved.
//

#ifndef SGClientForiPhone_SGMacro_h
#define SGClientForiPhone_SGMacro_h

#define ApplicationDelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

#define NavBarHeightAlone 44
#define NavBarHeight 64
#define TabBarHeight 49

#define IOSVersion                          [[[UIDevice currentDevice] systemVersion] floatValue]
#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>16)&0xFF)/255.0 green:((c>>8)&0xFF)/255.0 blue:(c&0xFF)/255.0 alpha:1.0];

#define TheameColor RGB(37,159,219)
#define NavBarColorAlpha(a) RGBA(37,159,219,a)

#define BorderColor RGB(223, 223, 223).CGColor
#define MaskColor RGBA(0, 0, 0, 0.5)


#define Lantinghei(s) [UIFont fontWithName:@"Lantinghei SC" size:s]


#define DrawLine(x1,y1,x2,y2,s) [NSString stringWithFormat:@"<line x1=\"%f\" y1=\"%f\" x2=\"%f\" y2=\"%f\" style=\" stroke:rgb(99,99,99);stroke-width:3\" onclick=\"self.location.href='@@@@%@'\"/>",x1,y1,x2,y2,s]

#define DrawLineT(x1,y1,x2,y2,s) [NSString stringWithFormat:@"<line x1=\"%f\" y1=\"%f\" x2=\"%f\" y2=\"%f\" style=\" stroke:rgb(99,99,99);stroke-width:1\" onclick=\"self.location.href='@@@@%@'\"/>",x1,y1,x2,y2,s]

#define DrawLineArrow(x1,y1,x2,y2,s) [NSString stringWithFormat:@"<line x1=\"%f\" y1=\"%f\" x2=\"%f\" y2=\"%f\" style=\" stroke:rgb(99,99,99);stroke-width:2\" marker-end=\"url(#triangle)\" onclick=\"self.location.href='@@@@%@'\"/>",x1,y1,x2,y2,s]

#define DrawCircle(x,y,r) [NSString stringWithFormat:@"<circle cx=\"%f\" cy=\"%f\" r=\"%f\" style=\"stroke:black; fill:black\"/>",x,y,r]


#define DrawText(x,y,z,c,f,s) [NSString stringWithFormat:@"<text x=\"%f\" y=\"%f\" font-size=\"%d\" fill =\"%@\" font-style=\"%@\">%@</text>",x,y,z,c,f,s]

#define DrawTextL(x,y,z,c,f,s) [NSString stringWithFormat:@"<text x=\"%f\" y=\"%f\" font-size=\"%d\" fill =\"%@\" style=\"text-anchor: left;\" font-style=\"%@\">%@</text>",x,y,z,c,f,s]

#define DrawTextR(x,y,z,c,f,s) [NSString stringWithFormat:@"<text x=\"%f\" y=\"%f\" font-size=\"%d\" fill =\"%@\" style=\"text-anchor: end\" font-style=\"%@\">%@</text>",x,y,z,c,f,s]

#define DrawTextM(x,y,z,c,f,s) [NSString stringWithFormat:@"<text x=\"%f\" y=\"%f\" font-size=\"%d\" fill =\"%@\" style=\"text-anchor: middle\" font-style=\"%@\">%@</text>",x,y,z,c,f,s]





#define DrawTextClicked(x,y,z,c,f,s,i) [NSString stringWithFormat:@"<text x=\"%f\" y=\"%f\" font-size=\"%d\" fill =\"%@\" font-style=\"%@\" onclick=\"self.location.href='@@@@%@'\">%@</text>",x,y,z,c,f,i,s]


#define DrawRectH(x,y,w,h) [NSString stringWithFormat:@"<rect x=\"%f\" y=\"%f\" width=\"%f\" rx=\"10\" ry=\"10\" height=\"%f\" style=\"fill:#0061b0;stroke:white;stroke-width:1;opacity:0.5\"/>",x,y,w,h]

#define DrawRect(x,y,w,h) [NSString stringWithFormat:@"<rect x=\"%f\" y=\"%f\" width=\"%f\" rx=\"10\" ry=\"10\" height=\"%f\" style=\"fill:#0061b0;stroke:black;stroke-width:1;opacity:0.5\"/>",x,y,w,h]

#define DrawRectD(x,y,w,h) [NSString stringWithFormat:@"<rect x=\"%f\" y=\"%f\" width=\"%f\" rx=\"10\" ry=\"10\" height=\"%f\" style=\"fill:#0061b0;stroke:black;stroke-width:1;opacity:0.5\"/>",x,y,w,h]




#define DrawRectW(x,y,w,h,p) [NSString stringWithFormat:@"<rect x=\"%f\" y=\"%f\" width=\"%f\" height=\"%f\" rx=\"10\" ry=\"10\" style=\"fill:#0061b0;stroke:white;stroke-width:1;opacity:0.5\" onclick=\"self.location.href='@@@@%@'\"/>",x,y,w,h,p]

#define DrawRectWD(x,y,w,h,p) [NSString stringWithFormat:@"<rect x=\"%f\" y=\"%f\" width=\"%f\" height=\"%f\" rx=\"10\" ry=\"10\" style=\"fill:#0061b0;stroke:white;stroke-width:1;opacity:0.5\" onclick=\"self.location.href='@@@@%@'\"/>",x,y,w,h,p]

#define LineInfo(n,c,i,t) [NSString stringWithFormat:@"%@*%@*%d*%d",n,c,i,t]

#endif
