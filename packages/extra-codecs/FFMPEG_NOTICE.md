# FFmpeg Notice

This software incorporates the FFmpeg library (https://ffmpeg.org/).

FFmpeg is Copyright (c) 2000-2025 the FFmpeg developers.

FFmpeg is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This build of FFmpeg was configured with:

```
./configure --target-os=none --arch=x86_32 --enable-cross-compile \
  --disable-asm --disable-x86asm --disable-inline-asm \
  --disable-programs --disable-doc --disable-debug \
  --disable-all --disable-everything --disable-autodetect \
  --disable-pthreads --disable-runtime-cpudetect \
  --disable-gpl \
  --enable-avcodec --enable-swresample \
  --enable-decoder=dca --enable-decoder=truehd \
  --enable-decoder=ac3 --enable-decoder=eac3 \
  --enable-decoder=flac --enable-decoder=opus \
  --enable-small \
  --cc=emcc --cxx=em++ --ar=emar --nm=emnm --ranlib=emranlib \
  --extra-cflags="-DNDEBUG -Oz -flto -fno-math-errno -mnontrapping-fptoint -msign-ext" \
  --extra-ldflags="-flto"
```

License: LGPL version 2.1 or later

The complete corresponding source code for FFmpeg is available at:
https://github.com/FFmpeg/FFmpeg

The build configuration and scripts used to produce this FFmpeg binary are available at:
https://github.com/Vanilagy/mediabunny/tree/main/packages/extra-codecs
