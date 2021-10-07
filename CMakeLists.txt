cmake_minimum_required(VERSION 3.15)

project(task LANGUAGES CXX VERSION 0.1)

enable_testing()

include(cmake/StandardProjectSettings.cmake)

# link this 'library' to set the c++ standard / compile-time options requested
add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE cxx_std_20)
target_compile_options(project_options INTERFACE -fcoroutines)

# include(cmake/Conan.cmake)

find_package(Vulkan REQUIRED )
find_package(glfw3 REQUIRED )
find_package(glm REQUIRED )

add_executable(vulkan_test src/test_main.cxx)

target_link_libraries(vulkan_test PRIVATE 
	project_options
	Vulkan::Vulkan
	glfw
	glm::glm
	${CMAKE_DL_LIBS}
)

target_include_directories(vulkan_test PRIVATE ./include)
