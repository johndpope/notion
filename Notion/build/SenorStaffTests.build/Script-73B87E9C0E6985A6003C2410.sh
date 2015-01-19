#!/bin/sh
# Run the unit tests in this test bundle.
export MallocStackLogging=YES
export MallocScribble=1
export MallocPreScribble=1
export NSDebugEnabled=YES

"${SYSTEM_DEVELOPER_DIR}/Tools/RunUnitTests"


# Run gcov on the framework getting tested
# (If lcov is installed, we'll use that instead, and get pretty html output)

if [ "${CONFIGURATION}" = 'Coverage' ]; then     
	FRAMEWORK_NAME=ProtoNodeGraph
	FRAMEWORK_TARGET=ProtoNodeGraph
# -- useful for building correct path to object files /${CONFIGURATION}/${FRAMEWORK_TARGET}.build
     FRAMEWORK_OBJ_DIR=${OBJROOT}/${FRAMEWORK_NAME}.build/Objects-normal/${NATIVE_ARCH}
	echo "Black Sabbath -"
	echo $FRAMEWORK_OBJ_DIR
#	mkdir -p coverage
#	cd coverage
	
#	if hash lcov 2>/dev/null; then
#		ECHO ${FRAMEWORK_TARGET} STEVE
#		/opt/local/bin/lcov --directory ${FRAMEWORK_OBJ_DIR} --capture --output-file ${FRAMEWORK_TARGET}.info
#		/opt/local/bin/genhtml ${FRAMEWORK_TARGET}.info
#	else
#		echo "***************"
#		echo "lcov is not installed - using gcov instead"
#		echo "***************"
#		find ${OBJROOT} -name *.gcda -exec gcov -o ${FRAMEWORK_OBJ_DIR} {} \;
#	fi
	
     cd ..
fi
