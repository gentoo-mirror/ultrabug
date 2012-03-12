# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
PYTHON_DEPEND="python? 2:2.4:2.7 3:3.1:3.2"
PYTHON_MODNAME="uwsgidecorators"
SUPPORT_PYTHON_ABIS="1"
USE_RUBY="ruby18 ree18 ruby19"
RUBY_OPTIONAL="yes"

MY_P="${P/_/-}"

inherit apache-module python multilib ruby-ng

DESCRIPTION="uWSGI server for Python web applications"
HOMEPAGE="http://projects.unbit.it/uwsgi/"
SRC_URI="http://projects.unbit.it/downloads/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="apache2 +caps +carbon debug json ldap lua +nagios perl +pcre python rrdtool rsyslog ruby spooler sqlite syslog +uuid +xml yaml zeromq"
REQUIRED_USE="|| ( lua perl python ruby )"

CDEPEND="caps? ( sys-libs/libcap )
	json? ( dev-libs/jansson )
	ldap? ( net-nds/openldap )
	lua? ( dev-lang/lua )
	pcre? ( dev-libs/libpcre )
	perl? ( dev-lang/perl )
	ruby? ( $(ruby_implementations_depend) )
	sqlite? ( dev-db/sqlite:3 )
	rsyslog? ( app-admin/rsyslog )
	uuid? ( sys-apps/util-linux )
	xml? ( dev-libs/libxml2 )
	yaml? ( dev-libs/libyaml )
	zeromq? ( net-libs/zeromq )"
DEPEND="${CDEPEND}
	dev-util/pkgconfig"
RDEPEND="${CDEPEND}
	rrdtool? ( net-analyzer/rrdtool )"

S="${WORKDIR}/${MY_P}"
APXS2_S="${S}/apache2"
APACHE2_MOD_CONF="42_mod_${PN}"

want_apache2_2

use_true_false() {
	if use $1 ; then
		echo "true"
	else
		echo "false"
	fi
}

src_unpack() {
	default
}

pkg_setup() {
	depend.apache_pkg_setup
	python_pkg_setup
}

src_prepare() {
	sed -i \
		-e "s|'-O2', ||" \
		-e "s|'-Werror', ||" \
		-e "s|uc.get('plugin_dir')|uc.get('plugin_build_dir')|" \
		uwsgiconfig.py || die "sed failed"

	sed -i \
		-e 's|python\([0-9].[0-9]\)-config|python-config-\1|' \
		plugins/python/uwsgiplugin.py || die "sed failed"
}

src_configure() {
	local plugins=""
	use carbon && plugins+=", carbon"
	use nagios && plugins+=", nagios"
	use rrdtool && plugins+=", rrdtool"
	use rsyslog && plugins+=", rsyslog"
	use syslog && plugins+=", syslog"

	cat > "buildconf/gentoo.ini" << EOF
[uwsgi]
xml = $(use_true_false xml)
ini = true
yaml = $(use_true_false yaml)
json = $(use_true_false json)
sqlite3 = $(use_true_false sqlite)
zeromq = $(use_true_false zeromq)
snmp = true
sctp = false
spooler = true
embedded = true
udp = true
multicast = true
threading = true
sendfile = true
minterpreters = true
async = true
evdis = false
ldap = $(use_true_false ldap)
pcre = $(use_true_false pcre)
debug = $(use_true_false debug)
unbit = false
xml_implementation = libxml2
yaml_implementation = libyaml
malloc_implementation = libc
plugins =
bin_name = uwsgi
append_version =
plugin_dir = /usr/$(get_libdir)/uwsgi
plugin_build_dir = ${T}/plugins
embedded_plugins =  ping, cache, rpc, fastrouter, http, ugreen, signal, logsocket, ${plugins:1}
as_shared_library = false

locking = auto
event = auto
timer = auto
filemonitor = auto

embed_files = 

embed_config =
[python]
paste = true
web3 = true
EOF
	use caps || sed -i -e 's|sys/capability.h|DISABLED|' uwsgiconfig.py || die "sed failed"
	use uuid || sed -i -e 's|uuid/uuid.h|DISABLED|' uwsgiconfig.py || die "sed failed"
}

