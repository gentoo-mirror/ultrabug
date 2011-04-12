# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
SCONS_MIN_VERSION="1.2.0"

inherit eutils multilib scons-utils versionator

MY_P="${PN}-src-r${PV/_rc/-rc}"

DESCRIPTION="A high-performance, open source, schema-free document-oriented database"
HOMEPAGE="http://www.mongodb.org"
SRC_URI="http://downloads.mongodb.org/src/${MY_P}.tar.gz"

LICENSE="AGPL-3 Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# Prefer static-libs as recommended by upstream
IUSE="+static-libs v8"
RDEPEND="!v8? ( >=dev-lang/spidermonkey-1.9 )
	v8? ( dev-lang/v8 )
	dev-libs/boost
	dev-libs/libpcre[cxx]
	net-libs/libpcap"
DEPEND="${RDEPEND}
	sys-libs/readline
	sys-libs/ncurses"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	enewgroup mongodb
	enewuser mongodb -1 -1 /var/lib/${PN} mongodb

	scons_opts=""
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
	escons ${scons_opts} all || die "Compile failed"
}

pkg_preinst() {
	has_version '<dev-db/mongodb-1.8'
	PREVIOUS_LESS_THAN_1_8=$?
}

src_install() {
	escons ${scons_opts} --full --nostrip install --prefix="${D}"/usr || die "Install failed"

	use static-libs || rm "${D}/usr/$(get_libdir)/libmongoclient.a"

	for x in /var/{lib,log,run}/${PN}; do
		keepdir "${x}" || die "Install failed"
		fowners mongodb:mongodb "${x}"
	done

	doman debian/mongo*.1 || die "Install failed"
	dodoc README docs/building.md

	newinitd "${FILESDIR}/${PN}.initd" ${PN} || die "Install failed"
	newconfd "${FILESDIR}/${PN}.confd" ${PN} || die "Install failed"
	newinitd "${FILESDIR}/${PN/db/s}.initd" ${PN/db/s} || die "Install failed"
	newconfd "${FILESDIR}/${PN/db/s}.confd" ${PN/db/s} || die "Install failed"
}

src_test() {
	escons ${scons_opts} test || die "Build test failed"
	${S}/test --dbpath=unittest || die "Tests failed"
}

pkg_postinst() {
	if [ ${PREVIOUS_LESS_THAN_1_8} -eq 0 ]; then
		ewarn "You just upgraded from a previous version of mongodb !"
		ewarn "Make sure you run 'mongod --upgrade' before using this version."
	fi
	elog "Journaling is now enabled by default, see /etc/conf.d/${PN}.conf"
}