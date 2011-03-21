# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/rgmanager/rgmanager-2.03.09-r1.ebuild,v 1.1 2011/01/20 09:13:18 xarthisius Exp $

EAPI=3

inherit eutils multilib versionator

CLUSTER_RELEASE="${PV}"
MY_P="cluster-${CLUSTER_RELEASE}"

MAJ_PV="$(get_major_version)"
MIN_PV="$(get_version_component_range 2).$(get_version_component_range 3)"

DESCRIPTION="Clustered resource group manager"
HOMEPAGE="http://sources.redhat.com/cluster/wiki/"
SRC_URI="https://fedorahosted.org/releases/c/l/cluster/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="dbus"

RDEPEND="
	~sys-cluster/libccs-${PV}
	~sys-cluster/libdlm-${PV}"
DEPEND="${RDEPEND}
	dev-libs/libxml2
	=sys-libs/slang-2*"

S=${WORKDIR}/${MY_P}/${PN}

src_prepare() {
	epatch "${FILESDIR}/${P}-fix_libxml2.patch"
}

src_configure() {
	local myopts=""
	use dbus || myopts="--disable_dbus"
	(cd "${WORKDIR}"/${MY_P};
		./configure \
			--cc="$(tc-getCC)" \
			--cflags="-Wall" \
			--libdir=/usr/$(get_libdir) \
			--disable_kernel_check \
			--somajor="$MAJ_PV" \
			--sominor="$MIN_PV" \
			--dlmlibdir=/usr/$(get_libdir) \
			--dlmincdir=/usr/include \
			--cmanlibdir=/usr/$(get_libdir) \
			--cmanincdir=/usr/include \
			${myopts} \
	) || die "configure problem"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake failed"

	newinitd "${FILESDIR}"/${PN}-2.0x.rc ${PN} || die
	newconfd "${FILESDIR}"/${PN}-2.0x.conf ${PN} || die
}
