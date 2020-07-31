//
//  Rendering.metal
//  TraceEditor
//
//  Created by Noah Pikielny on 7/24/20.
//  Copyright © 2020 Noah Pikielny. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

constant float2 quadVertices[] = {
    float2(-1, -1),
    float2(-1,  1),
    float2( 1,  1),
    float2(-1, -1),
    float2( 1,  1),
    float2( 1, -1)
};

struct CopyVertexOut {
    float4 position [[position]];
    float2 uv;
};

// Simple vertex shader which passes through NDC quad positions
vertex CopyVertexOut copyVertex(unsigned short vid [[vertex_id]]) {
    float2 position = quadVertices[vid];
    
    CopyVertexOut out;
    
    out.position = float4(position, 0, 1);
    out.uv = position * 0.5f + 0.5f;
    
    return out;
}

//Type Key:
//    Oligo = 0,
//    NG2 = 1,
//    Axon = 2,
//    Undefined = 3

struct Trace {
    int index;
    bool selected;
    int type;
    int parent;
};

struct Point {
    int n;
    int type;
    float3 position;
    float radius;
    int parent;
    int trace;
};

typedef enum SelectionType {
    single = 0,
    addition = 1,
    subtraction = 2,
    negative = 3
} SelectionType;

struct Uniform {
    int pointCount;
    float3 dimension;
    float3 imageSize;
    int frame;
    bool selecting;
    int selectionType;
    int2 center;
    int2 size;
    float3 selectionColor;
    
    float3 baseColor;
    float fade;
    float embolden;
    bool showImages;
    bool grayScale;
    bool showTraces;
    bool showSelection;
};

// Simple fragment shader which copies a texture and applies a simple tonemapping function
fragment float4 copyFragment(CopyVertexOut in [[stage_in]],
                             constant Uniform &uniform [[buffer(0)]],
                             texture2d<float> traceTexture [[texture(0)]],
                             texture2d<float> imageTexture [[texture(1)]],
                             texture2d<float> imageTextureNeg [[texture(2)]],
                             texture2d<float> imageTexturePos [[texture(3)]])
{
    constexpr sampler sam(min_filter::nearest, mag_filter::nearest, mip_filter::none);
    
//    float3 color = max(traceTexture.sample(sam, in.uv).xyz, imageTexture.sample(sam, in.uv));
//    float3 color;
    float4 imageValue = imageTexture.sample(sam, in.uv);
    if (uniform.frame > 0 && uniform.frame < int(uniform.dimension.z) - 1) {
        imageValue = imageValue * 0.5 + imageTextureNeg.sample(sam, in.uv)*0.25 + imageTexturePos.sample(sam, in.uv)*0.25;
    }else if (uniform.frame > 0) {
        imageValue = imageValue * 0.67 + imageTextureNeg.sample(sam, in.uv)*0.33;
    }else if (uniform.frame < int(uniform.dimension.z) - 1) {
        imageValue = imageValue * 0.67 + imageTexturePos.sample(sam, in.uv)*0.33;
    }
    if (uniform.grayScale) {
        imageValue = float4(float3(length(imageValue.xyz)/3),1);
    }
    float4 traceValue = traceTexture.sample(sam, in.uv);
    float totalAlpha = imageValue.w + traceValue.w;
    float3 color;
    if (uniform.showImages) {
        color = (imageValue.xyz*imageValue.w/4+traceValue.xyz*traceValue.w)/totalAlpha;
    }else {
        color = traceValue.xyz*traceValue.w;
    }
//    if (length(traceTexture.sample(sam, in.uv)) > 0) {
//        color = traceTexture.sample(sam, in.uv).xyz;
//    }else {
//        color = imageTexture.sample(sam, in.uv).xyz;
//    }
       
    int2 difference = int2(uniform.center) - int2(in.uv*uniform.imageSize.xy);
        
    if (abs(difference.x) < uniform.size.x / 2 && abs(difference.y) < uniform.size.y / 2) {
        color = color/2+float3(0.1)/2;
    }else if (abs(difference.x) <= uniform.size.x/2 && abs(difference.y) <= uniform.size.y / 2) {
        color = color/2+float3(1)/2;
    }
    // Apply a very simple tonemapping function to reduce the dynamic range of the
    // input image into a range which can be displayed on screen.
//    color = color / (1.0f + color);
    
    return float4(color, 1.0f);
}

struct ImagesArray {
    texture2d<float, access::read>images;
};

kernel void copy(uint2 tid [[thread_position_in_grid]],
                 texture2d<float, access::read_write> presentingImage [[texture(0)]]) {
    presentingImage.write(float4(0), tid);
    
//    int2 difference = int2(uniform.center) - int2(tid);
    
//    if (abs(difference.x) < uniform.size.x / 2 && abs(difference.y) < uniform.size.y / 2) {
//        presentingImage.write(originalImage.read(tid)/2+float4(0.1)/2, tid);
//    }else if (abs(difference.x) <= uniform.size.x/2 && abs(difference.y) <= uniform.size.y / 2) {
//        presentingImage.write(originalImage.read(tid)/2+float4(1)/2, tid);
//    }else {
//        presentingImage.write(originalImage.read(tid), tid);
//    }
//    presentingImage.write(originalImage.read(tid), tid);
//    presentingImage.write(images.images.read(tid), tid);
}

