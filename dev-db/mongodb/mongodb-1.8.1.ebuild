# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/mongodb/mongodb-1.6.0.ebuild,v 1.2 2011/02/02 18:14:42 phajdan.jr Exp $

EAPI=3

inherit eutils multilib versionator

MY_PATCHVER=$(get_version_component_range 1-2)
MY_P="${PN}-src-r${PV}"

DESCRIPTION="A high-performance, open source, schema-free document-oriented database"
HOMEPAGE="http://www.mongodb.org"
SRC_URI="http://downloads.mongodb.org/src/${MY_P}.tar.gz"

LICENSE="AGPL-3 Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static-libs v8"

RDEPEND="!v8? ( >=dev-lang/spidermonkey-1.9 )
	v8? ( dev-lang/v8 )
	dev-libs/boost
	dev-libs/libpcre[cxx]
	net-libs/libpcap"
DEPEND="${RDEPEND}
	dev-util/scons
	sys-libs/readline
	sys-libs/ncurses"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	enewgroup mongodb
	enewuser mongodb -1 -1 /var/lib/${PN} mongodb

	scons_opts="${MAKEOPTS}"
	use static-libs || scons_opts+=" --sharedclient"
	if use v8; then
		scons_opts+=" --usev8"
	else
		scons_opts+=" --usesm"
	fi
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-1.8-fix-scons.patch"
}

src_compile() {
	scons ${scons_opts} all || die "Compile failed"
}

pkg_preinst() {
	has_version '<dev-db/mongodb-1.8'
	PREVIOUS_LESS_THAN_1_8=$?
}

src_install() {
	scons ${scons_opts} --full --nostrip install --prefix="${D}"/usr || die "Install failed"

	use static-libs || rm "${D}/usr/$(get_libdir)/libmongoclient.a"

	for x in /var/{lib,log}/${PN}; do
		keepdir "${x}" || die "Install failed"
		fowners mongodb:mongodb "${x}"
	done

	doman debian/mongo*.1 || die "Install failed"
	dodoc README docs/building.md

	newinitd "${FILESDIR}/${PN}.initd" ${PN} || die "Install failed"
	newconfd "${FILESDIR}/${PN}.confd" ${PN} || die "Install failed"
}

# FIXME: test phase depends on pymongo which is not in tree
# src_test() {
	#scons ${scons_opts} smoke --smokedbprefix='testdir' test || die "Tests failed"
# }

pkg_postinst() {
	if [ ${PREVIOUS_LESS_THAN_1_8} -eq 0 ]; then
		ewarn "You just upgraded from a previous version of mongodb !"
		ewarn "Make sure you run 'mongod --upgrade' before using this version."
	fi
	elog "Journaling is now set as default, see ${CONFDIR}/${PN}."
}