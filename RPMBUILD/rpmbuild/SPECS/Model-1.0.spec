%define realname Model
%define realver 1.0
%define srcext tar.gz
%define inspath  /apps/
%define baseService /usr/lib/systemd/system
%define logrotateDir /etc/logrotate.d

Name:           %{realname}
Version:        %{realver}
Release:        1%{?dist}
Summary:        Model appplication
Group: 		SinoImage
License:        GPL
URL:            http://kenvin.cn
Source0:        Model-1.0.tar.gz
Packager: 	zeasn


%description  
Model is zeasn tomcat application  api .It play
very import role in the web application

%prep
%setup -c

%install
install -d -m755 $RPM_BUILD_ROOT%{inspath}
%__install -d -m755 $RPM_BUILD_ROOT%{baseService}
%__install -d -m755 $RPM_BUILD_ROOT%{logrotateDir}
cp -a %{name}* $RPM_BUILD_ROOT%{inspath}
cp   %{name}/conf/tempfile7 $RPM_BUILD_ROOT%{baseService}/%{name}.service
cp   %{name}/conf/logrotatefile $RPM_BUILD_ROOT%{logrotateDir}/%{name}
sed -i "s/ZeasnTom/%{name}/g"  $RPM_BUILD_ROOT%{baseService}/%{name}.service
sed -i "s/ZeasnTom/%{name}/g"  $RPM_BUILD_ROOT%{logrotateDir}/%{name}

%clean
rm -rf $RPM_BUILD_ROOT
rm -rf $RPM_BUILD_DIR/%{name}

%files
%defattr(-,zeasn,zeasn,-)
/apps/Model
#%attr(0755,zeasn,zeasn) /apps/RECms
%attr(0644,root,root) %{baseService}/%{name}.service
%attr(0644,root,root) %{logrotateDir}/%{name}