bool compareVector (float4 vector1, float4 vector2) {
    return distance(vector1, vector2) == 0;
}

float4 getColor(int trace) {
    return abs(float4(sin(float(trace)),cos(float(trace)),sin(cos(trace+M_E_F)),1));
}

//bool between (float value, float bounds1, float bounds2) {
//    return (value <= max(bounds1, bounds2) && value >= min(bounds1, bounds2));
//}
//
//bool checkIntersection (float2 p1, float2 p2, int2 center, int2 size) {
//    float2 Min = float2(center - size/2);
//    float2 Max = float2(center + size/2);
//    return ((between(Min.x, p1.x, p2.x) && between(Min.y, p1.y, p2.y)) || (between(Min.x, p1.x, p2.x) && between(Max.y, p1.y, p2.y)) || (between(Max.x, p1.x, p2.x) && between(Min.y, p1.y, p2.y)) || (between(Max.x, p1.x, p2.x) && between(Max.y, p1.y, p2.y)));
//}

//struct Test {
//    array<int, 2> values;
//};

void write (float3 position, int frame, int2 imageDimension, float embolden, float fade, bool selected, float3 color, bool showSelection, texture2d<float, access::read_write> image) {
    int sideLength = int(embolden / clamp(abs(float(frame) - position.z)/4,float(1),INFINITY));
    if (selected && showSelection) {
        sideLength = 5;
    }
    for (int x = - sideLength/2; x <= sideLength / 2; x ++) {
        for (int y = - sideLength/2; y <= sideLength / 2; y ++) {
            int2 writingCoords = int2(position.xy) + int2(x,y);
            if (writingCoords.x >= 0 && writingCoords.y >= 0 && writingCoords.x < imageDimension.x && writingCoords.y < imageDimension.y) {
                float4 imValue = image.read(uint2(writingCoords));
                if (compareVector(float4(0,0,0,0), imValue) || compareVector(float4(1), imValue)) {
                    if (selected) {
                        if (showSelection) {
                            image.write(float4(color,1), uint2(writingCoords));
                        }else {
                            image.write(float4(color,1/pow(clamp(abs(float(frame)-position.z),float(1),INFINITY),fade)), uint2(writingCoords));
                        }
                    }else {
                        image.write(float4(color,1/pow(clamp(abs(float(frame)-position.z),float(1),INFINITY),fade)), uint2(writingCoords));
                    }
                }
            }
        }
    }
}

kernel void draw(uint2 tid [[thread_position_in_grid]],
                 device Trace *traces [[buffer(0)]],
                 constant Point *points [[buffer(1)]],
                 constant Uniform &uniform [[buffer(2)]],
                 texture2d<float, access::read_write> presentingImage [[texture(1)]]) {
    int Index = tid.x + tid.y * uniform.pointCount;
    constant Point &point = points[Index];
    
    int2 difference = int2(point.position.xy) - int2(uniform.center);
    if (abs(difference.x) < uniform.size.x / 2 && abs(difference.y) < uniform.size.y / 2) {
        if (uniform.selectionType == single || uniform.selectionType == addition || uniform.selectionType == negative) {
            if (abs(point.position.z - uniform.frame) <= 5) {
                if (uniform.selectionType == negative) {
                    traces[point.trace].selected = !traces[point.trace].selected;
                }else {
                    traces[point.trace].selected = true;
                }
            }
        }else {
            if (uniform.showSelection || abs(point.position.z - uniform.frame) <= 5) {
                traces[point.trace].selected = false;
            }
        }
    }
    
    if (point.parent != -1) {
        constant Point &last = points[point.parent-1];
//        if (checkIntersection(point.position.xy, last.position.xy, uniform.center, uniform.size)) {
//            traces[point.trace].selected = true;
//        }
        float3 difference = point.position - last.position;

        float dist = distance(point.position.xy, last.position.xy);
        if (dist > 0) {
            if (dist > 500) {
                dist = 500;
            }
            for (int t = 0; t < int(dist); t ++) {
                float3 position = last.position + difference*float(t)/float(int(dist));
                if (!compareVector(presentingImage.read(uint2(position.xy)), float4(1))) {
                    write(position, uniform.frame, int2(uniform.dimension.xy), uniform.embolden, uniform.fade, traces[point.trace].selected, traces[point.trace].selected?uniform.selectionColor:uniform.baseColor, uniform.showSelection, presentingImage);
                }
            }
        }
//        if (int(d) > 0) {
//            for (int t = 0; t < int(d); t ++) {
//    //            float x = (float(t/400)*(point.position.x - last.position.x) + last.position.x);
//    //            float y = m * x + b;
//                float2 position = last.position.xy + difference*float(t)/d;
//                presentingImage.write(float4(0,0,1,1), uint2(position));
//            }
//        }
    }
    write(point.position, uniform.frame, int2(uniform.dimension.xy), uniform.embolden, uniform.fade, traces[point.trace].selected, traces[point.trace].selected?uniform.selectionColor:uniform.baseColor, uniform.showSelection, presentingImage);
}
