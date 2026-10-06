cmake_minimum_required(VERSION 3.10)
project(ghidra CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(BISON 3.8 REQUIRED)
find_package(FLEX 2.6 REQUIRED)
find_package(ZLIB 1.2.12 REQUIRED)

option(BUILD_COMPILER "Build the sleigh compiler executable" ON)
option(BUILD_DECOMPILER "Build the decompiler library" ON)

if (NOT BUILD_DECOMPILER AND NOT BUILD_COMPILER)
  message(FATAL_ERROR "At least one of BUILD_DECOMPILER or BUILD_COMPILER must be ON")
endif()

set(SLEIGH_SOURCES
  src/marshal.cc
  src/space.cc
  src/float.cc
  src/address.cc
  src/pcoderaw.cc
  src/translate.cc
  src/opcodes.cc
  src/globalcontext.cc
  src/sleigh.cc
  src/pcodecompile.cc
  src/sleighbase.cc
  src/slghsymbol.cc
  src/slghpatexpress.cc
  src/slghpattern.cc
  src/slaformat.cc
  src/compression.cc
  src/semantics.cc
  src/context.cc
  src/filemanage.cc
  src/slgh_compile.cc
)

set(DECOMPILER_SOURCES
  src/marshal.cc
  src/space.cc
  src/float.cc
  src/address.cc
  src/pcoderaw.cc
  src/translate.cc
  src/opcodes.cc
  src/globalcontext.cc
  src/capability.cc
  src/architecture.cc
  src/modelrules.cc
  src/options.cc
  src/graph.cc
  src/cover.cc
  src/block.cc
  src/cast.cc
  src/typeop.cc
  src/database.cc
  src/cpool.cc
  src/comment.cc
  src/fspec.cc
  src/action.cc
  src/loadimage.cc
  src/varnode.cc
  src/op.cc
  src/type.cc
  src/variable.cc
  src/varmap.cc
  src/jumptable.cc
  src/emulate.cc
  src/emulateutil.cc
  src/flow.cc
  src/userop.cc
  src/expression.cc
  src/funcdata.cc
  src/funcdata_block.cc
  src/funcdata_varnode.cc
  src/unionresolve.cc
  src/funcdata_op.cc
  src/pcodeinject.cc
  src/heritage.cc
  src/prefersplit.cc
  src/rangeutil.cc
  src/ruleaction.cc
  src/subflow.cc
  src/blockaction.cc
  src/merge.cc
  src/double.cc
  src/coreaction.cc
  src/condexe.cc
  src/override.cc
  src/dynamic.cc
  src/crc32.cc
  src/prettyprint.cc
  src/printlanguage.cc
  src/printc.cc
  src/printjava.cc
  src/memstate.cc
  src/opbehavior.cc
  src/paramid.cc
  src/transform.cc
  src/string_ghidra.cc
  src/stringmanage.cc
  src/signature.cc
  src/sleigh_arch.cc
  src/sleigh.cc
  src/inject_sleigh.cc
  src/filemanage.cc
  src/semantics.cc
  src/slghsymbol.cc
  src/context.cc
  src/sleighbase.cc
  src/slghpatexpress.cc
  src/slghpattern.cc
  src/slaformat.cc
  src/pcodecompile.cc
  src/compression.cc
  src/multiprecision.cc
  src/constseq.cc
  src/bitfield.cc
)

set(PARSER_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated)
file(MAKE_DIRECTORY ${PARSER_OUTPUT_DIR})

BISON_TARGET(SlghParser src/slghparse.y ${PARSER_OUTPUT_DIR}/slghparse.cc COMPILE_FLAGS "-l -d")
BISON_TARGET(XmlParser src/xml.y ${PARSER_OUTPUT_DIR}/xml.cc COMPILE_FLAGS "-l" DEFINES_FILE ${PARSER_OUTPUT_DIR}/xml.unused.hh)
BISON_TARGET(PcodeParser src/pcodeparse.y ${PARSER_OUTPUT_DIR}/pcodeparse.cc COMPILE_FLAGS "-l" DEFINES_FILE ${PARSER_OUTPUT_DIR}/pcodeparse.unused.hh)
BISON_TARGET(GrammarParser src/grammar.y ${PARSER_OUTPUT_DIR}/grammar.cc COMPILE_FLAGS "-l" DEFINES_FILE ${PARSER_OUTPUT_DIR}/grammar.unused.hh)

FLEX_TARGET(SlghScanner src/slghscan.l ${PARSER_OUTPUT_DIR}/slghscan.cc COMPILE_FLAGS "-L --nounput")

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DYYDEBUG")

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  add_compile_options(-Wall -Wno-sign-compare -Wno-unneeded-internal-declaration -Wno-unused-but-set-variable -Wno-mismatched-tags)
endif()

if(BUILD_DECOMPILER)
  add_library(decompiler STATIC
    ${DECOMPILER_SOURCES}
    ${BISON_SlghParser_OUTPUTS}
    ${BISON_XmlParser_OUTPUTS}
    ${BISON_PcodeParser_OUTPUTS}
    ${BISON_GrammarParser_OUTPUTS}
    ${FLEX_SlghScanner_OUTPUTS}
  )

  target_include_directories(decompiler PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${PARSER_OUTPUT_DIR}
  )

  target_compile_definitions(decompiler PRIVATE
    YYDEBUG=1
    YYERROR_VERBOSE
  )

  target_link_libraries(decompiler PUBLIC ZLIB::ZLIB)

  install(TARGETS decompiler
    RUNTIME DESTINATION lib
  )
endif()

if(BUILD_COMPILER)
  add_executable(sleighc
    ${SLEIGH_SOURCES}
    ${BISON_SlghParser_OUTPUTS}
    ${BISON_XmlParser_OUTPUTS}
    ${BISON_PcodeParser_OUTPUTS}
    ${FLEX_SlghScanner_OUTPUTS}
  )

  target_link_libraries(sleighc PRIVATE ZLIB::ZLIB)

  target_include_directories(sleighc PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${PARSER_OUTPUT_DIR}
  )

  target_compile_definitions(sleighc PRIVATE
    YYDEBUG=1
    YYERROR_VERBOSE
  )

  install(TARGETS sleighc
    RUNTIME DESTINATION bin
  )
endif()