each_ruby_compile() {
	cd "${WORKDIR}/${MY_P}"

	sed -i -e "s|^NAME=.*|NAME='rack_${RUBY##*/}'|" plugins/rack/uwsgiplugin.py || die "sed failed"
	UWSGICONFIG_RUBYPATH="${RUBY}" python uwsgiconfig.py --plugin plugins/rack gentoo || die "building plugin for ${RUBY} failed"

	if [[ "${RUBY}" == *ruby19 ]] ; then
		UWSGICONFIG_RUBYPATH="${RUBY}" python uwsgiconfig.py --plugin plugins/ruby19 gentoo || die "building plugin for ${RUBY} failed"
	fi
}

install_python_lib() {
	insinto $(python_get_sitedir)
	doins uwsgidecorators.py
}

src_compile() {
	python uwsgiconfig.py --build gentoo || die "building uwsgi failed"

	mkdir -p "${T}/plugins"

	if use lua ; then
		python uwsgiconfig.py --plugin plugins/lua gentoo || die "building plugin for lua failed"
	fi

	if use perl ; then
		python uwsgiconfig.py --plugin plugins/psgi gentoo || die "building plugin for perl failed"
	fi

	if use python ; then
		for a in ${PYTHON_ABIS} ; do
			python${a} uwsgiconfig.py --plugin plugins/python gentoo python${a/.} || die "building plugin for python-${a} failed"
		done
	fi

	if use ruby ; then
		ruby-ng_src_compile
	fi

	if use spooler ; then
		python uwsgiconfig.py --plugin plugins/spooler gentoo || die "building plugin for spooler failed"
	fi

	if use apache2 ; then
		for m in Ruwsgi uwsgi ; do
			APXS2_ARGS="-c mod_${m}.c"
			apache-module_src_compile
		done
	fi
}

src_install() {
	dobin uwsgi

	insinto /usr/$(get_libdir)/uwsgi
	doins "${T}/plugins"/*.so

	use lua && dosym uwsgi /usr/bin/uwsgi_lua

	use perl && dosym uwsgi /usr/bin/uwsgi_perl

	if use python ; then
		python_execute_function install_python_lib
		for a in ${PYTHON_ABIS} ; do
			dosym uwsgi /usr/bin/uwsgi_python${a/.}
		done
	fi

	if use apache2; then
		for m in Ruwsgi uwsgi ; do
			APACHE2_MOD_FILE="${APXS2_S}/.libs/mod_${m}.so"
			apache-module_src_install
		done
	fi

	newinitd "${FILESDIR}"/uwsgi.initd uwsgi
	newconfd "${FILESDIR}"/uwsgi.confd uwsgi
	keepdir /etc/"${PN}".d
	use spooler && keepdir /var/spool/"${PN}"
}

pkg_postinst() {
	if use apache2 ; then
		elog "Two Apache modules have been installed: mod_uwsgi and mod_Ruwsgi."
		elog "You can enable them with -DUWSGI or -DRUWSGI in /etc/conf.d/apache2."
		elog "Both have the same configuration interface and define the same symbols."
		elog "Therefore you can enable only one of them at a time."
		elog "mod_uwsgi is commercially supported by Unbit and stable but a bit hacky."
		elog "mod_Ruwsgi is newer and more Apache-API friendly but not commercially supported."
	fi

	if use lua || use perl || use ruby || use python; then
		elog "The lua, perl and ruby modules are built as plugins."
		elog "Use '--plugins lua', '--plugins psgi', '--plugins rack_ruby18' or '--plugins python27' to load them."
	fi
}
