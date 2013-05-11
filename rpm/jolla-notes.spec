Name:       jolla-notes
Summary:    Note-taking application
Version:    0.5
Release:    1
Group:      Applications/Editors
License:    TBD
URL:        https://bitbucket.org/jolla/ui-jolla-notes
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  pkgconfig(QtCore) >= 4.8.0
BuildRequires:  pkgconfig(QtDeclarative)
BuildRequires:  pkgconfig(QtGui)
BuildRequires:  pkgconfig(QtOpenGL)
BuildRequires:  desktop-file-utils
BuildRequires:  pkgconfig(qdeclarative-boostable)

Requires:  ambient-icons-closed
Requires:  sailfishsilica >= 0.8.33
Requires:  mapplauncherd-booster-jolla

%description
Note-taking application using Sailfish Silica components

%package ts-devel
Summary: Translation source for %{name}

%description ts-devel
Translation source for %{name}

%package tests
Summary: Automated tests for Jolla Notes
Requires: %{name} = %{version}-%{release}
Requires: qtest-qml
Requires: mce-tools
# workaround for a bug in qtchooser.
# when the tests run without this, it can be dropped
Requires: qt-qmake
Requires: meegotouch-compositor-tools

%description tests
This package installs automated test scripts for jolla-notes,
and a test definition XML file for testrunner-lite.

%prep
%setup -q -n %{name}-%{version}

%build
%qmake %{name}.pro PREFIX=/usr
make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}
%qmake_install

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/applications/*.desktop
%{_datadir}/jolla-notes/*
%{_bindir}/jolla-notes
%{_datadir}/translations/notes_eng_en.qm

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/notes.ts

%files tests
%defattr(-,root,root,-)
/opt/tests/jolla-notes/*
