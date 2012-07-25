# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils

MY_PN="hive"
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
	insinto /usr/share/"${MY_PN}"
	mv "${S}"/{bin,lib,scripts,examples} "${D}"/usr/share/"${MY_PN}" || die

	dosym /usr/share/"${MY_PN}"/bin/hive /usr/bin/hive
	dosym /usr/share/"${MY_PN}"/bin/hive-config.sh /usr/bin/hive-config.sh
	dosym /etc/"${MY_PN}" /usr/share/"${MY_PN}"/conf

	insinto /etc/"${MY_PN}"
	for c in conf/*; do
		mv "${c}" "${c/.template/}" || die
	done
	sed -e 's/org.apache.hadoop.metrics.jvm.EventCounter/org.apache.hadoop.log.metrics.EventCounter/g' \
		-i conf/*log4j.properties || die
	doins conf/*

	dodoc README.txt RELEASE_NOTES.txt
}

pkg_postinst() {
	elog "For info on configuration see http://hadoop.apache.org/${MY_PN}/docs/r${PV}"
}
