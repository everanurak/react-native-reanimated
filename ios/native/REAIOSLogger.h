#pragma once

#include <stdio.h>
#include "ReanimatedHiddenHeaders.h"

namespace reanimated {

class REAIOSLogger : public LoggerInterface {
 public:
  void log(const char *str) override;
  void log(double d) override;
  void log(int i) override;
  void log(bool b) override;
  virtual ~REAIOSLogger() {}
};

} // namespace reanimated
