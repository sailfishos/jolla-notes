Name:       jolla-notes
Summary:    Note-taking application
Version:    0.8.57
Release:    1
Group:      Applications/Editors
License:    Proprietary
URL:        https://bitbucket.org/jolla/ui-jolla-notes
Source0:    %{name}-%{version}.tar.bz2
Source1:    %{name}.privileges
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Gui)
BuildRequires:  pkgconfig(Qt5DBus)
BuildRequires:  pkgconfig(Qt5Sql)
BuildRequires:  desktop-file-utils
BuildRequires:  pkgconfig(qdeclarative5-boostable)
BuildRequires:  qt5-qttools
BuildRequires:  qt5-qttools-linguist
BuildRequires: pkgconfig(vault)
BuildRequires: pkgconfig(qtaround) >= 0.2.0
BuildRequires: pkgconfig(icu-i18n)
BuildRequires:  oneshot

Requires:  jolla-notes-settings = %{version}
Requires:  ambient-icons-closed
Requires:  sailfishsilica-qt5 >= 1.1.11
Requires:  qt5-qtdeclarative-import-localstorageplugin
Requires:  mapplauncherd >= 4.1.17
Requires:  mapplauncherd-booster-silica-qt5
Requires:  qt5-plugin-sqldriver-sqlite
Requires:  declarative-transferengine-qt5 >= 0.3.1
Requires:  nemo-qml-plugin-configuration-qt5
Requires:  %{name}-all-translations
Requires: vault >= 0.1.0

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
Requires:  jolla-settings

%description settings
Settings page for jolla-notes

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5 jolla-notes.pro
make %{_smp_mflags}

%install
rm -rf %{buildroot}
%qmake5_install

mkdir -p %{buildroot}%{_datadir}/mapplauncherd/privileges.d
install -m 644 -p %{SOURCE1} %{buildroot}%{_datadir}/mapplauncherd/privileges.d/

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/applications/*.desktop
%{_datadir}/jolla-notes
%{_datadir}/mapplauncherd/privileges.d/*
%{_libexecdir}/jolla-notes/notes-vault
# Own com.jolla.notes import
%dir %{_libdir}/qt5/qml/com/jolla/notes
%{_bindir}/jolla-notes
%{_datadir}/translations/*.qm
%{_datadir}/dbus-1/services/com.jolla.notes.service
%{_oneshotdir}/add-jolla-notes-import-default-handler
%dir %{_datadir}/jolla-vault/units
%{_datadir}/jolla-vault/units/Notes.json

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/*.ts

%files tests
%defattr(-,root,root,-)
/opt/tests/jolla-notes

%files settings
%{_libdir}/qt5/qml/com/jolla/notes/settings
%{_datadir}/jolla-settings/entries/*.json
%{_datadir}/jolla-settings/pages/jolla-notes

