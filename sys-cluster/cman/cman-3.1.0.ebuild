# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils linux-mod versionator

CLUSTER_RELEASE="${PV}"
MY_P="cluster-${CLUSTER_RELEASE}"

MAJ_PV="$(get_major_version)"
MIN_PV="$(get_version_component_range 2).$(get_version_component_range 3)"

DESCRIPTION="General-purpose Distributed Lock Manager"
HOMEPAGE="http://sources.redhat.com/cluster/wiki/"
SRC_URI="https://fedorahosted.org/releases/c/l/cluster/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="logrotate"

DEPEND=">=sys-kernel/linux-headers-2.6.24
	sys-cluster/libccs
	sys-cluster/libfence
	sys-cluster/libcman
	sys-cluster/libdlm
	sys-cluster/libdlmcontrol
	sys-cluster/liblogthread
	"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_configure() {
	# cluster libs have their own separate packages
	sed -i 's/lib//' "${S}/cman/Makefile" || die
	sed -i 's/liblogthread//' "${S}/common/Makefile" || die
	sed -i 's/libs//' "${S}/config/Makefile" || die
	sed -i 's/libdlm libdlmcontrol//' "${S}/dlm/Makefile" || die
	sed -i 's/libfence libfenced//' "${S}/fence/Makefile" || die
	sed -i 's@fence/libfenced@@' "${S}/Makefile" || die
	use logrotate || sed -i '/^LOGRORATED/d' "${S}/doc/Makefile" || die
}

src_compile() {
	./configure \
		--cc=$(tc-getCC) \
		--cflags="-Wall" \
		--disable_kernel_check \
		--kernel_src=${KERNEL_DIR} \
		--somajor="$MAJ_PV" \
		--sominor="$MIN_PV" \
		--without_rgmanager \
		--without_bindings \
		|| die "configure problem"
	
	emake -j1 || die
}

src_install() {
	emake DESTDIR="${D}" install || die
}
