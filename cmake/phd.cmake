include(FetchContent)
set(VENDOR_DIR ${CMAKE_SOURCE_DIR}/vendor CACHE FILEPATH "Path to store third-party source")
set(VENDOR_BUILD_BASE_DIR ${CMAKE_CURRENT_BINARY_DIR}/_deps CACHE FILEPATH "Path to store third-party builds")

FetchContent_Declare(
    phd
    SOURCE_DIR ${VENDOR_DIR}/phd
    SUBBUILD_DIR ${VENDOR_BUILD_BASE_DIR}/phd_subbuild
    BINARY_DIR ${VENDOR_BUILD_BASE_DIR}/phd_bin
    GIT_REPOSITORY https://github.com/bogado/phd
    GIT_TAG master
)

FetchContent_MakeAvailable(phd)
