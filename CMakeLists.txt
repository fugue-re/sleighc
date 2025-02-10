cmake_minimum_required(VERSION 3.10)
project(sleigh_compiler CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(BISON 3.8 REQUIRED)
find_package(FLEX 2.6 REQUIRED)
find_package(ZLIB 1.2.12 REQUIRED)

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

set(PARSER_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated)
file(MAKE_DIRECTORY ${PARSER_OUTPUT_DIR})

BISON_TARGET(SlghParser src/slghparse.y ${PARSER_OUTPUT_DIR}/slghparse.cc COMPILE_FLAGS "-l -d")
BISON_TARGET(XmlParser src/xml.y ${PARSER_OUTPUT_DIR}/xml.cc COMPILE_FLAGS "-l" DEFINES_FILE ${PARSER_OUTPUT_DIR}/xml.unused.hh)
BISON_TARGET(PcodeParser src/pcodeparse.y ${PARSER_OUTPUT_DIR}/pcodeparse.cc COMPILE_FLAGS "-l" DEFINES_FILE ${PARSER_OUTPUT_DIR}/pcodeparse.unused.hh)

FLEX_TARGET(SlghScanner src/slghscan.l ${PARSER_OUTPUT_DIR}/slghscan.cc COMPILE_FLAGS "-L --nounput")

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DYYDEBUG")

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
  add_compile_options(-Wall -Wno-sign-compare -Wno-unneeded-internal-declaration -Wno-unused-but-set-variable)
endif()

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
