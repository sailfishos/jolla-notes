# SPDX-FileCopyrightText: 2013 - 2014 Jolla Ltd.
# SPDX-FileCopyrightText: 2025 Jolla Mobile Ltd
#
# SPDX-License-Identifier: BSD-3-Clause

tests.files = tests/*.qml tests/runtest tests/README
tests.path = /opt/tests/$$TARGET

# The test definition used by testrunner-lite.
definition.files = tests/tests.xml
definition.path = /opt/tests/$$TARGET/test-definition

INSTALLS += tests definition

# For some reason the SDK doesn't upload NotesTestCase.qml without this
OTHER_FILES += tests/*.qml
