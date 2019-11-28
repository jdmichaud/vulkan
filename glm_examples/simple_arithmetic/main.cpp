// Help on glm: http://www.c-jump.com/bcc/common/Talk3/Math/GLM/GLM.html
#include <iostream>
#include <glm/mat4x4.hpp>
#include <glm/vec4.hpp>
#include <glm/gtx/string_cast.hpp>

int main(void) {
  glm::mat4 matrix = glm::mat4({ // use braces here to create an array
    1.0, 0.0, 0.0, 0.0,
    0.0, 1.0, 0.0, 0.0,
    0.0, 0.0, 1.0, 0.0,
    0.0, 0.0, 0.0, 1.0,
  });
  glm::vec4 eye = glm::vec4(2.0, 3.0, 1.0, 1.0);
  // to_string is in defined in the string_cast header
  std::cout << glm::to_string(matrix * eye) << std::endl;

  return 0;
}
