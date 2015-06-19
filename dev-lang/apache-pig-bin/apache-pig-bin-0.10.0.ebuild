# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils

MY_PN="pig"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="High-level language and platform for analyzing large data sets"
HOMEPAGE="http://hadoop.apache.org/"
SRC_URI="mirror://apache/${MY_PN}/${MY_P}/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror binchecks"
IUSE=""

DEPEND=""
RDEPEND=">=virtual/jre-1.6
	sys-cluster/apache-hadoop-bin"

S="${WORKDIR}/${MY_P}"

src_install() {
	dobin bin/pig

	insinto /usr/share/"${MY_PN}"
	doins "${MY_P}"-withouthadoop.jar
	newins "${MY_P}"-withouthadoop.jar "${MY_P}"-core.jar
	mv "${S}"/{contrib,lib,scripts,src/packages/templates,test,tutorial} "${D}"/usr/share/"${MY_PN}" || die

	insinto /etc/"${MY_PN}"
	doins conf/*

	dosbin src/packages/*.sh

	dodoc README.txt RELEASE_NOTES.txt CHANGES.txt
	dohtml -r docs/*
}

pkg_postinst() {
	elog "For info on configuration see http://hadoop.apache.org/${MY_PN}/docs/r${PV}"
}
