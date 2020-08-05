FROM circleci/android:api-30-ndk

USER root

RUN apt-get update
RUN apt-get install -y git swig openjdk-11-jdk

RUN git clone --branch 2.10 --depth 1 https://github.com/pjsip/pjproject.git
RUN wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz
RUN tar -zxf openssl-1.1.1g.tar.gz

ENV ANDROID_NDK_ROOT=/opt/android/android-ndk-r20
ENV TARGET_ABI=arm64-v8a
ENV ANDROID_API=29
ENV PATH=/opt/android/android-ndk-r20/toolchains/llvm/prebuilt/linux-x86_64/bin/:$PATH

RUN cd openssl-1.1.1g && \
	./Configure android-arm64 -D__ANDROID_API__=$ANDROID_API && make -j8 && \
	mkdir lib && cp lib*.a lib/

RUN cd pjproject && \
	echo "#define PJ_CONFIG_ANDROID 1" > pjlib/include/pj/config_site.h && \
	echo "#include <pj/config_site_sample.h>" > pjlib/include/pj/config_site.h && \
	./configure-android --use-ndk-cflags --with-ssl=/openssl-1.1.1g && \
	make -j8 dep && make clean && make -j8

RUN cd pjproject/pjsip-apps/src/swig/ && make
