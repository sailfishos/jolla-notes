Name:       jolla-notes
Summary:    Note-taking application
Version:    0.8.41
Release:    1
Group:      Applications/Editors
License:    TBD
URL:        https://bitbucket.org/jolla/ui-jolla-notes
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Gui)
BuildRequires:  desktop-file-utils
BuildRequires:  pkgconfig(qdeclarative5-boostable)
BuildRequires:  qt5-qttools
BuildRequires:  qt5-qttools-linguist
BuildRequires: pkgconfig(vault-unit) >= 0.1.0
BuildRequires: pkgconfig(qtaround) >= 0.2.0

Requires:  jolla-notes-settings = %{version}
Requires:  ambient-icons-closed
Requires:  sailfishsilica-qt5 >= 0.13.44
Requires:  qt5-qtdeclarative-import-localstorageplugin
Requires:  mapplauncherd-booster-silica-qt5
Requires:  qt5-plugin-sqldriver-sqlite
Requires:  declarative-transferengine-qt5 >= 0.0.34
Requires:  %{name}-all-translations
Requires: vault >= 0.1.0
Requires: qtaround
Requires: sqlite >= 3.0

%description
Note-taking application using Sailfish Silica components

%package ts-devel
Summary: Translation source for %{name}

%description ts-devel
Translation source for %{name}

%package tests
Summary: Automated tests for Jolla Notes
Requires: %{name} = %{version}-%{release}
Requires: qt5-qtdeclarative-import-qttest
Requires: qt5-qtdeclarative-devel-tools
Requires: mce-tools
Requires: testrunner-lite

%description tests
This package installs automated test scripts for jolla-notes,
and a test definition XML file for testrunner-lite.

%package settings
Summary:   Setting page for jolla-notes
License:   TBD
Group:     System/Applications
Requires:  jolla-settings

%description settings
Settings page for jolla-notes

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5 jolla-notes.pro
make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}
%qmake5_install

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/applications/*.desktop
%{_datadir}/jolla-notes/*
%{_libexecdir}/jolla-notes/notes-vault
%{_bindir}/jolla-notes
%{_datadir}/translations/notes_eng_en.qm
%{_datadir}/dbus-1/services/com.jolla.notes.service

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/notes.ts

%files tests
%defattr(-,root,root,-)
/opt/tests/jolla-notes/*

%files settings
%{_libdir}/qt5/qml/com/jolla/notes/settings/*
%{_datadir}/jolla-settings/*

%post
vault -G -a register --data=name=Notes,translation=vault-ap-notes,group=organizer,icon=icon-launcher-notes,script=%{_libexecdir}/jolla-notes/notes-vault || :

%postun
if [ $1 -eq 0 ]; then
vault -G -a unregister --unit=Notes || :
fi
