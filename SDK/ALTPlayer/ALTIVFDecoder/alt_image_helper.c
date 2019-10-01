//
//  alt_image_helper.c
//  ALTSDK
//
//  Created by Alienchang on 2019/5/6.
//  Copyright © 2019 Alienchang. All rights reserved.
//

#include "alt_image_helper.h"

#define MAKEUS(a, b)    ((unsigned short) ( ((unsigned short)(a))<<8 | ((unsigned short)(b)) ))
#define MAKEUI(a,b,c,d) ((unsigned int) ( ((unsigned int)(a)) << 24 | ((unsigned int)(b)) << 16 | ((unsigned int)(c)) << 8 | ((unsigned int)(d)) ))

#define M_DATA  0x00
#define M_SOF0  0xc0
#define M_DHT   0xc4
#define M_SOI   0xd8
#define M_EOI   0xd9
#define M_SOS   0xda
#define M_DQT   0xdb
#define M_DNL   0xdc
#define M_DRI   0xdd
#define M_APP0  0xe0
#define M_APPF  0xef

// 获取图片信息
int extract_pic_info(const char *pic, const uint32_t size, int *width, int *height) {
    char png_signature[4] = {137 ,80 ,78 ,71};
    char gif_signature[7] = {'G' ,'I' ,'F' ,'8' ,'9' ,'7' ,'a'};
    char bmp_signature[2] = {'B' ,'M'};
    char jpeg_signature[3] = {255 ,216 ,217};
    int ret = -1;
    *width = 0;
    *height = 0;
    size_t offset = 0;
    if (pic == NULL)
    return ret;
    if ((pic[0] == gif_signature[0]) && (pic[1] == gif_signature[1]) && (pic[2] == gif_signature[2]) && (pic[3] == gif_signature[3]) && (pic[4] == gif_signature[4] || pic[4] == gif_signature[5]) && (pic[5] == gif_signature[6])) {
        //gif
        offset = 6;
        *width = MAKEUS(pic[offset + 1], pic[offset]);
        offset += 2;
        *height = MAKEUS(pic[offset + 1], pic[offset]);
        ret = 0;
    } else if ((pic[0] == bmp_signature[0]) && (pic[1] == bmp_signature[1])) {
        //BMP
        offset = 18;
        *width = MAKEUI(pic[offset + 3], pic[offset + 2], pic[offset + 1], pic[offset + 0]);
        offset += 4;
        *height = MAKEUS(pic[offset + 1], pic[offset]);
        ret = 0;
    } else if (pic[0] == png_signature[0] && pic[1] == png_signature[1] && pic[2] == png_signature[2] && pic[3] == png_signature[3]) {
        //PNG
        offset = 16;
        *width = MAKEUI(pic[offset + 0], pic[offset + 1], pic[offset + 2], pic[offset + 3]);
        offset += 4;
        *height = MAKEUI(pic[offset + 0], pic[offset + 1], pic[offset + 2], pic[offset + 3]);
        ret = 0;
    } else if (pic[0] == jpeg_signature[0] && pic[1] == jpeg_signature[1] && pic[size-2] == jpeg_signature[0] && pic[size-1] == jpeg_signature[2]) {
        //JPEG
        int finish = 0;
        offset = 0;
        unsigned char id = 0;
        while(!finish && offset < size)
        {
            if (pic[offset++] != (const char)255 || offset >= size)
            {
                ret = -2;
                break;
            }
            id = pic[offset++];
            if (id >= M_APP0 && id <= M_APPF) // app data block
            {
                offset += MAKEUS(pic[offset], pic[offset + 1]);
                continue;
            }
            switch(id)
            {
                    case M_SOI:
                    break;
                    case M_DQT:
                    case M_DHT:
                    case M_DNL:
                    case M_DRI:
                    offset += MAKEUS(pic[offset], pic[offset + 1]);
                    break;
                    case M_SOF0:
                    offset += 3;
                    *height = MAKEUS(pic[offset], pic[offset + 1]);
                    offset += 2;
                    *width = MAKEUS(pic[offset], pic[offset + 1]);
                    finish = 1;
                    ret = 0;
                    break;
                    case M_SOS:
                    case M_EOI:
                    case M_DATA:
                    finish = 1;
                    ret = -1;
                    break;
                default:
                    offset += MAKEUS(pic[offset], pic[offset + 1]);
                    break;
            }
        }
    }
    return ret;
}
