# for compilation define exactly one of the following three variables:
# SEDOV_SYNC_POS_VEL_NONE
# SEDOV_SYNC_POS_VEL_EARLY
# SEDOV_SYNC_POS_VEL_LATE
SYNCFLAG = -define SEDOV_SYNC_POS_VEL_EARLY

X10FLAG = -v -J-Xmx1500M -O3 -VERBOSE_CHECKS -g -report postcompile=1 ${SYNCFLAG}
ifdef NO_CHECKS
    X10FLAG += -NO_CHECKS
endif

X10RTIMPL ?=  # sockets, mpi, pami, etc.
ifdef X10RTIMPL
  X10FLAG += -x10rt ${X10RTIMPL}
endif

# enable CPU profiling with google-perftools
PROFILE ?=
ifdef PROFILE
  X10FLAG += -gpt
endif

RECORD_LOOP_TIMES ?=
ifdef RECORD_LOOP_TIMES
  X10FLAG += -define __RECORD_LOOP_TIMES__
endif

BINDIR = bin
ManagedX10BIN = ${BINDIR}/Lulesh2.0.jar
NativeX10BIN = ${BINDIR}/lulesh2.0

SRCPATH = src
DOCPATH = x10doc

APPFLAG =  -s 20

default:	run-cpp

build:	${NativeX10BIN} ${ManagedX10BIN}

run:	run-cpp run-java 

${ManagedX10BIN}:	${SRCPATH}/*.x10
	x10c ${X10FLAG} -o ${ManagedX10BIN} ${SRCPATH}/Lulesh.x10

${NativeX10BIN}:	${SRCPATH}/*.x10
	x10c++ ${X10FLAG} -o ${NativeX10BIN} -d ${BINDIR} ${SRCPATH}/Lulesh.x10

kernel:	${SRCPATH}/*.x10
	x10c++ ${X10FLAG} -o kernel -d ${BINDIR} ${SRCPATH}/LuleshKernel.x10

run-java:	${ManagedX10BIN}
	x10 -cp ${ManagedX10BIN} Lulesh ${APPFLAG}

run-cpp:	${NativeX10BIN}
	${NativeX10BIN} ${APPFLAG}

run-poe:	${NativeX10BIN}
	poe ${NativeX10BIN} ${APPFLAG}

run-mpi:	${NativeX10BIN}
	mpiexec -n 8 -env X10_NTHREADS 1 ${NativeX10BIN} -s 10

DOCSRC=$(shell find ${SRCPATH} -type f -iname '*.x10')

doc		: ${DOCSRC}
		x10doc -d ${DOCPATH} $^

.PHONY: clean
clean:
	rm -rf ${ManagedX10BIN} ${NativeX10BIN} ${BINDIR} ${DOCPATH} 
