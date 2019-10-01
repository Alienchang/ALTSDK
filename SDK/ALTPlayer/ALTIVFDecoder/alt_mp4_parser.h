//
//  ALTParserMp4.h
//
//  Created by Alienchang on 2019/4/29.
//

#include <stdio.h>
#include <stdlib.h> 
#include <string.h>
#include <math.h>


char *parserSample(char * sampleData ,long *dataSize ,int *ret);
int countF(char *data);
char *deleteSegFileBuffer(char *fileBuffer ,long size ,long *targetSize);
char *get_img(char *imageChar ,long *dataSize);
int extract_pic_info(const char *pic, const uint32_t size, int *width, int *height);
long firstSamplePosition(const char *mp4Data);
// 是否已经加载mdat数据
int did_load_mdat(const char *mp4Data ,long long dataLength);
