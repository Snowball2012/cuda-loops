
cmake_minimum_required(VERSION 2.8.4)
project(diploma_prototype)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

#set some internal variables
set(LLVMCOMPONENTS "cppbackend")
set(RTTIFLAG "-fno-rtti")
set(LLVMCONFIG "llvm-config")
execute_process(COMMAND "${LLVMCONFIG} --src-root"
                 OUTPUT_VARIABLE LLVMSRCROOT)
execute_process(COMMAND "${LLVMCONFIG} --obj-root"
                 OUTPUT_VARIABLE LLVMOBJROOT)
execute_process(COMMAND "${LLVMCONFIG} --cxxflags"
                 OUTPUT_VARIABLE LLVMCXXFLAGS)
execute_process(COMMAND "${LLVMCONFIG} --ldflags --libs ${LLVMCOMPONENTS}"
                 OUTPUT_VARIABLE LLVMLDFLAGS)
execute_process(COMMAND "${LLVMCONFIG} --libdir"
                 OUTPUT_VARIABLE LLVMLIBDIR)
execute_process(COMMAND "${LLVMCONFIG} --includedir"
                 OUTPUT_VARIABLE LLVMINCLUDEDIR)
execute_process(COMMAND "${LLVMCONFIG} --libs"
                 OUTPUT_VARIABLE LLVMLIBS)
execute_process(COMMAND "${LLVMCONFIG} --system-libs"
                 OUTPUT_VARIABLE LLVMSYSLIBS)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -I${LLVMSRCROOT}/tools/clang/include -I${LLVMOBJROOT}/tools/clang/include ${LLVMCXXFLAGS} ${RTTIFLAG} -D__STDC_CONSTANT_MACROS -D__STDC_LIMIT_MACROS")

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LLVMLDFLAGS} -ltinfo")

set(SOURCE_FILES src/main.cpp src/PragmaHandling.cpp src/dvm/pragmas.cpp src/MDLoopInfo.cpp)
add_executable(diploma_prototype ${SOURCE_FILES} src/handler-gen/NoAcrossGen.cpp src/handler-gen/NoAcrossGen.h src/handler-gen/AcrossGen.cpp src/handler-gen/AcrossGen.h)


#set include dirs
include_directories(${LLVMINCLUDEDIR})
include_directories(src/)

#link libraries
link_directories(${LLVMLIBDIR})


target_link_libraries(diploma_prototype clangTooling
                                         	clangFrontendTool
                                         	clangFrontend
                                         	clangDriver
                                         	clangSerialization
                                         	clangCodeGen
                                         	clangParse
                                         	clangSema
                                         	clangStaticAnalyzerFrontend
                                         	clangStaticAnalyzerCheckers
                                         	clangStaticAnalyzerCore
                                         	clangAnalysis
                                         	clangARCMigrate
                                         	clangRewriteFrontend
                                         	clangRewriteCore
                                         	clangEdit
                                         	clangAST
                                         	clangLex
                                         	clangBasic
                                         	${LLVMLIBS}
                                         	${LLVMSYSLIBS})



target_link_libraries(diploma_prototype
  LLVMX86AsmParser # MC, MCParser, Support, X86Desc, X86Info
  LLVMX86Desc # MC, Support, X86AsmPrinter, X86Info
  LLVMX86AsmPrinter # MC, Support, X86Utils
  LLVMX86Info # MC, Support, Target
  LLVMX86Utils # Core, Support
  LLVMipo
  LLVMScalarOpts
  LLVMInstCombine
  LLVMTransformUtils
  LLVMipa
  LLVMAnalysis
  LLVMTarget
  LLVMOption # Support
  LLVMMCParser # MC, Support
  LLVMMC # Object, Support
  LLVMObject # BitReader, Core, Support
  LLVMBitReader # Core, Support
  LLVMCore # Support
  LLVMSupport
  pthread
  z
  dl
  tinfo
)





