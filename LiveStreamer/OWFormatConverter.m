//
//  OWFormatConverter.m
//  LiveStreamer
//
//  Created by Christopher Ballinger on 9/12/13.
//  Copyright (c) 2013 OpenWatch, Inc. All rights reserved.
//

/* Parts of this code adapted from demuxing.c from ffmpeg example
 * Copyright (c) 2012 Stefano Sabatini
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import "OWFormatConverter.h"
#import "avformat.h"
#import "libavutil/imgutils.h"
#import "libavutil/samplefmt.h"
#import "libavutil/timestamp.h"
#import "libavformat/avformat.h"

@interface OWFormatConverter() {
    uint8_t *video_dst_data[4];
    int video_dst_linesize[4];
    AVFormatContext *fmt_ctx;
    AVCodecContext *video_dec_ctx, *audio_dec_ctx;
    AVStream *video_stream, *audio_stream;
    const char *src_filename;
    const char *video_dst_filename;
    const char *audio_dst_filename;
    FILE *video_dst_file;
    FILE *audio_dst_file;
    
    
    int video_dst_bufsize;
    
    uint8_t **audio_dst_data;
    int       audio_dst_linesize;
    int audio_dst_bufsize;
    
    int video_stream_idx, audio_stream_idx;
    AVFrame *frame;
    AVPacket pkt;
    int video_frame_count;
    int audio_frame_count;
}

@end

@implementation OWFormatConverter

- (id) init {
    if (self = [super init]) {
        fmt_ctx = NULL;
        video_dec_ctx = NULL;
        audio_dec_ctx = NULL;
        video_stream = NULL;
        audio_stream = NULL;
        src_filename = NULL;
        video_dst_filename = NULL;
        audio_dst_filename = NULL;
        video_dst_file = NULL;
        audio_dst_file = NULL;
        
        audio_dst_data = NULL;

        video_stream_idx = -1, audio_stream_idx = -1;
        frame = NULL;
        video_frame_count = 0;
        audio_frame_count = 0;
    }
    return self;
}

- (int) decodePacket:(int*)got_frame cached:(int)cached {
    int ret = 0;
    
    if (pkt.stream_index == video_stream_idx) {
        /* decode video frame */
        ret = avcodec_decode_video2(video_dec_ctx, frame, got_frame, &pkt);
        if (ret < 0) {
            fprintf(stderr, "Error decoding video frame\n");
            return ret;
        }
        
        if (*got_frame) {
            printf("video_frame%s n:%d coded_n:%d pts:%s\n",
                   cached ? "(cached)" : "",
                   video_frame_count++, frame->coded_picture_number,
                   av_ts2timestr(frame->pts, &video_dec_ctx->time_base));
            
            /* copy decoded frame to destination buffer:
             * this is required since rawvideo expects non aligned data */
            av_image_copy(video_dst_data, video_dst_linesize,
                          (const uint8_t **)(frame->data), frame->linesize,
                          video_dec_ctx->pix_fmt, video_dec_ctx->width, video_dec_ctx->height);
            
            /* write to rawvideo file */
            fwrite(video_dst_data[0], 1, video_dst_bufsize, video_dst_file);
        }
    } else if (pkt.stream_index == audio_stream_idx) {
        /* decode audio frame */
        ret = avcodec_decode_audio4(audio_dec_ctx, frame, got_frame, &pkt);
        if (ret < 0) {
            fprintf(stderr, "Error decoding audio frame\n");
            return ret;
        }
        
        if (*got_frame) {
            printf("audio_frame%s n:%d nb_samples:%d pts:%s\n",
                   cached ? "(cached)" : "",
                   audio_frame_count++, frame->nb_samples,
                   av_ts2timestr(frame->pts, &audio_dec_ctx->time_base));
            
            ret = av_samples_alloc(audio_dst_data, &audio_dst_linesize, av_frame_get_channels(frame),
                                   frame->nb_samples, frame->format, 1);
            if (ret < 0) {
                fprintf(stderr, "Could not allocate audio buffer\n");
                return AVERROR(ENOMEM);
            }
            
            /* TODO: extend return code of the av_samples_* functions so that this call is not needed */
            audio_dst_bufsize =
            av_samples_get_buffer_size(NULL, av_frame_get_channels(frame),
                                       frame->nb_samples, frame->format, 1);
            
            /* copy audio data to destination buffer:
             * this is required since rawaudio expects non aligned data */
            av_samples_copy(audio_dst_data, frame->data, 0, 0,
                            frame->nb_samples, av_frame_get_channels(frame), frame->format);
            
            /* write to rawaudio file */
            fwrite(audio_dst_data[0], 1, audio_dst_bufsize, audio_dst_file);
            av_freep(&audio_dst_data[0]);
        }
    }
    
    return ret;
}

