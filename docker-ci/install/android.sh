#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
set -o errexit -o nounset
set -o pipefail

ANDROID_HOME=/opt/android-sdk-linux
ASDKTOOLS_HOME=/opt/android-sdk-tools
ASDKTOOLS_VERSION=3859397
ASDKTOOLS_SHA256=444e22ce8ca0f67353bda4b85175ed3731cae3ffa695ca18119cbacef1c1bea0

ANDROID_NDK_VERSION=25.2.9519653
ANDROID_NDK_MAJOR=25
CMAKE_VERSION=3.22.1
BUILD_TOOLS_VERSION=33.0.2
ANDROID_PLATFORM=33

apt install -qy openjdk-8-jdk maven
arch=$(uname -m)
jre_arch="unknown"
case $arch in
'x86_64')
	jre_arch="amd64"
	;;
'aarch64')
	jre_arch="arm64"
	;;
default)
	echo "Unknown architecture $arch" >&2
	exit 1
	;;
esac
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-$jre_arch/"
if [ ! -f "$JAVA_HOME/bin/java" ]; then
	echo "error: missing openjdk for $jre_arch" >&2
	exit 1
fi

wget -q http://dl.google.com/android/repository/sdk-tools-linux-${ASDKTOOLS_VERSION}.zip -O sdk-tools-linux.zip
echo "${ASDKTOOLS_SHA256} *sdk-tools-linux.zip" | sha256sum --check -
unzip sdk-tools-linux.zip
rm sdk-tools-linux.zip
mv tools "${ASDKTOOLS_HOME}/"
# The following popular fix makes sdkmanager honour $http_proxy variables
mv ${ASDKTOOLS_HOME}/bin/sdkmanager ${ASDKTOOLS_HOME}/bin/sdkmanager-vanilla
cat >${ASDKTOOLS_HOME}/bin/sdkmanager <<"EOF"
#!/bin/sh
if test -n "$http_proxy"; then
  PROXY_HOST=`echo $http_proxy | sed 's@.*//\(.*\):.*@\1@'`
  PROXY_PORT=`echo $http_proxy | sed 's@.*//.*:\(.*\)@\1@'`
  PROXY="--proxy=http --proxy_host=$PROXY_HOST --proxy_port=$PROXY_PORT"
else
  PROXY=""
fi
exec "`dirname $0`/sdkmanager-vanilla" $PROXY "$@"
EOF
for f in ${ASDKTOOLS_HOME}/bin/*; do
	chmod +x "$f"
	ln --symbolic "$f" "/usr/bin/$(basename $f)"
done

cat >/install/package-list-minimal.txt <<EOF
build-tools;26.0.3
build-tools;${BUILD_TOOLS_VERSION}
cmake;${CMAKE_VERSION}
emulator
extras;android;m2repository
extras;google;auto
extras;google;google_play_services
extras;google;instantapps
extras;google;m2repository
extras;google;market_apk_expansion
extras;google;market_licensing
extras;google;simulators
extras;google;webdriver
extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2
extras;m2repository;com;android;support;constraint;constraint-layout-solver;1.0.2
platforms;android-26
platforms;android-${ANDROID_PLATFORM}
tools
ndk;${ANDROID_NDK_VERSION}
EOF

mkdir /root/.android 2>/dev/null || true
touch /root/.android/repositories.cfg
(yes || true) | sdkmanager --licenses --sdk_root="$ANDROID_HOME" || true # NOTE: sdkmanager returns exit code 141
sdkmanager --verbose --package_file=/install/package-list-minimal.txt --sdk_root="$ANDROID_HOME"
test -d "${ANDROID_HOME}/build-tools/${BUILD_TOOLS_VERSION}"
test -d "${ANDROID_HOME}/ndk/${ANDROID_NDK_VERSION}"
for f in ${ANDROID_HOME}/ndk/${ANDROID_NDK_VERSION}/*; do
	ln --symbolic "$f" "/usr/bin/$(basename $f)"
done

echo "export JAVA_HOME=${JAVA_HOME}" >>/android_env_vars.sh
echo "export ANDROID_HOME=${ANDROID_HOME}" >>/android_env_vars.sh
echo "export ANDROID_NDK_HOME=/opt/android-sdk-linux/ndk/${ANDROID_NDK_VERSION}/" >>/android_env_vars.sh
echo "export ANDROID_NDK_VERSION=${ANDROID_NDK_VERSION}" >>/android_env_vars.sh
echo "export ANDROID_NDK_MAJOR=${ANDROID_NDK_MAJOR}" >>/android_env_vars.sh
