#!/bin/sh -l


# when changing spotbugs versions, edit the 
# SHASUM file with the new filename and hash:
SHASUM=${GITHUB_ACTION_PATH}/shasum-spotbugs.txt

VERSION=$(egrep -o '[0-9]+\.[0-9]+\.[0-9]+' ${SHASUM})
FILENAME=$(awk '{print $2}' ${SHASUM})

SPOTBUGS_HOME=./spotbugs-${VERSION}
SPOTBUGS=${SPOTBUGS_HOME}/bin/spotbugs

sbproject=spotbugs-project.fbp
sbfilter=spotbugs-filter.xml
sbsarif=spotbugs.sarif

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

cp ${GITHUB_ACTION_PATH}/${sbproject} .
cp ${GITHUB_ACTION_PATH}/${sbfilter} .

# print spotbugs configuration
${SPOTBUGS} -textui -project ${sbproject} -exclude ${sbfilter} -printConfiguration

# run analysis
${SPOTBUGS} -textui -project ${sbproject} -exclude ${sbfilter} -sarif > ${sbsarif}

