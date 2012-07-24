# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils

MY_PN="flume"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Distributed Log Collection"
HOMEPAGE="http://cwiki.apache.org/FLUME/"
SRC_URI="mirror://apache/incubator/${MY_PN}/${MY_P}-incubating/apache-${MY_P}-incubating-bin.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror binchecks"
IUSE=""

DEPEND=""
RDEPEND=">=virtual/jre-1.6
	sys-cluster/apache-hadoop-bin"

S="${WORKDIR}/apache-${MY_P}-incubating-bin"

pkg_setup() {
	enewgroup flume
	enewuser flume -1 -1 /dev/null flume
}

src_install() {
	rmdir bin/amd64 bin/ia64
	dobin bin/flume-ng

	dodir /usr/$(get_libdir)/"${MY_PN}"
	mv "${S}"/{bin,lib} "${D}"/usr/$(get_libdir)/"${MY_PN}" || die

	dosym /etc/"${MY_PN}" /usr/$(get_libdir)/"${MY_PN}"/conf

	JAVA_HOME=$(java-config -g JAVA_HOME)
	echo "export JAVA_HOME=${JAVA_HOME}" >> conf/flume-env.sh.template || die "sed failed"

	insinto /etc/"${MY_PN}"
	for c in conf/*.template; do
		mv "${c}" "${c/.template/}" || die
	done
	doins conf/*

	dodoc README RELEASE-NOTES CHANGELOG
}

pkg_postinst() {
	elog "For info on configuration see https://cwiki.apache.org/FLUME/"
}
