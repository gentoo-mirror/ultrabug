# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# TODO: node_exporter pkg name change to report upstream

EAPI=6

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/scylladb/scylla.git"
	inherit git-r3
else
	MY_PV="${PV/_rc/.rc}"
	MY_P="${PN}-${MY_PV}"
	AMI_COMMIT="0df779dcca3dc36ec7a6e91295a2f96828b07dc8"
	C_ARES_COMMIT="fd6124c74da0801f23f9d324559d8b66fb83f533"
	DPDK_COMMIT="8aa1d694919fb63211ed625539250008f5d7df9a"
	FMT_COMMIT="f61e71ccb9ab253f6d76096b2d958caf38fcccaa"
	SEASTAR_COMMIT="2a2c1d2708bda22087cb04442caebf2e2fe61ef2"
	SWAGGER_COMMIT="1b212bbe713905aac22af1edb836f5cf8cc39cc2"
	SRC_URI="
		https://github.com/scylladb/${PN}/archive/scylla-${MY_PV}.tar.gz -> ${MY_P}.tar.gz
		https://github.com/scylladb/scylla-seastar/archive/${SEASTAR_COMMIT}.tar.gz -> scylla-seastar-${SEASTAR_COMMIT}.tar.gz
		https://github.com/scylladb/scylla-swagger-ui/archive/${SWAGGER_COMMIT}.tar.gz -> scylla-swagger-ui-${SWAGGER_COMMIT}.tar.gz
		https://github.com/scylladb/dpdk/archive/${DPDK_COMMIT}.tar.gz -> dpdk-${DPDK_COMMIT}.tar.gz
		https://github.com/scylladb/fmt/archive/${FMT_COMMIT}.tar.gz -> fmt-${FMT_COMMIT}.tar.gz
		https://github.com/scylladb/c-ares/archive/${C_ARES_COMMIT}.tar.gz -> c-ares-${C_ARES_COMMIT}.tar.gz
		https://github.com/scylladb/scylla-ami/archive/${AMI_COMMIT}.tar.gz -> scylla-ami-${AMI_COMMIT}.tar.gz
	"
	KEYWORDS="~amd64"
	S="${WORKDIR}/scylla-${MY_P}"
fi

PYTHON_COMPAT=( python3_{4,5,6} )

inherit autotools flag-o-matic linux-info python-r1 toolchain-funcs systemd user

DESCRIPTION="NoSQL data store using the seastar framework, compatible with Apache Cassandra"
HOMEPAGE="http://scylladb.com/"

LICENSE="AGPL-3"
SLOT="0"
IUSE="-collectd doc systemd"

# NOTE:
# if you want to debug using backtraces, enable the 'splitdebug' FEATURE:
# https://wiki.gentoo.org/wiki/Project:Quality_Assurance/Backtraces
#
# then check out:
# https://github.com/scylladb/scylla/wiki/How-to-resolve-backtrace

RESTRICT="test"

