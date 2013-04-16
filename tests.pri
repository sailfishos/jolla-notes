
tests.files = tests/*.qml tests/*.js
tests.path = /opt/tests/$$TARGET

# The test definition used by testrunner-lite.
# It only contains one case, the one that runs qmltestrunner.
# TODO: figure out how to report per-test results to testrunner-lite.
definition.files = tests/tests.xml
definition.path = /opt/tests/$$TARGET/test-definition

INSTALLS += tests definition

# For some reason the SDK doesn't upload NotesTestCase.qml without this
OTHER_FILES += tests/*.qml
