//
//  ALTParserMp4.c
//
//  Created by Alienchang on 2019/4/29.
//

#include "alt_mp4_parser.h"
#define NUM_16_TO_10(a,b,c,d) ((unsigned int) ( ((unsigned int)(a)) << 24 | ((unsigned int)(b)) << 16 | ((unsigned int)(c)) << 8 | ((unsigned int)(d)) ))
int convertTo256Int(char c) {
    if ((int)c < 0) {
        return 256 + (int)c;
    } else {
        return (int)c;
    }
}
// 将前4个字节转为int
long num16To10(const char *char16) {
    long num2 = convertTo256Int(char16[0]) * pow(16, 4) +
    convertTo256Int(char16[1])* pow(16, 3) +
    convertTo256Int(char16[2]) * pow(16, 2) +
    convertTo256Int(char16[3]);
    return num2;
}

int did_load_mdat(const char *mp4Data ,long long dataLength) {
    long long fTypeLength = num16To10(mp4Data);
    if (dataLength > fTypeLength) {
        long ftypeLength = num16To10(mp4Data);
        char *moovData = (char *)mp4Data + ftypeLength;
        unsigned long moovLength = num16To10(moovData);
        if (ftypeLength + moovLength < dataLength) {
            long long headerBoxLength = firstSamplePosition(mp4Data);
            long long configLength = num16To10(mp4Data + headerBoxLength);
            if (dataLength > headerBoxLength + configLength) {
                return 1;
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    } else {
        return 0;
    }
}

long firstSamplePosition(const char *mp4Data) {
    long ftypeLength = num16To10(mp4Data);
    char *moovData = (char *)mp4Data + ftypeLength;
    unsigned long moovLength = num16To10(moovData);
    if (num16To10(mp4Data + moovLength + ftypeLength) > 8) {
        return moovLength + 8 + ftypeLength;   // 4为mdata的长度以及char * mdat，24 为mtyp长度
    } else {
        return moovLength + 12 + ftypeLength;   // 4为mdata的长度以及char * mdat，24 为mtyp长度 ,freeBox
    }
//    return naluLength + num16To10(mp4Data + naluLength + ftypeLength) + 4 + ftypeLength;   // 4为mdata的长度以及char * mdat，24 为mtyp长度
}

int countF(char *data) {
    int fSignCount = 0;
    char cusFSign[1] = {255};
    while (memcmp(cusFSign, data + fSignCount, 1) == 0) {
        ++ fSignCount;
    }
    return fSignCount;
}

char *parserSample(char * sampleData ,long *dataSize ,int *ret) {
    long naluOffset = 0;    
    // nalu 长度
    long naluLength = num16To10(sampleData + naluOffset);
    int naluType = sampleData[4 + naluOffset] & 0x1F; // nalu type
    // 自定义帧
    if (naluType == 0 && naluLength > 0) {
        // 自定义数据
        naluOffset += (4 + naluLength);
        *dataSize = naluLength - 1;
        *ret = 0;
        return 0;
        //            return (char *)(sampleData + 5 + naluOffset);
    } else if (naluType == 6 && naluLength > 0) {  // sei
        int seiType = sampleData[5 + naluOffset] & 0x1F;
        if (seiType == 5) {
            int fSignCount = 0;
            naluOffset += 6;
            fSignCount = countF(sampleData + naluOffset);
            naluOffset += fSignCount;
            
            int tailSize = (sampleData + fSignCount + 6)[0];
            if (tailSize < 0) {
                tailSize = 256 + tailSize;
            }
            int uuidNum = 16;
            int seiSize = 255 * fSignCount + tailSize - uuidNum;
            naluOffset ++;
            naluOffset += uuidNum;    // UUID 16个字节
            *dataSize = seiSize;
            *ret = 1;
            return (char *)(sampleData + naluOffset);
        }
    } else {
        naluOffset += (4 + naluLength);
    }
    *ret = 0;
    return 0;
}
// 去除数据中转义自动生成的03
char *deleteSegFileBuffer(char *fileBuffer ,long size ,long *targetSize) {
    char *targetImageBuffer = malloc(size);
    char *segBuffer = malloc(4);
    segBuffer[0] = 0;
    segBuffer[1] = 0;
    segBuffer[2] = 0;
    segBuffer[3] = 0;
    char seg[4] = {0 ,0 ,3 ,0};
    
    long segCount = 0;
    int j = 0;
    for (int i = 0; i < size; ++i) {
        segBuffer[0] = segBuffer[1];
        segBuffer[1] = segBuffer[2];
        segBuffer[2] = segBuffer[3];
        segBuffer[3] = fileBuffer[i];
        if (memcmp(seg, segBuffer, 4) == 0) {
            segBuffer[0] = 0;
            segBuffer[1] = 0;
            segBuffer[2] = 0;
            segBuffer[3] = fileBuffer[i + 1];
            ++i;
            ++ segCount;
        }
        
        if (j > 2) {
            targetImageBuffer[j - 3] = segBuffer[0];
        }
        ++j;
    }
    *targetSize = (int)(size - segCount);
    targetImageBuffer[*targetSize - 3] = segBuffer[1];
    targetImageBuffer[*targetSize - 2] = segBuffer[2];
    targetImageBuffer[*targetSize - 1] = segBuffer[3];
    
    free(segBuffer);
    return targetImageBuffer;
}

// 获取图片
char *get_img(char *imageChar ,long *dataSize) {
    int fcount = countF(imageChar + 6);
    int fEndOffset = fcount + 6;
    long length = 256 + (imageChar + fEndOffset)[0] + fcount * 255;
    int uuidNum = 16;
    long imageLength = length - uuidNum;
    *dataSize = imageLength;
    long deletedSize = 0;
    char *fullImage = deleteSegFileBuffer(imageChar + fEndOffset + uuidNum + 1, imageLength, &deletedSize); 
    *dataSize = deletedSize;
    return fullImage;
}





