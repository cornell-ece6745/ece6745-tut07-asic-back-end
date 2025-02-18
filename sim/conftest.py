#=========================================================================
# conftest
#=========================================================================

import pytest
import random

@pytest.fixture(autouse=True)
def fix_randseed():
  """Set the random seed prior to each test case."""
  random.seed(0xdeadbeef)