- (int) openCodecContext:(int*)stream_idx formatContext:(AVFormatContext *)formatContext type:(enum AVMediaType)type
{
    int ret;
    AVStream *st;
    AVCodecContext *dec_ctx = NULL;
    AVCodec *dec = NULL;
    
    ret = av_find_best_stream(formatContext, type, -1, -1, NULL, 0);
    if (ret < 0) {
        fprintf(stderr, "Could not find %s stream in input file '%s'\n",
                av_get_media_type_string(type), src_filename);
        return ret;
    } else {
        *stream_idx = ret;
        st = formatContext->streams[*stream_idx];
        
        /* find decoder for the stream */
        dec_ctx = st->codec;
        dec = avcodec_find_decoder(dec_ctx->codec_id);
        if (!dec) {
            fprintf(stderr, "Failed to find %s codec\n",
                    av_get_media_type_string(type));
            return ret;
        }
        
        if ((ret = avcodec_open2(dec_ctx, dec, NULL)) < 0) {
            fprintf(stderr, "Failed to open %s codec\n",
                    av_get_media_type_string(type));
            return ret;
        }
    }
    
    return 0;
}

- (int) format:(const char **)format forSampleFormat:(enum AVSampleFormat)sample_fmt
{
    int i;
    struct sample_fmt_entry {
        enum AVSampleFormat sample_fmt; const char *fmt_be, *fmt_le;
    } sample_fmt_entries[] = {
        { AV_SAMPLE_FMT_U8,  "u8",    "u8"    },
        { AV_SAMPLE_FMT_S16, "s16be", "s16le" },
        { AV_SAMPLE_FMT_S32, "s32be", "s32le" },
        { AV_SAMPLE_FMT_FLT, "f32be", "f32le" },
        { AV_SAMPLE_FMT_DBL, "f64be", "f64le" },
    };
    *format = NULL;
    
    for (i = 0; i < FF_ARRAY_ELEMS(sample_fmt_entries); i++) {
        struct sample_fmt_entry *entry = &sample_fmt_entries[i];
        if (sample_fmt == entry->sample_fmt) {
            *format = AV_NE(entry->fmt_be, entry->fmt_le);
            return 0;
        }
    }
    
    fprintf(stderr,
            "sample format %s is not supported as output format\n",
            av_get_sample_fmt_name(sample_fmt));
    return -1;
}

- (void) cleanupFFmpeg {
    if (video_dec_ctx)
        avcodec_close(video_dec_ctx);
    if (audio_dec_ctx)
        avcodec_close(audio_dec_ctx);
    avformat_close_input(&fmt_ctx);
    if (video_dst_file)
        fclose(video_dst_file);
    if (audio_dst_file)
        fclose(audio_dst_file);
    av_free(frame);
    av_free(video_dst_data[0]);
    av_free(audio_dst_data);
}

