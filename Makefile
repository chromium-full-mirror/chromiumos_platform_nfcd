# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

include common.mk

BASE_VER ?= 180609
PKG_CONFIG ?= pkg-config

CXXFLAGS += -I$(SRC)/..

DBUS_DEPS = dbus-1 dbus-glib-1
DBUS_FLAGS := $(shell $(PKG_CONFIG) --cflags $(DBUS_DEPS))
DBUS_LIBS := $(shell $(PKG_CONFIG) --libs $(DBUS_DEPS))

GLIB_DEPS = glib-2.0 gobject-2.0 libchrome-$(BASE_VER) libchromeos-$(BASE_VER)
GLIB_FLAGS := $(shell $(PKG_CONFIG) --cflags $(GLIB_DEPS))
GLIB_LIBS := $(shell $(PKG_CONFIG) --libs $(GLIB_DEPS))

LIBNFC_DEPS = libnfc
LIBNFC_FLAGS := $(shell $(PKG_CONFIG) --cflags $(LIBNFC_DEPS))
LIBNFC_LIBS := $(shell $(PKG_CONFIG) --libs $(LIBNFC_DEPS))

COMMON_OBJS = \
  nfcd.o

# --------------------------------------------------------------------
# The daemon binary
# --------------------------------------------------------------------
NFCD_OBJS = \
  nfcd_main.o

NFCD_FLAGS = $(DBUS_FLAGS) $(GLIB_FLAGS) $(LIBNFC_FLAGS)
NFCD_LIBS = $(DBUS_LIBS) $(GLIB_LIBS) $(LIBNFC_LIBS) -lgflags
CXX_BINARY(nfcd): CXXFLAGS += $(NFCD_FLAGS)
CXX_BINARY(nfcd): LDLIBS += $(NFCD_LIBS)
CXX_BINARY(nfcd): \
  $(COMMON_OBJS) \
  $(NFCD_OBJS)
clean: CLEAN(nfcd)


# --------------------------------------------------------------------
# The test binary
# --------------------------------------------------------------------
NFCD_UNITTEST_FLAGS = $(NFCD_FLAGS)
TEST_LIBS := $(shell gmock-config --libs) $(shell gtest-config --libs)
NFCD_UNITTEST_LIBS = $(NFCD_LIBS) $(TEST_LIBS)

TEST_OBJS = \
  nfcd_unittest.o
CXX_BINARY(nfcd_unittest): \
  CXXFLAGS += $(NFCD_UNITTEST_FLAGS)
CXX_BINARY(nfcd_unittest): \
  LDLIBS += $(NFCD_UNITTEST_LIBS)
CXX_BINARY(nfcd_unittest): \
  $(COMMON_OBJS) \
  $(TEST_OBJS)
clean: CLEAN(nfcd_unittest)
tests: TEST(CXX_BINARY(nfcd_unittest))


# --------------------------------------------------------------------
# ALL rules
# --------------------------------------------------------------------
all: CXX_BINARY(nfcd) CXX_BINARY(nfcd_unittest)

ALL_OBJS = \
  $(COMMON_OBJS) \
  $(NFCD_OBJS) \
  $(TEST_OBJS)

