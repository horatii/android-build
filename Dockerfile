FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

ENV ANDROID_HOME='/opt/android'

ENV TZ=Asia/Shanghai

RUN set -eux; \	
	sed -i "s/security.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list; \ 
	sed -i "s/archive.ubuntu.com/mirrors.cloud.tencent.com/g" /etc/apt/sources.list;  \
	apt-get -qq update; \	
	apt-get -qq install -y --no-install-recommends; \
	apt-get -qq install -y tzdata; \
	apt-get -qq install -y apt-utils; \
	apt-get -qq install -y curl tar unzip; \
	apt-get -qq install -y lib32stdc++6 lib32z1; \
	apt-get -qq install -y libc6-i386 lib32gcc1; \	
	apt-get -qq install -y build-essential; \
	apt-get -qq install -y g++-multilib; \
	apt-get -qq install -y cmake; \	 
	apt-get -qq install -y openjdk-8-jdk openjdk-8-jre; \
	apt-get -qq install -y git; \
	apt-get -qq install -y python3 python3-pip; \
	apt-get -qq autoremove -y; \
	apt-get -qq autoclean; \	
	apt-get -qq update; \
	rm -rf /var/lib/apt/lists/*; \
	rm -rf /tmp/*
	
RUN set -eux; \    
	curl -o cmdline-tools.zip -fL "https://dl.google.com/android/repository/commandlinetools-linux-8512546_latest.zip"; \
	mkdir -p ${ANDROID_HOME}/cmdline-tools; \
	unzip -d ${ANDROID_HOME}/ cmdline-tools.zip; \
	rm  cmdline-tools.zip;
	
ENV PATH=$PATH:${ANDROID_HOME}/cmdline-tools/bin/

RUN set -eux; \
	yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses || true; \
	sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-26"; \
	sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools"; \
	sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;30.0.2"; \
	sdkmanager --sdk_root=${ANDROID_HOME} "cmake;3.18.1"; \
	sdkmanager --sdk_root=${ANDROID_HOME} "ndk;21.4.7075529"
	
RUN set -eux; \
	sdkmanager --sdk_root=${ANDROID_HOME} --install "emulator"

ENV ANDROID_NDK_HOME=${ANDROID_HOME}/ndk/21.4.7075529/ 

RUN set -eux; \
	pip3 install --quiet conan -i  https://mirrors.aliyun.com/pypi/simple/; \
	pip3 install --quiet conan_package_tools -i  https://mirrors.aliyun.com/pypi/simple/; \
	conan config set general.revisions_enabled=1; \
	conan profile new default --detect; \
	conan profile update settings.compiler.libcxx=libstdc++11 default; \
	conan profile update settings.compiler.cppstd=17 default;

