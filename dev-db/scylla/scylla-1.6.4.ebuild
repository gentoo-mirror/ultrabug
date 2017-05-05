# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

EGIT_REPO_URI="https://github.com/scylladb/scylla.git"
PYTHON_COMPAT=( python3_{4,5,6} )

inherit git-r3 linux-info python-r1 toolchain-funcs systemd user

DESCRIPTION="NoSQL data store using the seastar framework, compatible with Apache Cassandra"
HOMEPAGE="http://scylladb.com/"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="collectd doc systemd"

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
	dev-python/pyudev
	dev-python/urwid
	dev-util/ragel
	dev-util/systemtap
	net-libs/gnutls
	net-misc/lksctp-tools
	sys-apps/hwloc
	sys-apps/irqbalance[numa]
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

CONFIG_CHECK="~KPROBES ~NUMA_BALANCING ~SYN_COOKIES ~TRANSPARENT_HUGEPAGE"
ERROR_KPROBES="${PN} recommends support for KProbes Instrumentation (KPROBES)."
ERROR_NUMA_BALANCING="${PN} recommends support for Memory placement aware NUMA scheduler (NUMA_BALANCING)."
ERROR_SYN_COOKIES="${PN} recommends support for TCP syncookie support (SYN_COOKIES)."
ERROR_TRANSPARENT_HUGEPAGE="${PN} recommends support for Transparent Hugepage support (TRANSPARENT_HUGEPAGE)."

DOCS=( LICENSE.AGPL README.md )
PATCHES=(
	"${FILESDIR}/fix_perftune_indexerror.patch"
	"${FILESDIR}/0001-add-gentoo_variant-detection-and-SYSCONFIG-setup.patch"
	"${FILESDIR}/0001-Add-support-for-Gentoo-Linux-irqbalance-configuratio.patch"
	"${FILESDIR}/0002-detect-gentoo-linux-on-selinux-setup.patch"
	"${FILESDIR}/0003-coredump-setup-add-support-for-gentoo-linux.patch"
	"${FILESDIR}/0004-cpuscaling-setup-add-support-for-gentoo-linux.patch"
	"${FILESDIR}/0005-kernel-check-add-support-for-gentoo-linux.patch"
	"${FILESDIR}/0006-ntp-setup-add-support-for-gentoo-linux.patch"
	"${FILESDIR}/0007-raid-setup-add-support-for-gentoo-linux.patch"
	"${FILESDIR}/0008-prometheus-node_exporter-install-add-support-for-gen.patch"
	"${FILESDIR}/0009-scylla_setup-add-gentoo-linux-installation-detection.patch"
	"${FILESDIR}/0010-scylla_setup-refactor-scylla-server-service-setup-wh.patch"
	"${FILESDIR}/0011-scylla_setup-disable-useless-version-check-for-gento.patch"
	"${FILESDIR}/0012-scylla_setup-disable-selinux-setup-for-gentoo-linux.patch"
	"${FILESDIR}/0013-scylla_setup-fix-typo-on-cpu-scaling-messages.patch"
)

pkg_setup() {
	linux-info_pkg_setup
	enewgroup scylla
	enewuser scylla -1 -1 /var/lib/${PN} scylla
}

src_prepare() {
	default
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

	# fix -Werror crashing build
	sed -e 's/ -Werror//g' -i seastar/configure.py || die
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

	if use collectd; then
		insinto /etc/collectd.d
		doins dist/common/collectd.d/scylla.conf
	fi

	for x in /var/lib/${PN}/{data,commitlog,coredump} /var/log/scylla; do
		keepdir "${x}"
		fowners scylla:scylla "${x}"
	done

	insinto /etc/security/limits.d
	doins dist/common/limits.d/scylla.conf

	insinto /etc/scylla.d
	doins dist/common/scylla.d/*.conf

	insinto /etc/sudoers.d
	doins dist/debian/sudoers.d/scylla

	insinto /etc/scylla
	doins conf/*

	insinto /etc/sysctl.d
	doins dist/debian/sysctl.d/99-scylla.conf

	insinto /etc/default
	doins dist/common/sysconfig/scylla-server

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
	elog "Setting up irqbalance..."
	if $(grep -q systemd /proc/1/comm); then
		systemctl enable irqbalance.service
		systemctl start irqbalance.service
	else
		rc-update add irqbalance default
		service irqbalance start
	fi

	elog "Running 'scylla_setup'..."
	scylla_setup
}