RDEPEND="
	<dev-libs/thrift-0.11.0
	<dev-util/ragel-7.0
	=app-admin/scylla-jmx-${PV}
	=app-admin/scylla-tools-${PV}
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
	dev-python/pyparsing[${PYTHON_USEDEP}]
	dev-python/pyudev[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
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
	collectd? ( app-metrics/collectd )
	systemd? ( sys-apps/systemd )
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

DOCS=( LICENSE.AGPL NOTICE.txt ORIGIN README.md README-DPDK.md )
PATCHES=(
	"${FILESDIR}/0001-Fix-Scylla-compilation-with-Crypto-v6.patch"
	"${FILESDIR}/0001-Inject-CryptoPP-namespace-where-Crypto-byte-typedef-.patch"
)

pkg_pretend() {
	if tc-is-gcc ; then
		if [[ $(gcc-major-version) -lt 7 && $(gcc-minor-version) -lt 3 ]] ; then
				die "You need at least sys-devel/gcc-7.3"
		fi
	fi
}

pkg_setup() {
	linux-info_pkg_setup
	enewgroup scylla
	enewuser scylla -1 -1 /var/lib/${PN} scylla
}

src_prepare() {
	default

	# replace git submodules by symlinks
	if [[ ${PV} == "9999" ]] ; then
		# set version
		local git_commit=$(git log --pretty=format:'%h' -n 1)
		echo "${PV}-${git_commit}" > version
	else
		rmdir seastar || die
		mv "${WORKDIR}/scylla-seastar-${SEASTAR_COMMIT}" seastar || die

		rmdir seastar/dpdk || die
		mv "${WORKDIR}/dpdk-${DPDK_COMMIT}" seastar/dpdk || die

		rmdir seastar/c-ares || die
		mv "${WORKDIR}/c-ares-${C_ARES_COMMIT}" seastar/c-ares || die

		rmdir seastar/fmt || die
		mv "${WORKDIR}/fmt-${FMT_COMMIT}" seastar/fmt || die

		rmdir swagger-ui || die
		mv "${WORKDIR}/scylla-swagger-ui-${SWAGGER_COMMIT}" swagger-ui || die

		rmdir dist/ami/files/scylla-ami || die
		mv "${WORKDIR}/scylla-ami-${AMI_COMMIT}" dist/ami/files/scylla-ami || die

		# set version
		echo "${MY_PV}-gentoo" > version
	fi

	# fix slotted antlr3 path
	sed -e 's/antlr3 /antlr3.5 /g' -i configure.py || die

	# fix jsoncpp detection
	sed -e 's@json/json.h@jsoncpp/json/json.h@g' -i json.hh || die

	# fix systemd service config path
	mkdir build || die
	cp dist/common/systemd/scylla-server.service.in build/scylla-server.service || die
	sed -e "s#@@SYSCONFDIR@@#/etc/sysconfig#g" -i build/scylla-server.service || die

	# run a clean autoreconf on c-ares
	pushd seastar/c-ares
	eautoreconf || die
	popd
}

src_configure() {
	python_setup

	# native CPU CFLAGS are strongly enforced by upstreams, respect that
	replace-cpu-flags "*" "native"

	${EPYTHON} configure.py --mode=release --with=scylla --enable-dpdk --disable-xen --compiler "$(tc-getCXX)" --ldflags "${LDFLAGS}" --cflags "${CFLAGS}" --python ${EPYTHON} || die
}

src_compile() {
	# force number of parallel builds because ninja does a bad job in guessing
	# and the default build will kill your RAM/Swap in no time
	ninja -v build/release/scylla build/release/iotune -j2 || die
}

src_install() {
	default

	insinto /etc/default
	doins dist/common/sysconfig/scylla-server

	insinto /etc/security/limits.d
	doins dist/common/limits.d/scylla.conf

	insinto /etc/collectd.d
	doins dist/common/collectd.d/scylla.conf

	insinto /etc/scylla.d
	mv conf/housekeeping.cfg dist/common/scylla.d/
	doins dist/common/scylla.d/*.conf

	insinto /etc/sysctl.d
	doins dist/common/sysctl.d/*.conf
	doins dist/debian/sysctl.d/*.conf

	insinto /etc/scylla
	doins conf/*

	systemd_dounit build/*.service
	systemd_dounit dist/common/systemd/*.service
	systemd_dounit dist/common/systemd/*.timer

	newinitd "${FILESDIR}/scylla-server.initd" ${PN}-server
	newconfd "${FILESDIR}/scylla-server.confd" ${PN}-server

	exeinto /usr/lib/scylla
	doexe dist/common/scripts/*
	doexe seastar/scripts/*
	doexe seastar/dpdk/usertools/dpdk-devbind.py
	doexe scylla-blocktune
	doexe scylla-housekeeping

	dobin build/release/iotune
	dobin build/release/scylla
	dobin dist/common/bin/scyllatop

	dodoc -r licenses

	insinto /usr/lib/scylla/swagger-ui
	doins -r swagger-ui/dist

	insinto /usr/lib/scylla/api
	doins -r api/api-doc

	insinto /usr/lib/scylla/scyllatop
	doins -r tools/scyllatop/*
	fperms +x /usr/lib/scylla/scyllatop/scyllatop.py

	for util in $(ls dist/common/sbin/); do
		dosym /usr/lib/scylla/${util} /usr/sbin/${util}
	done

	for x in /var/lib/${PN}/{data,commitlog,coredump} /var/lib/scylla-housekeeping /var/log/scylla; do
		keepdir "${x}"
		fowners scylla:scylla "${x}"
	done

	insinto /etc/sudoers.d
	doins dist/debian/sudoers.d/scylla

	insinto /etc/rsyslog.d
	doins "${FILESDIR}/10-scylla.conf"

	insinto /etc/cron.d
	newins dist/debian/scylla-server.cron.d scylla_delay_fstrim
}

pkg_postinst() {
	elog "You should run 'emerge --config dev-db/scylla' to finalize your ScyllaDB installation."
}

pkg_config() {
	elog "Running 'scylla_setup'..."
	scylla_setup
}