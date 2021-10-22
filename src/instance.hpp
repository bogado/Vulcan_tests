#ifndef INSTANCE_HPP_INCLUDED
#define INSTANCE_HPP_INCLUDED

#include <array>
#include <optional>
#include <type_traits>
#include <vector>
#include <concepts>
#include <ranges>

#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>

#define VULKAN_HPP_NODISCARD_WARNINGS
#define VULKAN_HPP_RAII_ENABLE_DEFAULT_CONSTRUCTORS
#include <vulkan/vulkan_raii.hpp>

namespace vb {

struct not_found_error : std::runtime_error
{};

template <std::ranges::range RANGE, std::predicate<unsigned, typename std::ranges::range_value_t<RANGE> const &>... PREDICATES_TYPES>
auto index_of(const RANGE& range, PREDICATES_TYPES&&... tests) noexcept
requires (sizeof...(tests) > 0)
{
	auto index = unsigned(0);
	std::find_if(std::begin(range), std::end(range),
		 [&](const auto& value) mutable {
			auto result = (std::invoke(std::forward<PREDICATES_TYPES>(tests), index, value) && ... && true);
			index++;
			return result;
		 });
	return index;
}

template <std::invocable INIT_TYPE, std::invocable DESTROY_TYPE>
struct Managed {
	DESTROY_TYPE& destroy;
	bool engaged = true;

	Managed(INIT_TYPE &init, DESTROY_TYPE& destroy) noexcept
		: destroy(destroy)
	{
		init();
	}

	Managed() = delete;
	Managed(Managed&) = delete;
	Managed(Managed&& other)
		: destroy(other.value())
	{
		engaged = false;
	}

	Managed& operator=(const Managed&) = delete;
	Managed& operator=(Managed&&) = delete;

	~Managed() noexcept
	{
		if (engaged) {
			destroy();
		}
	}
};

template <typename RANGE_TYPE>
concept is_string_collection = requires {
	std::ranges::range<RANGE_TYPE>;
	std::same_as<const char*, std::ranges::range_value_t<RANGE_TYPE>>;
};

template <size_t SIZE>
struct Names : std::array<const char*, SIZE> 
{
	using parent_type = std::array<const char*, SIZE>;

	consteval Names(std::same_as<const char*> auto... names)
		: parent_type{names...}
	{}

	using parent_type::begin;
	using parent_type::end;
	using parent_type::cbegin;
	using parent_type::cend;

	template<size_t SIZE1, size_t SIZE2>
	requires(SIZE1+SIZE2 == SIZE)
	consteval Names(std::array<const char*, SIZE1> first, std::array<const char*, SIZE2> second)
	{
		auto it = std::copy(std::begin(first), std::end(first), begin());
		std::copy(std::begin(second), std::end(second), it);
	}

	template <size_t OTHER_SIZE>
	auto operator+(const Names<OTHER_SIZE>& other)
	{
		return Names(*this, other);
	}

	friend auto operator+(Names const& first, is_string_collection auto const& second)
	{
		auto result = std::vector<const char*>{std::begin(first), std::end(first)};
		std::copy(std::begin(second), std::end(second), std::back_inserter(result));
		return result;
	}
};

template<std::same_as<const char*> ... STRINGS>
Names(STRINGS...) -> Names<sizeof...(STRINGS)>;

struct InstanceManager {
	static inline const auto glfwLibrary = Managed{glfwInit, glfwTerminate};

	vk::ApplicationInfo application;
	vk::raii::Context context;
	vk::raii::Instance instance;
	vk::raii::PhysicalDevice physicalDevice;

	auto surfaceFrom(GLFWwindow* window)
	{
		VkSurfaceKHR surface{};
		if (auto result = vk::Result{glfwCreateWindowSurface(*instance, window, nullptr, &surface)};
			result != vk::Result::eSuccess)
		{
			throw std::runtime_error("Failed to create surface: " + to_string(result));
		}
		return vk::raii::SurfaceKHR(instance, surface);
	}

	template <std::predicate<vk::raii::PhysicalDevice const&>... PREDICATES_TYPES>
	auto const &selectPhysicalDevice(PREDICATES_TYPES &&... device_tests) noexcept
	{
		auto physicalDevices = vk::raii::PhysicalDevices(instance);

		auto result = std::ranges::find_if(physicalDevices, [&](auto const&value) {
			return (std::forward<PREDICATES_TYPES>(device_tests)(value) && ...);
		});
		if (result != std::end(physicalDevices)) {
			physicalDevice = std::move(*result);
		} else {
			physicalDevice = std::move(physicalDevices.front());
		}
		return physicalDevice;
	}

	template <std::predicate<
	    unsigned, vk::QueueFamilyProperties const&>... PREDICATES_TYPES>
	auto build_device(vk::raii::PhysicalDevice const& physicalDevice,
			  is_string_collection auto extensions,
			  PREDICATES_TYPES&&... queueFamilyTests)
	{
	    static constexpr auto priority = float{0.0f};

	    auto deviceQueueCreateInfo = std::array { vk::DeviceQueueCreateInfo()
			.setQueueFamilyIndex(vb::index_of(
				physicalDevice.getQueueFamilyProperties(),
				std::forward<PREDICATES_TYPES>(queueFamilyTests)...))
			 .setQueueCount(1)
			 .setPQueuePriorities(&priority) };
	    auto deviceCreateInfo = vk::DeviceCreateInfo()
			.setPEnabledExtensionNames(extensions)
			.setQueueCreateInfos(deviceQueueCreateInfo);
	    return vk::raii::Device(physicalDevice, deviceCreateInfo);
	}

	InstanceManager(
		const char* name
		, std::uint32_t version
		, const is_string_collection auto& layers
		, const is_string_collection auto& extensions
	) : application(name, version)
		, context()
		, instance(context, vk::InstanceCreateInfo({}, &application, layers, extensions))
	{}

};

}

#endif
