# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

EGIT_REPO_URI="https://github.com/scylladb/scylla.git"
PYTHON_COMPAT=( python3_{4,5} )

inherit autotools git-r3 python-r1 toolchain-funcs systemd user

DESCRIPTION="NoSQL data store using the seastar framework, compatible with Apache Cassandra"
HOMEPAGE="http://scylladb.com/"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="collectd systemd"

RDEPEND="
	=dev-libs/thrift-0.9.1
	app-arch/lz4
	app-arch/snappy
	dev-cpp/antlr-cpp:3.5
	dev-cpp/yaml-cpp
	dev-java/antlr:3.5
	dev-libs/boost
	dev-libs/crypto++
	dev-libs/jsoncpp
	dev-libs/libaio
	dev-libs/libxml2
	dev-libs/protobuf
	dev-python/pyparsing
	dev-python/urwid
	dev-util/ragel
	dev-util/systemtap
	net-libs/gnutls
	net-misc/lksctp-tools
	sys-apps/hwloc
	sys-fs/xfsprogs
	sys-libs/libunwind
	sys-libs/zlib
	sys-process/numactl
	x11-libs/libpciaccess
"
DEPEND="${RDEPEND}
	>=sys-kernel/linux-headers-3.5
	dev-util/ninja
"

DOCS=( LICENSE.AGPL README.md )

pkg_setup() {
	enewgroup scylla
	enewuser scylla -1 -1 /var/lib/${PN} scylla
}

src_prepare() {
	eapply_user

	# set version
	local git_commit=$(git log --pretty=format:'%h' -n 1)
	echo "${PV}-${git_commit}" > version

	# fix slotted antlr3 path
	sed -e 's/antlr3 /antlr3.5 /g' -i configure.py || die

	# fix jsoncpp detection
	sed -e 's@json/json.h@jsoncpp/json/json.h@g' -i json.hh || die

	# fix systemd service config path
	cp dist/common/systemd/scylla-server.service.in dist/common/systemd/scylla-server.service || die
	sed -e "s#@@SYSCONFDIR@@#/etc/sysconfig#g" -i dist/common/systemd/scylla-server.service || die
}

src_configure() {
	# TODO: --cflags "${CFLAGS}"
	#./configure.py --help
	./configure.py --mode=release --disable-xen --compiler "$(tc-getCXX)" --ldflags "${LDFLAGS}" || die
	#./configure.py --disable-xen --enable-dpdk --mode=release || die
}

src_compile() {
	ninja -v build/release/scylla build/release/iotune ${MAKEOPTS} || die
}

src_install() {
	insinto /usr/lib/scylla
	doins -r tools/scyllatop
	doins dist/common/scripts/*
	doins dist/debian/scripts/*
	doins scylla-blocktune
	doins scylla-housekeeping
	doins seastar/scripts/dpdk_nic_bind.py
	doins seastar/scripts/posix_net_conf.sh

	insinto /usr/lib/scylla/swagger-ui
	doins -r swagger-ui/dist

	insinto /usr/lib/scylla/api
	doins -r api/api-doc

	insinto /etc/security/limits.d
	doins dist/common/limits.d/scylla.conf

	insinto /etc/scylla.d
	doins dist/common/scylla.d/*.conf

	insinto /etc/scylla
	doins conf/*

	insinto /etc/sysctl.d
	doins dist/debian/sysctl.d/99-scylla.conf

	dobin build/release/iotune
	dobin build/release/scylla
	dobin dist/common/bin/scyllatop

	for util in $(ls dist/common/sbin/); do
		dosym /usr/lib/scylla/${util} /usr/sbin/${util}
	done

	if use collectd; then
		insinto /etc/collectd.d
		doins dist/common/collectd.d/scylla.conf
	fi

	for x in /var/lib/${PN}/{data,commitlog,coredump} /var/log/scylla; do
		keepdir "${x}"
		fowners scylla:scylla "${x}"
	done

	insinto /etc/default
	doins dist/common/sysconfig/scylla-server

	newinitd "${FILESDIR}/scylla.initd" ${PN}
	newconfd "${FILESDIR}/scylla.confd" ${PN}
	systemd_dounit dist/common/systemd/*.service
	systemd_dounit dist/common/systemd/*.timer
}
