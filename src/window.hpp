#ifndef WINDOW_HPP_INCLUDED
#define WINDOW_HPP_INCLUDED

#include <concepts>

#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>

namespace vb {

struct window {
	struct hints {
		hints()
		{
			glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
			glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);
		}
	} glfw_hints;

	std::unique_ptr<GLFWwindow, void(&)(GLFWwindow*)> glfw_window;

	window(std::unsigned_integral auto width, std::unsigned_integral auto height, const std::string name) :
		glfw_hints(),
		glfw_window(glfwCreateWindow(uint32_t{width}, uint32_t{height}, name.c_str(), nullptr, nullptr), glfwDestroyWindow)
	{}

	operator const GLFWwindow*() const {
		return glfw_window.get();
	}

	operator GLFWwindow*() {
		return glfw_window.get();
	}

	GLFWwindow* operator->() {
		return glfw_window.get();
	}

	operator bool() {
		return !glfwWindowShouldClose(glfw_window.get());
	}
};

}

#endif
