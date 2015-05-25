#!/bin/bash

# Build all examples into one .jar file.`

EXAMPDIR=$(dirname $0)

if   [ -e ../../../platform/osx32x86 ]; then
  PLATFORM=../../../platform/osx32x86
elif [ -e ../../../platform/osx64x86 ]; then
  PLATFORM=../../../platform/osx64x86
elif [ -e ../../../platform/linux32x86 ]; then
  PLATFORM=../../../platform/linux32x86
elif [ -e ../../../platform/linux64x86 ]; then
  PLATFORM=../../../platform/linux64x86
elif [ -e ../../../platform/win32x86 ]; then
  PLATFORM=../../../platform/win32x86
elif [ -e ../../../platform/win64x86 ]; then
  PLATFORM=../../../platform/win64x86
elif [ -e ../../../platform/solaris32x86 ]; then
  PLATFORM=../../../platform/solaris32x86
elif [ -e ../../../platform/solaris64x86 ]; then
  PLATFORM=../../../platform/solari642x86
fi


echo javac -classpath "$PLATFORM/bin/mosek.jar" -d . $EXAMPDIR/*.java && \
javac -classpath "$PLATFORM/bin/mosek.jar" -d . $EXAMPDIR/*.java && \
echo jar cvf ./examples.jar com/mosek/fusion/examples/* && \
jar cvf ./examples.jar com/mosek/fusion/examples/* && \
echo "Successfully built $(pwd)/examples.jar"
