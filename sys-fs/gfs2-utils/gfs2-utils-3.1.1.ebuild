# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit autotools linux-info

DESCRIPTION="GFS2 Utilities"
HOMEPAGE="http://sources.redhat.com/cluster/wiki/"
SRC_URI="https://fedorahosted.org/releases/${PN:0:1}/${PN:1:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND="sys-cluster/corosync
	sys-cluster/openais
	sys-cluster/liblogthread
	sys-cluster/libccs
	sys-cluster/libfence
	sys-cluster/libdlm
	sys-libs/ncurses"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${PN}"

src_prepare() {
	mkdir m4
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable debug) \
		--with-kernel="${KERNEL_DIR}" \
		--localstatedir=/var
}

src_install() {
	emake DESTDIR="${D}" install || die "emake failed"
	rm -rf "${D}/usr/share/doc"
	dodoc doc/*.txt
	keepdir /var/{lib,log,run}/cluster
}
