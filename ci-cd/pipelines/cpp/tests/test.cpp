#include "sum.hpp"

#include <cassert>

int main() {
  assert(sum(1, 2) == 3);
  assert(sum(-1, 1) == 0);
  return 0;
}
