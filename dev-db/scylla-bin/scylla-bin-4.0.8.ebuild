# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_PV="${PV}-0.20200830.7d1180b98fc"

inherit linux-info user versionator

DESCRIPTION="NoSQL data store using the seastar framework, compatible with Apache Cassandra"
HOMEPAGE="https://scylladb.com/"
SRC_URI="http://downloads.scylladb.com/downloads/scylla/relocatable/scylladb-$(get_version_component_range 1-2)/scylla-package-${MY_PV}.tar.gz -> ${P}-package.tar.gz http://downloads.scylladb.com/downloads/scylla/relocatable/scylladb-$(get_version_component_range 1-2)/scylla-python3-package-${MY_PV}.tar.gz -> ${P}-python3.tar.gz http://downloads.scylladb.com/downloads/scylla/relocatable/scylladb-$(get_version_component_range 1-2)/scylla-tools-package-${MY_PV}.tar.gz -> ${P}-tools.tar.gz http://downloads.scylladb.com/downloads/scylla/relocatable/scylladb-$(get_version_component_range 1-2)/scylla-jmx-package-${MY_PV}.tar.gz -> ${P}-jmx.tar.gz"

KEYWORDS="~amd64"
LICENSE="AGPL-3"
SLOT="0"
IUSE="doc"
RESTRICT="strip test"

RDEPEND="
	!app-admin/scylla-jmx
	!app-admin/scylla-tools
	!dev-db/scylla
"
DEPEND="${RDEPEND}
	>=sys-kernel/linux-headers-3.5
"

# Discussion about kernel configuration:
# https://groups.google.com/forum/#!topic/scylladb-dev/qJu2zrryv-s
CONFIG_CHECK="~NUMA_BALANCING ~SYN_COOKIES ~TRANSPARENT_HUGEPAGE"
ERROR_NUMA_BALANCING="${PN} recommends support for Memory placement aware NUMA scheduler (NUMA_BALANCING)."
ERROR_SYN_COOKIES="${PN} recommends support for TCP syncookie (SYN_COOKIES)."
ERROR_TRANSPARENT_HUGEPAGE="${PN} recommends support for Transparent Hugepage (TRANSPARENT_HUGEPAGE)."

# NOTE: maybe later depending on upstream energy, support DPDK
# For DPDK, removed HUGETLBFS PROC_PAGE_MONITOR UIO_PCI_GENERIC in favor of VFIO
# CONFIG_CHECK="~NUMA_BALANCING ~SYN_COOKIES ~TRANSPARENT_HUGEPAGE ~VFIO"
# ERROR_VFIO="${PN} running with DPDK recommends support for Non-Privileged userspace driver framework (VFIO)."

DOCS=( README.md NOTICE.txt SCYLLA-PRODUCT-FILE SCYLLA-RELEASE-FILE SCYLLA-RELOCATABLE-FILE SCYLLA-VERSION-FILE )
PATCHES=( )
S=${WORKDIR}

pkg_setup() {
	linux-info_pkg_setup
	enewgroup scylla
	enewuser scylla -1 -1 /var/lib/${PN} scylla
}

src_unpack() {
	for pkg in package python3 tools jmx;
	do
		mkdir "${pkg}" || die
		pushd "${pkg}" || die
		unpack ${P}-${pkg}.tar.gz || die
		find . -type f -name "*.pyc" -delete
		popd || die
	done
}

src_prepare() {
	default
	# remove useless ARCH shared objects
	find "${WORKDIR}/tools/lib/sigar-bin" -type f ! -name "libsigar-amd64-linux.so" -delete || die
}

install_package() {
	pushd package

	bash install.sh --root "${D}" --sysconfdir /etc/default --packaging || die

	for x in /var/lib/scylla /var/lib/scylla/{data,commitlog,hints,coredump,hints,view_hints} /var/lib/scylla-housekeeping /var/log/scylla; do
		keepdir "${x}"
		fowners scylla:scylla "${x}"
	done

	insinto /etc/sudoers.d
	newins "${FILESDIR}"/scylla.sudoers scylla

	insinto /etc/rsyslog.d
	doins "${FILESDIR}/10-scylla.conf"

	newinitd "${FILESDIR}/scylla-server.initd" scylla-server
	newconfd "${FILESDIR}/scylla-server.confd" scylla-server

	popd
}

install_python3() {
	pushd python3
	bash install.sh --root "${D}" || die
	popd
}

install_jmx() {
	pushd jmx
	# fix symlink runtime error on scylla-jmx script
	# * scylla-jmx is not available for oracle-jdk-bin-1.8 on x86_64
	# * IMPORTANT: some Java tools are not available on some VMs on some architectures
	sed -e 's@"$LOCATION_SCRIPTS"/symlinks/scylla-jmx@/usr/bin/java@g' -i scylla-jmx || die
	bash install.sh --root "${D}" --sysconfdir /etc/default || die
	newinitd "${FILESDIR}/scylla-jmx.initd" scylla-jmx
	newconfd "${FILESDIR}/scylla-jmx.confd" scylla-jmx
	popd
}

install_tools() {
	pushd tools
	bash install.sh --root "${D}" || die
	popd
}

src_install() {
	install_python3
	install_package
	install_tools
	install_jmx
}

pkg_postinst() {
	elog "You should run 'emerge --config dev-db/scylla' to finalize your Scylla installation."
}

pkg_config() {
	elog "Running 'scylla_setup'..."
	scylla_setup
}
