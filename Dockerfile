FROM gradle:5.4.1-jdk8

RUN echo %PATH%
RUN gradle -v
RUN java -version
RUN echo %JAVA_HOME%
RUN echo %GRADLE_HOME%
RUN echo %KOTLIN_HOME%

# download and install Android SDK
# https://developer.android.com/studio/#downloads
ARG ANDROID_SDK_VERSION=4333796
ENV ANDROID_HOME /opt/android-sdk
RUN mkdir -p ${ANDROID_HOME} && cd ${ANDROID_HOME} && \
    wget https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_VERSION}.zip && \
    unzip sdk-tools-linux-${ANDROID_SDK_VERSION}.zip && \
    rm sdk-tools-linux-${ANDROID_SDK_VERSION}.zip

# set the environment variables
# ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
# ENV GRADLE_HOME /opt/gradle
# ENV KOTLIN_HOME /opt/kotlinc
# ENV PATH ${PATH}:${GRADLE_HOME}/bin:${KOTLIN_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin
# ENV _JAVA_OPTIONS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
# WORKAROUND: for issue https://issuetracker.google.com/issues/37137213
# ENV LD_LIBRARY_PATH ${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib

# Install Android SDK Packages
# https://developer.android.com/studio/command-line/sdkmanager.html
# accept the license agreements of the SDK components
ADD license_accepter.sh /opt/
RUN chmod +x /opt/license_accepter.sh && /opt/license_accepter.sh $ANDROID_HOME

ARG ANDROID_SDK_PACKAGES="build-tools;28.0.3 platforms;android-28 platform-tools"
RUN ${ANDROID_HOME}/tools/bin/sdkmanager ${ANDROID_SDK_PACKAGES}

ENV PATH $PATH:$ANDROID_HOME/platform-tools

# setup adb server
# EXPOSE 5037

RUN adb version

RUN apt-get update
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y apt-utils
RUN apt-get install -y ruby-full
RUN ruby -v
RUN gem -v

RUN apt-get install -y make gcc
RUN make -v
RUN gcc -v

RUN gem install dryrun

CMD ["bash"]
