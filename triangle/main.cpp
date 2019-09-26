#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>

#include <string.h>

#include <iostream>
#include <stdexcept>
#include <functional>
#include <cstdlib>
#include <algorithm>

#define WIDTH 800
#define HEIGHT 600

const std::vector<const char*> validationLayers = {
    "VK_LAYER_KHRONOS_validation"
};

#ifdef NDEBUG
  const bool enableValidationLayers = false;
#else
  const bool enableValidationLayers = true;
#endif

/**
 * Prints debug message from the Vulkan layers.
 * Uses the VK_EXT_DEBUG_UTILS_EXTENSION_NAME extension enabled when NDEBUG is not defined.
 */
static VKAPI_ATTR VkBool32 VKAPI_CALL debugCallback(VkDebugUtilsMessageSeverityFlagBitsEXT messageSeverity,
                                                    VkDebugUtilsMessageTypeFlagsEXT messageType,
                                                    const VkDebugUtilsMessengerCallbackDataEXT* pCallbackData,
                                                    void* pUserData) {
  std::cerr << "validation layer: " << pCallbackData->pMessage << std::endl;
  // Return VK_TRUE to abort the call.
  return VK_FALSE;
}

/**
 * We need vkCreateDebugUtilsMessengerEXT to register the debugCallback. But this
 * function shall be loaded dynamically because it is an extension function.
 */
VkResult CreateDebugUtilsMessengerEXT(VkInstance instance, const VkDebugUtilsMessengerCreateInfoEXT* pCreateInfo, const VkAllocationCallbacks* pAllocator, VkDebugUtilsMessengerEXT* pDebugMessenger) {
  auto func = (PFN_vkCreateDebugUtilsMessengerEXT) vkGetInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT");
  if (func != nullptr) {
    return func(instance, pCreateInfo, pAllocator, pDebugMessenger);
  } else {
    return VK_ERROR_EXTENSION_NOT_PRESENT;
  }
}

/**
 * Fetches the function that destroys the object created by vkCreateDebugUtilsMessengerEXT
 */
void DestroyDebugUtilsMessengerEXT(VkInstance instance, VkDebugUtilsMessengerEXT debugMessenger, const VkAllocationCallbacks* pAllocator) {
  auto func = (PFN_vkDestroyDebugUtilsMessengerEXT) vkGetInstanceProcAddr(instance, "vkDestroyDebugUtilsMessengerEXT");
  if (func != nullptr) {
    func(instance, debugMessenger, pAllocator);
  }
}

class HelloTriangleApplication {
public:
  void run() {
    initWindow();
    initVulkan();
    mainLoop();
    cleanup();
  }

private:
  void initWindow() {
    glfwInit();
    // Do not create an OpenGL context
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    // Do not handle resize
    glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);
    // Create the window
    this->m_window = glfwCreateWindow(WIDTH, HEIGHT, "Vulkan", nullptr, nullptr);
  }

  void initVulkan() {
    this->createInstance();
    this->setupDebugMessenger();
  }

  void mainLoop() {
    while (!glfwWindowShouldClose(this->m_window)) {
      glfwPollEvents();
    }
  }

  void cleanup() {
    if (enableValidationLayers) {
      // DestroyDebugUtilsMessengerEXT(this->m_instance, this->m_debugMessenger, nullptr);
    }
    vkDestroyInstance(this->m_instance, nullptr);
    glfwDestroyWindow(this->m_window);
    glfwTerminate();
  }

  void createInstance() {
    if (enableValidationLayers && !this->checkValidationLayerSupport()) {
      throw std::runtime_error("validation layers requested, but not available!");
    }
    // This structure is optional
    VkApplicationInfo appInfo = {};
    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pNext = nullptr;
    appInfo.pApplicationName = "Hello Triangle";
    appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.pEngineName = "No Engine";
    appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.apiVersion = VK_API_VERSION_1_0;
    // This one is mandatory
    VkInstanceCreateInfo createInfo = {};
    createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    createInfo.pNext = nullptr;
    createInfo.pApplicationInfo = &appInfo;
    // Provide the data to the createInfo structure
    auto extensions = this->getRequiredExtensions();
    createInfo.enabledExtensionCount = static_cast<uint32_t>(extensions.size());
    createInfo.ppEnabledExtensionNames = extensions.data();
    // No validation layer for now
    if (enableValidationLayers) {
      std::cout << "running in debug mode" << std::endl;
      createInfo.enabledLayerCount = static_cast<uint32_t>(validationLayers.size());
      createInfo.ppEnabledLayerNames = validationLayers.data();
    } else {
      createInfo.enabledLayerCount = 0;
    }
    // Create the instance
    if (vkCreateInstance(&createInfo, nullptr, &this->m_instance) != VK_SUCCESS) {
      throw std::runtime_error("failed to create instance!");
    }
  }

  // Check that all the validation layers in validationLayers are available.
  bool checkValidationLayerSupport() {
    uint32_t layerCount = 0;

    vkEnumerateInstanceLayerProperties(&layerCount, nullptr);
    std::vector<VkLayerProperties> layerProperties(layerCount);
    vkEnumerateInstanceLayerProperties(&layerCount, layerProperties.data());

    return std::all_of(
      validationLayers.begin(), validationLayers.end(),
      [layerProperties](const char *layer) {
        return std::find_if(layerProperties.begin(), layerProperties.end(), [layer](VkLayerProperties layerProperty) {
          return strcmp(layer, layerProperty.layerName) == 0;
        }) != layerProperties.end();
      }
    );
  }

  /**
   * Ask glfw all the extensions that it needs from Vulkan and merge those with
   * some others.
   */
  std::vector<const char*> getRequiredExtensions() {
    // Ask GLW directly which Vulkan extension it will need
    uint32_t glfwExtensionCount = 0;
    const char** glfwExtensions;
    glfwExtensions = glfwGetRequiredInstanceExtensions(&glfwExtensionCount);

    std::vector<const char*> extensions(glfwExtensions, glfwExtensions + glfwExtensionCount);
    // If we enabled the validation layer, then also add the debug extension to print callback messages
    if (enableValidationLayers) {
      extensions.push_back(VK_EXT_DEBUG_UTILS_EXTENSION_NAME);
    }
    return extensions;
  }

  /**
   * Register debugCallback as a debug message handler.
   */
  void setupDebugMessenger() {
    if (!enableValidationLayers) return;

    VkDebugUtilsMessengerCreateInfoEXT createInfo = {};
    createInfo.sType = VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
    createInfo.messageSeverity = VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT;
    createInfo.messageType = VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT | VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;
    createInfo.pfnUserCallback = debugCallback;
    createInfo.pUserData = nullptr; // Optional

    if (CreateDebugUtilsMessengerEXT(this->m_instance, &createInfo, nullptr, &(this->m_debugMessenger)) != VK_SUCCESS) {
      throw std::runtime_error("failed to set up debug messenger!");
    }
  }

private:
  GLFWwindow* m_window;
  VkInstance m_instance;
  // To register debugCallback
  VkDebugUtilsMessengerEXT m_debugMessenger;
};

int main() {
  HelloTriangleApplication app;

  try {
    app.run();
  } catch (const std::exception& e) {
    std::cerr << e.what() << std::endl;
    return EXIT_FAILURE;
  }

  return EXIT_SUCCESS;
}
