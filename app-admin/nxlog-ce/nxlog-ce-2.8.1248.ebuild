# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit autotools user

MY_PN="nxlog"

DESCRIPTION="Universal log collector and forwarder supporting different platforms"
HOMEPAGE="http://nxlog.org"
SRC_URI="http://nxlog.org/system/files/products/files/1/${P}.tar.gz"

LICENSE="NXLOG-1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="perl static-libs"

DEPEND=""
RDEPEND="${DEPEND}"

pkg_setup() {
	enewgroup nxlog
	enewuser nxlog -1 -1 /var/lib/${MY_PN} "adm,nxlog"
}

# TODO: fix me ?
# src_prepare() {
# 	sed -e 's/.* -ggdb3 .*/echo/g' -i configure.in || die 'failed to remove ggdb3 flag'
# 	mv configure.in configure.ac
# 	find . -name Makefile.in -exec sed -e 's@/configure.in@/configure.ac@g' -i {} \;
# 	eautoreconf
# 	eapply_user
# }

src_configure() {
	local conf_opts=(
		--libexecdir=/usr/$(get_libdir)
		--libdir=/usr/$(get_libdir)
		--localstatedir=/var
		--with-pidfile=/run/nxlog/nxlog.pid
		$(use_enable perl xm_perl)
		$(use_enable static-libs static)
	)
	econf "${conf_opts[@]}"
}

src_install() {
	default

	use static-libs || find ${D} -type f -name "*.la" -delete

	insinto /etc/nxlog
	doins packaging/debian/nxlog.conf

	keepdir /var/log/nxlog
	fowners nxlog:nxlog /var/log/nxlog

	keepdir /var/spool/nxlog
	fowners nxlog:nxlog /var/spool/nxlog

	newinitd "${FILESDIR}/${MY_PN}.initd" ${MY_PN}
}

pkg_postinst() {
	einfo "See the nxlog reference manual for configuration options."
	einfo "    http://nxlog.org/nxlog-docs/en/nxlog-reference-manual.html"
}