- (void) convertFileAtPath:(NSString*)inputPath outputPath:(NSString*)outputPath completionBlock:(OWFormatConverterCallback)completionCallback {
    int ret = 0, got_frame;
    AVOutputFormat *fmt;
    AVFormatContext *oc;
    AVStream *audio_st, *video_st;
    AVCodec *audio_codec, *video_codec;
    double audio_time, video_time;
    /*
    if (argc != 4) {
        fprintf(stderr, "usage: %s input_file video_output_file audio_output_file\n"
                "API example program to show how to read frames from an input file.\n"
                "This program reads frames from a file, decodes them, and writes decoded\n"
                "video frames to a rawvideo file named video_output_file, and decoded\n"
                "audio frames to a rawaudio file named audio_output_file.\n"
                "\n", argv[0]);
        exit(1);
    }
    */
    
    
    src_filename = [inputPath UTF8String];
    const char * output_filename = [outputPath UTF8String];
    
    /* register all formats and codecs */
    av_register_all();
    
    
    /* allocate the output media context */
    avformat_alloc_output_context2(&oc, NULL, NULL, output_filename);
    if (!oc) {
        printf("Could not deduce output format from file extension: using MPEGTS.\n");
        avformat_alloc_output_context2(&oc, NULL, "mpegts", output_filename);
    }
    if (!oc) {
        NSLog(@"No output context!");
        return;
    }
    fmt = oc->oformat;
    
    /* open input file, and allocate format context */
    if (avformat_open_input(&fmt_ctx, src_filename, NULL, NULL) < 0) {
        fprintf(stderr, "Could not open source file %s\n", src_filename);
        exit(1);
    }
    
    /* retrieve stream information */
    if (avformat_find_stream_info(fmt_ctx, NULL) < 0) {
        fprintf(stderr, "Could not find stream information\n");
        exit(1);
    }
    
    
    
    if ([self openCodecContext:&video_stream_idx formatContext:fmt_ctx type:AVMEDIA_TYPE_VIDEO] >= 0) {
        video_stream = fmt_ctx->streams[video_stream_idx];
        video_dec_ctx = video_stream->codec;
        
        video_dst_file = fopen(video_dst_filename, "wb");
        if (!video_dst_file) {
            fprintf(stderr, "Could not open destination file %s\n", video_dst_filename);
            ret = 1;
        }
        
        /* allocate image where the decoded image will be put */
        ret = av_image_alloc(video_dst_data, video_dst_linesize,
                             video_dec_ctx->width, video_dec_ctx->height,
                             video_dec_ctx->pix_fmt, 1);
        if (ret < 0) {
            fprintf(stderr, "Could not allocate raw video buffer\n");
            [self cleanupFFmpeg];
            return;
        }
        video_dst_bufsize = ret;
    }
    
    
    if ([self openCodecContext:&audio_stream_idx formatContext:fmt_ctx type:AVMEDIA_TYPE_AUDIO]
 >= 0) {
        int nb_planes;
        
        audio_stream = fmt_ctx->streams[audio_stream_idx];
        audio_dec_ctx = audio_stream->codec;
        audio_dst_file = fopen(audio_dst_filename, "wb");
        if (!audio_dst_file) {
            fprintf(stderr, "Could not open destination file %s\n", video_dst_filename);
            ret = 1;
            [self cleanupFFmpeg];
            return;
        }
        
        nb_planes = av_sample_fmt_is_planar(audio_dec_ctx->sample_fmt) ?
        audio_dec_ctx->channels : 1;
        audio_dst_data = av_mallocz(sizeof(uint8_t *) * nb_planes);
        if (!audio_dst_data) {
            fprintf(stderr, "Could not allocate audio data buffers\n");
            ret = AVERROR(ENOMEM);
            [self cleanupFFmpeg];
            return;
        }
    }
    
    /* dump input information to stderr */
    av_dump_format(fmt_ctx, 0, src_filename, 0);
    
    if (!audio_stream && !video_stream) {
        fprintf(stderr, "Could not find audio or video stream in the input, aborting\n");
        ret = 1;
        [self cleanupFFmpeg];
        return;
    }
    
    frame = avcodec_alloc_frame();
    if (!frame) {
        fprintf(stderr, "Could not allocate frame\n");
        ret = AVERROR(ENOMEM);
        [self cleanupFFmpeg];
        return;
    }
    
    /* initialize packet, set data to NULL, let the demuxer fill it */
    av_init_packet(&pkt);
    pkt.data = NULL;
    pkt.size = 0;
    
    if (video_stream)
        printf("Demuxing video from file '%s' into '%s'\n", src_filename, video_dst_filename);
    if (audio_stream)
        printf("Demuxing audio from file '%s' into '%s'\n", src_filename, audio_dst_filename);
    
    /* read frames from the file */
    while (av_read_frame(fmt_ctx, &pkt) >= 0) {
        [self decodePacket:&got_frame cached:0];
        av_free_packet(&pkt);
    }
    
    /* flush cached frames */
    pkt.data = NULL;
    pkt.size = 0;
    do {
        [self decodePacket:&got_frame cached:1];
    } while (got_frame);
    
    printf("Demuxing succeeded.\n");
    
    if (video_stream) {
        printf("Play the output video file with the command:\n"
               "ffplay -f rawvideo -pix_fmt %s -video_size %dx%d %s\n",
               av_get_pix_fmt_name(video_dec_ctx->pix_fmt), video_dec_ctx->width, video_dec_ctx->height,
               video_dst_filename);
    }
    
    if (audio_stream) {
        const char *fmt;
        if ((ret = [self format:&fmt forSampleFormat:audio_dec_ctx->sample_fmt]) < 0) {
            [self cleanupFFmpeg];
            return;
        }
        printf("Play the output audio file with the command:\n"
               "ffplay -f %s -ac %d -ar %d %s\n",
               fmt, audio_dec_ctx->channels, audio_dec_ctx->sample_rate,
               audio_dst_filename);
    }
    

}

@end
