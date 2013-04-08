# Caller must have set PREFIX

TS_FILE = $$OUT_PWD/notes.ts
EE_QM = $$OUT_PWD/notes_eng_en.qm

ts.commands += lupdate $$PWD -ts $$TS_FILE
ts.output = $$TS_FILE
ts.input = .

ts_install.files = $$TS_FILE
ts_install.path = $$PREFIX/share/translations/source
ts_install.CONFIG += no_check_exist

engineering_english.commands += lrelease -idbased $$TS_FILE -qm $$EE_QM
engineering_english.depends = ts
engineering_english.input = $$TS_FILE
engineering_english.output = $$EE_QM

TRANSLATIONS_PATH = $$PREFIX/share/translations
engineering_english_install.path = $$TRANSLATIONS_PATH
engineering_english_install.files = $$EE_QM
engineering_english_install.CONFIG += no_check_exist

QMAKE_EXTRA_TARGETS += ts engineering_english
PRE_TARGETDEPS += ts engineering_english
DEFINES += TRANSLATIONS_PATH=\"\\\"\"$${TRANSLATIONS_PATH}\"\\\"\"

INSTALLS += ts_install engineering_english_install
