cmake_minimum_required(VERSION 3.15)

project(task LANGUAGES CXX VERSION 0.1)

enable_testing()

include(cmake/StandardProjectSettings.cmake)

# link this 'library' to set the c++ standard / compile-time options requested
add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE cxx_std_20)
target_compile_options(project_options INTERFACE -fcoroutines)

find_program(XSLT xsltproc)

function(GenerateHeader HeaderName)
	add_custom_command(
		COMMAND ${XSLT} ${CMAKE_SOURCE_DIR}/xslt/${HeaderName}.xslt /usr/share/vulkan/registry/vk.xml > ${CMAKE_CURRENT_BINARY_DIR}/${HeaderName}.hpp
		OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${HeaderName}.hpp
		DEPENDS ${CMAKE_SOURCE_DIR}/xslt/${HeaderName}.xslt ${CMAKE_SOURCE_DIR}/xslt/common.xslt
		COMMENT "Generating HEADER ${HeaderName}"
		)
endfunction()

function(GenerateHeaders)
	foreach(HeaderName IN LISTS ARGN)
		GenerateHeader(${HeaderName})
	endforeach()
endfunction()
# include(cmake/Conan.cmake)

find_package(Vulkan REQUIRED )
find_package(glfw3 REQUIRED )
find_package(glm REQUIRED )

set(generated creator_traits platform extension handle type)
GenerateHeaders(${generated})

add_library(generated_includes INTERFACE
	${CMAKE_CURRENT_BINARY_DIR}/creator_traits.hpp
	${CMAKE_CURRENT_BINARY_DIR}/platform.hpp
	${CMAKE_CURRENT_BINARY_DIR}/extension.hpp
	${CMAKE_CURRENT_BINARY_DIR}/handle.hpp
	${CMAKE_CURRENT_BINARY_DIR}/type.hpp
)
target_link_libraries(project_options)
target_include_directories(generated_includes INTERFACE ${CMAKE_CURRENT_BINARY_DIR})

add_executable(vulkan_test src/test_main.cxx)

target_link_libraries(vulkan_test PRIVATE 
	project_options
	generated_includes
	Vulkan::Vulkan
	glfw
	glm::glm
	${CMAKE_DL_LIBS}
)

target_include_directories(vulkan_test PRIVATE ./include)
