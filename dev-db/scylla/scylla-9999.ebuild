# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

#EGIT_COMMIT="scylla-${PV}"
EGIT_REPO_URI="https://github.com/scylladb/scylla.git"
PYTHON_COMPAT=( python3_{4,5,6} )

inherit git-r3 linux-info python-r1 toolchain-funcs systemd user

DESCRIPTION="NoSQL data store using the seastar framework, compatible with Apache Cassandra"
HOMEPAGE="http://scylladb.com/"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc systemd"

RESTRICT="test"

RDEPEND="
	app-admin/collectd
	app-arch/lz4
	=app-admin/scylla-tools-${PV}
	=app-admin/scylla-jmx-${PV}
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
	=dev-libs/thrift-0.9.1
	dev-python/pyparsing[${PYTHON_USEDEP}]
	dev-python/pyudev[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	<dev-util/ragel-7.0
	dev-python/urwid[${PYTHON_USEDEP}]
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

# Discussion about kernel configuration:
# https://groups.google.com/forum/#!topic/scylladb-dev/qJu2zrryv-s
# For DPDK, removed HUGETLBFS PROC_PAGE_MONITOR UIO_PCI_GENERIC in favor of VFIO
CONFIG_CHECK="~NUMA_BALANCING ~SYN_COOKIES ~TRANSPARENT_HUGEPAGE ~VFIO"
ERROR_NUMA_BALANCING="${PN} recommends support for Memory placement aware NUMA scheduler (NUMA_BALANCING)."
ERROR_SYN_COOKIES="${PN} recommends support for TCP syncookie (SYN_COOKIES)."
ERROR_TRANSPARENT_HUGEPAGE="${PN} recommends support for Transparent Hugepage (TRANSPARENT_HUGEPAGE)."
ERROR_VFIO="${PN} running with DPDK recommends support for Non-Privileged userspace driver framework (VFIO)."

DOCS=( LICENSE.AGPL README.md )
PATCHES=()

pkg_setup() {
	linux-info_pkg_setup
	enewgroup scylla
	enewuser scylla -1 -1 /var/lib/${PN} scylla
}

src_prepare() {
	default

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

	# fix seastar -Werror crashing build
	sed -e 's/ -Werror//g' -i seastar/configure.py || die

	# fix ragel-7.0 bug
	# https://github.com/scylladb/seastar/issues/296
}

src_configure() {
	# TODO: --cflags "${CFLAGS}"
	./configure.py --mode=release --with=scylla --enable-dpdk --disable-xen --compiler "$(tc-getCXX)" --ldflags "${LDFLAGS}" || die
}

src_compile() {
	# force MAKEOPTS because ninja does a bad job in guessing and the default
	# build will kill your RAM/Swap in no time
	ninja -v build/release/scylla build/release/iotune -j4 || die
}

src_install() {
	# executables
	exeinto /usr/lib/scylla
	doexe dist/common/scripts/*
	doexe dist/debian/scripts/*
	doexe seastar/scripts/*
	doexe seastar/dpdk/usertools/dpdk-devbind.py
	doexe scylla-blocktune
	doexe scylla-housekeeping

	# scyllatop
	insinto /usr/lib/scylla/scyllatop
	doins -r tools/scyllatop/*
	fperms +x /usr/lib/scylla/scyllatop/scyllatop.py

	# swagger-ui
	insinto /usr/lib/scylla/swagger-ui
	doins -r swagger-ui/dist

	# bin
	dobin build/release/iotune
	dobin build/release/scylla
	dobin dist/common/bin/scyllatop

	# sbin symlinks
	for util in $(ls dist/common/sbin/); do
		dosym /usr/lib/scylla/${util} /usr/sbin/${util}
	done

	insinto /etc/collectd.d
	doins dist/common/collectd.d/scylla.conf

	for x in /var/lib/${PN}/{data,commitlog,coredump} /var/lib/scylla-housekeeping /var/log/scylla; do
		keepdir "${x}"
		fowners scylla:scylla "${x}"
	done

	insinto /etc/scylla.d
	mv conf/housekeeping.cfg dist/common/scylla.d/
	doins dist/common/scylla.d/*.conf

	insinto /etc/scylla
	doins conf/*

	insinto /etc/security/limits.d
	doins dist/common/limits.d/scylla.conf

	insinto /etc/sudoers.d
	doins dist/debian/sudoers.d/scylla

	insinto /etc/sysctl.d
	doins dist/debian/sysctl.d/99-scylla.conf

	insinto /etc/default
	doins dist/common/sysconfig/scylla-server

	insinto /etc/modprobe.d
	doins dist/common/modprobe.d/*

	insinto /etc/rsyslog.d
	doins "${FILESDIR}/10-scylla.conf"

	insinto /etc/cron.d
	newins dist/debian/scylla-server.cron.d scylla_delay_fstrim

	newinitd "${FILESDIR}/scylla-server.initd" ${PN}-server
	newconfd "${FILESDIR}/scylla-server.confd" ${PN}-server
	systemd_dounit dist/common/systemd/*.service
	systemd_dounit dist/common/systemd/*.timer

	# TODO: api docs are simple JSON files!?
	if use doc; then
		insinto /usr/lib/scylla/api
		doins -r api/api-doc
	fi
}

pkg_postinst() {
	elog "You should run 'emerge --config dev-db/scylla' to finalize your ScyllaDB installation."
}

pkg_config() {
	elog "Running 'scylla_setup'..."
	scylla_setup
}