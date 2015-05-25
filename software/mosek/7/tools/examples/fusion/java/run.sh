#!/bin/bash

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
  PLATFORM=../../../platform/solaris64x86
elif [ -e ../../../platform/solaris64x86 ]; then
  PLATFORM=../../../platform/solaris64x86
fi

echo java -classpath "$PLATFORM/bin/mosek.jar:examples.jar"
java -classpath "$PLATFORM/bin/mosek.jar:examples.jar" com.mosek.fusion.examples.$1

