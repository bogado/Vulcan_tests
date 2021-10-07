#include "./instance.hpp"
#include "./window.hpp"

#include <array>
#include <span>
#include <cstdint>
#include <functional>
#include <iterator>
#include <limits>
#include <stdexcept>
#include <type_traits>
#include <utility>
#include <iostream>
#include <memory>
#include <vector>
#include <ranges>
#include <vulkan/vulkan_enums.hpp>

#define VULKAN_HPP_NODISCARD_WARNINGS
#include <vulkan/vulkan_raii.hpp>

#define GLM_FORCE_RADIANS
#define GLM_FORCE_DEPTH_ZERO_TO_ONE
#include <glm/vec4.hpp>
#include <glm/mat4x4.hpp>

constexpr auto WIDTH = 1024u;
constexpr auto HEIGHT = 768u;
auto const     TITLE  = "Test";

auto constexpr layers     = vb::Names { "VK_LAYER_KHRONOS_validation" };
auto constexpr extensions = vb::Names {
    VK_KHR_SURFACE_EXTENSION_NAME,
    VK_EXT_DEBUG_REPORT_EXTENSION_NAME,
    VK_EXT_DEBUG_UTILS_EXTENSION_NAME
};
auto constexpr device_extensions = vb::Names { VK_KHR_SWAPCHAIN_EXTENSION_NAME };

VKAPI_ATTR VkBool32 VKAPI_CALL
debugUtilsMessengerCallback(VkDebugUtilsMessageSeverityFlagBitsEXT messageSeverity,
    VkDebugUtilsMessageTypeFlagsEXT                                messageTypes,
    VkDebugUtilsMessengerCallbackDataEXT const*                    pCallbackData,
    void* /*pUserData*/)
{
#if !defined(NDEBUG)
    if (pCallbackData->messageIdNumber == 648835635) {
        // UNASSIGNED-khronos-Validation-debug-build-warning-message
        return VK_FALSE;
    }
    if (pCallbackData->messageIdNumber == 767975156) {
        // UNASSIGNED-BestPractices-vkCreateInstance-specialuse-extension
        return VK_FALSE;
    }
#endif

    std::cerr << vk::to_string(static_cast<vk::DebugUtilsMessageSeverityFlagBitsEXT>(messageSeverity)) << ": "
              << vk::to_string(static_cast<vk::DebugUtilsMessageTypeFlagsEXT>(messageTypes)) << ":\n";
    std::cerr << "\t"
              << "messageIDName   = <" << pCallbackData->pMessageIdName << ">\n";
    std::cerr << "\t"
              << "messageIdNumber = " << pCallbackData->messageIdNumber << "\n";
    std::cerr << "\t"
              << "message         = <" << pCallbackData->pMessage << ">\n";
    if (0 < pCallbackData->queueLabelCount) {
        std::cerr << "\t"
                  << "Queue Labels:\n";
        for (uint8_t i = 0; i < pCallbackData->queueLabelCount; i++) {
            std::cerr << "\t\t"
                      << "labelName = <" << pCallbackData->pQueueLabels[i].pLabelName << ">\n";
        }
    }
    if (0 < pCallbackData->cmdBufLabelCount) {
        std::cerr << "\t"
                  << "CommandBuffer Labels:\n";
        for (uint8_t i = 0; i < pCallbackData->cmdBufLabelCount; i++) {
            std::cerr << "\t\t"
                      << "labelName = <" << pCallbackData->pCmdBufLabels[i].pLabelName << ">\n";
        }
    }
    if (0 < pCallbackData->objectCount) {
        std::cerr << "\t"
                  << "Objects:\n";
        for (uint8_t i = 0; i < pCallbackData->objectCount; i++) {
            std::cerr << "\t\t"
                      << "Object " << i << "\n";
            std::cerr << "\t\t\t"
                      << "objectType   = "
                      << vk::to_string(static_cast<vk::ObjectType>(pCallbackData->pObjects[i].objectType)) << "\n";
            std::cerr << "\t\t\t"
                      << "objectHandle = " << pCallbackData->pObjects[i].objectHandle << "\n";
            if (pCallbackData->pObjects[i].pObjectName) {
                std::cerr << "\t\t\t"
                          << "objectName   = <" << pCallbackData->pObjects[i].pObjectName << ">\n";
            }
        }
    }
    return VK_TRUE;
}

int main() // NOLINT(bugprone-exception-escape)
{
    auto all_extensions = extensions + std::invoke([]() {
        uint32_t count; // NOLINT(cppcoreguidelines-init-variables)
        auto     glfeExtensions = glfwGetRequiredInstanceExtensions(&count);
        return std::span<const char*> { glfeExtensions, size_t { count } };
    });

    auto debugUtilsMessengerCreateInfo = vk::DebugUtilsMessengerCreateInfoEXT {
        {}, vk::DebugUtilsMessageSeverityFlagBitsEXT::eWarning | vk::DebugUtilsMessageSeverityFlagBitsEXT::eError, vk::DebugUtilsMessageTypeFlagBitsEXT::eGeneral | vk::DebugUtilsMessageTypeFlagBitsEXT::ePerformance | vk::DebugUtilsMessageTypeFlagBitsEXT::eValidation, &debugUtilsMessengerCallback
    };

    //
    auto window           = vb::window(WIDTH, HEIGHT, TITLE);
    auto instancesManager = vb::InstanceManager("Teste", 1, layers, all_extensions);

    vk::raii::DebugUtilsMessengerEXT debugUtilsMessenger(instancesManager.instance, debugUtilsMessengerCreateInfo);

    // Create physicalDevice
    auto const& physicalDevice = instancesManager.selectPhysicalDevice(
        [](vk::raii::PhysicalDevice const& pdev) { return (pdev.getProperties().deviceType == vk::PhysicalDeviceType::eDiscreteGpu); },
        [](vk::raii::PhysicalDevice const& pdev) { return pdev.getFeatures().geometryShader; });

    // Fetch surface
    auto surface = instancesManager.surfaceFrom(window);

    // create device
    auto device = instancesManager.build_device(
        physicalDevice, [](unsigned /* index */, vk::QueueFamilyProperties const& properties) { return bool { properties.queueFlags & vk::QueueFlagBits::eGraphics }; }, [&physicalDevice, &surface](unsigned index, vk::QueueFamilyProperties const& properties) { return physicalDevice.getSurfaceSupportKHR(index, *surface); });

	auto surface_format = std::invoke([&](){
		auto all_surface_format = physicalDevice.getSurfaceFormatsKHR(*surface);
		
        auto wanted = std::ranges::find_if(all_surface_format, [](vk::SurfaceFormatKHR const& surface_format) {
            return surface_format.format == vk::Format::eR8G8B8A8Srgb && surface_format.colorSpace == vk::ColorSpaceKHR::eSrgbNonlinear;
        });
		if (wanted != std::end(all_surface_format)) {
			return *wanted;
		} else {
			return all_surface_format[0];
		}
	});

	std::cout << to_string(surface_format.format) << " / " << to_string(surface_format.colorSpace) << "\n";

    while (window) {
        glfwPollEvents();
    }

    return 0;
}
