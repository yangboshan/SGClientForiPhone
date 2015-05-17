//
//  SGGenerateCubicleSvg.m
//  SGClient
//
//  Created by yangboshan on 14-7-13.
//  Copyright (c) 2014年 XLDZ. All rights reserved.
//

#import "SGGenerateCubicleSvg.h"
#import "SGCablePageBussiness.h"


@implementation SGCableTmpItem
@end

@implementation SGGenerateCubicleSvg


-(NSString*)getCubicleSvgStr{
    
    NSArray *types = @[@{@"光缆连接":self.type0listSorted},
                       @{@"尾缆连接":self.type1list}];
    
    NSMutableString* svgStr = [[NSMutableString alloc] initWithString:@"<?xml version=\"1.0\" standalone=\"no\"?><!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">"];
    
    [svgStr appendString:@"<svg width=\"##@@@##\" height=\"++@@@++\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">"];
    
    float margin_x = 20;
    float margin_y = 50;
    float cWidth   = 240;
    float cHeight  = 35;
    float linelen  = 100;
    float linetext_y_origin = 10;
    float cuVeMargin = 10;
    float offsetY = 0;
    int hPostionMax = 0;
    BOOL drawFromLeft = NO;
    
    [svgStr appendString:@"<defs><style type=\"text/css\"><![CDATA[ rect {fill:white;stroke:black;stroke-width:2;opacity:0.1;}]]></style></defs>"];
    
    self.mergedCubicles = [self getMergedCubicles];
    
    //光缆连接如果全部是2个柜子没有3个柜子的情况下 合并
    BOOL flag = YES;
    //判断是否都是两段式连接
    for(NSArray* a in self.type0listSorted){
        if (a.count!=2) {
            flag = NO;
            break;
        }
    }
    //如果都是两段式连接合并柜子 固定高度
    if (flag) {
        for(SGCableTmpItem *item in self.mergedCubicles){
            item.count = 1;
        }
    }
    
    
    for(NSDictionary* _type in types){
    
        //没有数据不做处理
        if (![_type.allValues[0] count]) {
            continue;
        }
        NSArray* type = _type.allValues[0];
        
        if (!self.isForFiberPage) {
            //连接类型r
            [svgStr appendString:DrawText(margin_x,
                                          margin_y + offsetY - 15,18,
                                          @"navy",
                                          @"italic",
                                          _type.allKeys[0])];
        }

        
        float offsetTmp = 0;
        
        drawFromLeft = [self shouldMainCubicleDrawFromLeftWithList:type];
        if (!drawFromLeft) {
            offsetTmp += (cWidth+linelen);
        }
        
        //光缆下的主屏绘制
        if ([types indexOfObject:_type] == 0){
            //如果需要合并
            if (flag) {
                //画主屏
                [svgStr appendString:DrawRect(margin_x+offsetTmp,
                                              margin_y + offsetY,
                                              cWidth,
                                              self.mergedCubicles.count*cHeight + (self.mergedCubicles.count-1)*cuVeMargin)];
                
                //主屏名称
                [svgStr appendString:DrawText(margin_x+offsetTmp + 10,
                                              margin_y + offsetY + (self.mergedCubicles.count*cHeight + (self.mergedCubicles.count-1)*cuVeMargin)/2,14,
                                              @"white",
                                              @"italic",
                                              self.cubicleData[@"name"])];
            //不需要合并
            }else{
                //画主屏
                [svgStr appendString:DrawRect(margin_x+offsetTmp,
                                              margin_y + offsetY,
                                              cWidth,
                                              type.count*cHeight + (type.count-1)*cuVeMargin)];
                
                //主屏名称
                [svgStr appendString:DrawText(margin_x+offsetTmp + 10,
                                              margin_y + offsetY + (type.count*cHeight + (type.count-1)*cuVeMargin)/2,14,
                                              @"white",
                                              @"italic",
                                              self.cubicleData[@"name"])];
            }
        //尾缆的主屏绘制
        }else{
            //画主屏
            [svgStr appendString:DrawRect(margin_x+offsetTmp,
                                          margin_y + offsetY,
                                          cWidth,
                                          type.count*cHeight + (type.count-1)*cuVeMargin)];
            
            //主屏名称
            [svgStr appendString:DrawText(margin_x+offsetTmp + 10,
                                          margin_y + offsetY + (type.count*cHeight + (type.count-1)*cuVeMargin)/2,14,
                                          @"white",
                                          @"italic",
                                          self.cubicleData[@"name"])];
        }

        

        
        
        
        //光缆连接
        if ([types indexOfObject:_type] == 0){
            //画光缆连接屏柜 连接线缆
            float offsetYTmp = margin_y + offsetY;

            for(int k = 0; k < self.mergedCubicles.count; k++){
                
                SGCableTmpItem* t = self.mergedCubicles[k];
                
                //交替色
                if (k%2 == 0) {
                    [svgStr appendString:DrawRectD(margin_x+offsetTmp + cWidth + linelen,
                                                  offsetYTmp,
                                                  cWidth,
                                                  t.count*cHeight + (t.count-1)*cuVeMargin)];
                }else{
                    [svgStr appendString:DrawRect(margin_x+offsetTmp + cWidth + linelen,
                                                  offsetYTmp,
                                                  cWidth,
                                                  t.count*cHeight + (t.count-1)*cuVeMargin)];
                }
                
 
                
                
                [svgStr appendString:DrawText(margin_x+offsetTmp + cWidth +  linelen + 10,
                                              offsetYTmp + (t.count*cHeight + (t.count-1)*cuVeMargin)/2,14,
                                              @"white",
                                              @"italic",
                                              t.cubicleName)];
                //获取光缆Fiber数量
                NSString* tmp = [NSString stringWithFormat:@"%@(%ld)",t.cableName,(long)[[SGCablePageBussiness sharedSGCablePageBussiness] queryFiberCountWithCableId:t.cableId]];
                
                //画线
                [svgStr appendString:DrawLine(margin_x+offsetTmp + cWidth,
                                              offsetYTmp + (t.count*cHeight + (t.count-1)*cuVeMargin)/2,
                                              margin_x+offsetTmp + cWidth +linelen,
                                              offsetYTmp + (t.count*cHeight + (t.count-1)*cuVeMargin)/2,LineInfo(t.cableName,t.cableId, 0,[types indexOfObject:_type]))];
                //绘制
                [svgStr appendString:DrawTextClicked(margin_x+offsetTmp + cWidth,
                                              offsetYTmp + (t.count*cHeight + (t.count-1)*cuVeMargin)/2 - linetext_y_origin,14,
                                              @"gray",
                                              @"italic",
                                              tmp,LineInfo(t.cableName,t.cableId, 0,[types indexOfObject:_type]))];
                //累加高度
                offsetYTmp += t.count*(cHeight+cuVeMargin);
            }
        }

        int vPostion = 0;
        for(NSArray* connection in type){
            
            int hPosition = 0;
            int hPositionOri = 0;
            for(int i = 0;i < connection.count;i++){
                id cubicle = connection[i];
                
                if (i==0) {
                    if ([[cubicle valueForKey:@"cubicle_id"] isEqualToString:self.cubicleData[@"id"]]){
                        if (!drawFromLeft) {
                            hPosition++;
                        }
                    } else {
                        
                        if (vPostion%2==0) {
                            [svgStr appendString:DrawRectD(margin_x  + hPosition*(cWidth+linelen),
                                                          margin_y + vPostion*(cuVeMargin+cHeight)+offsetY,
                                                          cWidth,
                                                          cHeight)];
                        }else{
                            [svgStr appendString:DrawRect(margin_x  + hPosition*(cWidth+linelen),
                                                          margin_y + vPostion*(cuVeMargin+cHeight)+offsetY,
                                                          cWidth,
                                                          cHeight)];
                        }

                        
                        [svgStr appendString:DrawText(margin_x  + hPosition*(cWidth+linelen),
                                                      margin_y + vPostion*(cuVeMargin+cHeight)+offsetY + cHeight/2,14,
                                                      @"white",
                                                      @"italic",
                                                      [cubicle valueForKey:@"cubicle_name"])];
                    }
                    
                }else{
                    
                    if ([types indexOfObject:_type] == 0) {
                        
                        NSInteger pos = [self getMainIndexWithConnection:connection];
                        
                        if (hPositionOri ==  pos+1) {
                            
                        } else {
                            [svgStr appendString:DrawLine(margin_x+hPosition*cWidth+(hPosition-1)*linelen,
                                                          margin_y + vPostion*cHeight+0.5*cHeight+vPostion*cuVeMargin+offsetY,
                                                          margin_x+hPosition*(cWidth+linelen),
                                                          margin_y + vPostion*cHeight+0.5*cHeight+vPostion*cuVeMargin+offsetY,LineInfo([cubicle valueForKey:@"cable_name"],[cubicle valueForKey:@"cable_id"], vPostion,[types indexOfObject:_type]))];
                            
                            [svgStr appendString:DrawTextClicked(margin_x+hPosition*cWidth+(hPosition-1)*linelen,
                                                          margin_y + vPostion*cHeight+0.5*cHeight+vPostion*cuVeMargin+offsetY - linetext_y_origin,14,
                                                          @"gray",
                                                          @"italic",
                                                          [cubicle valueForKey:@"cable_name"],LineInfo([cubicle valueForKey:@"cable_name"],[cubicle valueForKey:@"cable_id"], vPostion,[types indexOfObject:_type]))];
                            
                            if ([[cubicle valueForKey:@"cubicle_id"] isEqualToString:self.cubicleData[@"id"]]){
                            }else{
                                
                                if (vPostion%2==0) {
                                    [svgStr appendString:DrawRectD(margin_x + hPosition*(cWidth+linelen),
                                                                  margin_y + vPostion*(cuVeMargin+cHeight)+offsetY,
                                                                  cWidth,
                                                                  cHeight)];
                                }else{
                                    [svgStr appendString:DrawRect(margin_x + hPosition*(cWidth+linelen),
                                                                  margin_y + vPostion*(cuVeMargin+cHeight)+offsetY,
                                                                  cWidth,
                                                                  cHeight)];
                                }

                                
                                
                                [svgStr appendString:DrawText(margin_x  + hPosition*(cWidth+linelen),
                                                              margin_y + vPostion*(cuVeMargin+cHeight)+offsetY + cHeight/2,14,
                                                              @"white",
                                                              @"italic",
                                                              [cubicle valueForKey:@"cubicle_name"])];
                            }
                        }
                        
                        
                        
                    }else{
                        
                        [svgStr appendString:DrawLine(margin_x+hPosition*cWidth+(hPosition-1)*linelen,
                                                      margin_y + vPostion*cHeight+0.5*cHeight+vPostion*cuVeMargin+offsetY,
                                                      margin_x+hPosition*(cWidth+linelen),
                                                      margin_y + vPostion*cHeight+0.5*cHeight+vPostion*cuVeMargin+offsetY,LineInfo([cubicle valueForKey:@"cable_name"],[cubicle valueForKey:@"cable_id"], vPostion,[types indexOfObject:_type]))];
                        
                        [svgStr appendString:DrawTextClicked(margin_x+hPosition*cWidth+(hPosition-1)*linelen,
                                                      margin_y + vPostion*cHeight+0.5*cHeight+vPostion*cuVeMargin+offsetY - linetext_y_origin,14,
                                                      @"gray",
                                                      @"italic",
                                                      [cubicle valueForKey:@"cable_name"],LineInfo([cubicle valueForKey:@"cable_name"],[cubicle valueForKey:@"cable_id"], vPostion,[types indexOfObject:_type]))];
                        
                        if ([[cubicle valueForKey:@"cubicle_id"] isEqualToString:self.cubicleData[@"id"]]){
                        }else{
                            
                            if (vPostion%2==0) {
                                [svgStr appendString:DrawRectD(margin_x + hPosition*(cWidth+linelen),
                                                              margin_y + vPostion*(cuVeMargin+cHeight)+offsetY,
                                                              cWidth,
                                                              cHeight)];
                            }else{
                                [svgStr appendString:DrawRect(margin_x + hPosition*(cWidth+linelen),
                                                              margin_y + vPostion*(cuVeMargin+cHeight)+offsetY,
                                                              cWidth,
                                                              cHeight)];
                            }

                            
                            
                            [svgStr appendString:DrawText(margin_x  + hPosition*(cWidth+linelen),
                                                          margin_y + vPostion*(cuVeMargin+cHeight)+offsetY + cHeight/2,14,
                                                          @"white",
                                                          @"italic",
                                                          [cubicle valueForKey:@"cubicle_name"])];
                        }
                    }
                    
                    
                }
                hPosition++;
                hPositionOri++;
                if(hPosition>hPostionMax){
                    hPostionMax = hPosition;
                }
            }
            vPostion++;
        }
        
        //累加高度
        if (type.count) {
            if ([types indexOfObject:_type] == 0){
                if (flag) {
                    offsetY += self.mergedCubicles.count*cHeight + (self.mergedCubicles.count-1)*cuVeMargin + margin_y;
                }else{
                    offsetY += type.count*cHeight + (type.count-1)*cuVeMargin + margin_y;
                }
            }else{
                offsetY += type.count*cHeight + (type.count-1)*cuVeMargin + margin_y;
            }
            

            
        }
        
        if (!self.isForFiberPage) {
            [svgStr appendString:[NSString stringWithFormat:@"<line x1=\"%f\" y1=\"%f\" x2=\"%f\" y2=\"%f\" style=\"stroke-dasharray: 9, 5;stroke: gray; stroke-width: 2;\"/>",margin_x,
                                  offsetY + margin_y,
                                  margin_x + 1000,
                                  offsetY + margin_y]];
        }

        offsetY+= margin_y;
    }
    
    
    //跳纤连接
    types = self.type2list;
    
    if (types.count) {
        
        if (!self.isForFiberPage) {
            [svgStr appendString:DrawText(margin_x,
                                          margin_y + offsetY - 15,18,
                                          @"navy",
                                          @"italic",
                                          @"跳纤连接")];
        }

        //画两个屏
        for(int i = 0; i<2; i++){
            
            [svgStr appendString:DrawRect(i*(linelen + cWidth) + margin_x,
                                          margin_y + offsetY,
                                          cWidth,
                                          types.count*cHeight)];
            
            [svgStr appendString:DrawText(i*(linelen + cWidth) + margin_x + 10,
                                          margin_y + offsetY + (types.count*cHeight + (types.count-1)*cuVeMargin)*0.5,14,
                                          @"white",
                                          @"italic",
                                          self.cubicleData[@"name"])];
        }
        //画线缆
        for(int i = 0; i < types.count; i++){
            id cubicle = types[i];
            //draw line
            [svgStr appendString:DrawLine(margin_x + cWidth,
                                          margin_y + offsetY + (0.5+i)*cHeight,
                                          linelen + margin_x + cWidth,
                                          margin_y + offsetY + (0.5+i)*cHeight,LineInfo([cubicle valueForKey:@"cable_name"],[cubicle valueForKey:@"cable_id"], i,2))];
            
            [svgStr appendString:DrawTextClicked(margin_x + cWidth + 20,
                                          margin_y + offsetY + (0.5+i)*cHeight - linetext_y_origin,14,
                                          @"gray",
                                          @"italic",
                                          [cubicle valueForKey:@"cable_name"],LineInfo([cubicle valueForKey:@"cable_name"],[cubicle valueForKey:@"cable_id"], i,2))];
            
        }
        if (types.count) {
            offsetY += (types.count*cHeight + 2*margin_y) ;
        }
    }
    if (!self.isForFiberPage) {
        [svgStr appendString:@"</svg>"];
    }
    
    offsetY+= 50;
    NSString* result = [NSString stringWithString:svgStr];
    
    //计算出总高总宽并填回
    if (!self.isForFiberPage) {
        result = [result stringByReplacingOccurrencesOfString:@"++@@@++" withString:[NSString stringWithFormat:@"%f",offsetY]];
        result = [result stringByReplacingOccurrencesOfString:@"##@@@##" withString:[NSString stringWithFormat:@"%f",2*margin_x+hPostionMax*cWidth+(hPostionMax-1)*linelen]];
    }

    if (self.isForFiberPage) {
       result = [NSString stringWithFormat:@"%@**@@@**%f",result,offsetY];
    }
    
    
    return result;
}

//主屏是否从最左边画起
-(BOOL)shouldMainCubicleDrawFromLeftWithList:(NSArray*)list{
    
    for(NSArray* connection in list){
        id cubicle = connection[0];
        if (![[cubicle valueForKey:@"cubicle_id"] isEqualToString:self.cubicleData[@"id"]]) {
            return NO;
        }
    }
    return YES;
}

-(NSUInteger)getMainIndexWithConnection:(NSArray*)conn{
    
    NSUInteger index;
    
    for(int i = 0; i < conn.count;i++){
        if ([[conn[i] valueForKey:@"cubicle_id"] isEqualToString:self.cubicleData[@"id"]]) {
            index = i;
            break;
        }
    }
    
    return index;
}

-(SGCableTmpItem*)getGLCableWithConnection:(NSArray*)conn{
    
    NSUInteger index;
    
    for(int i = 0; i < conn.count;i++){
        if ([[conn[i] valueForKey:@"cubicle_id"] isEqualToString:self.cubicleData[@"id"]]) {
            index = i;
            break;
        }
    }
    
    SGCableTmpItem *item = [SGCableTmpItem new];
    [item setCableId:[conn[index+1] valueForKey:@"cable_id"]];
    [item setCableName:[conn[index+1] valueForKey:@"cable_name"]];
    [item setCubicleName:[conn[index+1] valueForKey:@"cubicle_name"]];
    [item setCubicleId:[conn[index+1] valueForKey:@"cubicle_id"]];
    return item;
}

-(NSArray*)getMergedCubicles{
    NSMutableArray* mergedCubicles = [NSMutableArray array];
    NSInteger count = 0;
    
    if (self.type0listSorted.count) {
        SGCableTmpItem* preItem = [self getGLCableWithConnection:self.type0listSorted[0]];
        
        for(NSUInteger i = 0; i <self.type0listSorted.count; i++){
            
            SGCableTmpItem *t = [self getGLCableWithConnection:self.type0listSorted[i]];
            
            if (![t.cableName isEqualToString:preItem.cableName]) {
                
                SGCableTmpItem* t1 = [SGCableTmpItem new];
                t1.count = count;
                t1.cableName = preItem.cableName;
                t1.cableId = preItem.cableId;
                t1.cubicleId = preItem.cubicleId;
                t1.cubicleName = preItem.cubicleName;
                
                [mergedCubicles addObject:t1];
                count = 0;
            }
            
            preItem = t;
            count++;
            
            if (i == self.type0listSorted.count-1) {
                SGCableTmpItem* t1 = [SGCableTmpItem new];
                t1.count = count;
                t1.cableName = preItem.cableName;
                t1.cableId = preItem.cableId;
                t1.cubicleId = preItem.cubicleId;
                t1.cubicleName = preItem.cubicleName;
                [mergedCubicles addObject:t1];
            }
        }
    }
    
    return mergedCubicles;
}

@end
