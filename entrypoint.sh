#!/bin/sh -l


# when changing spotbugs versions, edit the 
# SHASUM file with the new filename and hash:
SHASUM=${GITHUB_ACTION_PATH}/shasum-spotbugs.txt

VERSION=$(egrep -o '[0-9]+\.[0-9]+\.[0-9]+' ${SHASUM})
FILENAME=$(awk '{print $2}' ${SHASUM})

SPOTBUGS_HOME=./spotbugs-${VERSION}
SPOTBUGS=${SPOTBUGS_HOME}/bin/spotbugs

URL=https://github.com/spotbugs/spotbugs/releases/download/${VERSION}/${FILENAME}

echo ---
echo ${FILENAME}
if [ ! -e ${FILENAME} ]; then
    wget -nv ${URL}
    if ! sha256sum -c ${SHASUM}; then
        exit 1
    fi
    tar xf ${FILENAME}
    chmod +x ${SPOTBUGS}
fi

SHASUM=${GITHUB_ACTION_PATH}/shasum-find-sec-bugs.txt

VERSION=$(egrep -o '[0-9]+\.[0-9]+\.[0-9]+' ${SHASUM})
FILENAME=$(awk '{print $2}' ${SHASUM})
URL=https://repo1.maven.org/maven2/com/h3xstream/findsecbugs/findsecbugs-plugin/${VERSION}/${FILENAME}
echo ---
echo ${FILENAME}
if [ ! -e ${FILENAME} ]; then
    wget -nv ${URL}
    if ! sha256sum -c ${SHASUM}; then
        exit 1
    fi
    cp ${FILENAME} ${SPOTBUGS_HOME}/plugin
fi

cp ${GITHUB_ACTION_PATH}/dsp-appsec-poc-security-tools.fbp .
cp ${GITHUB_ACTION_PATH}/dsp-appsec-poc-security-tools-filter.xml .

# print spotbugs configuration
${SPOTBUGS} -textui \
    -project dsp-appsec-poc-security-tools.fbp \
    -exclude dsp-appsec-poc-security-tools-filter.xml \
    -printConfiguration

# run analysis
${SPOTBUGS} -textui \
    -project dsp-appsec-poc-security-tools.fbp \
    -exclude dsp-appsec-poc-security-tools-filter.xml
