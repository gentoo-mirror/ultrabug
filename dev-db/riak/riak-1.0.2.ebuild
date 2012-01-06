# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit versionator

MAJ_PV="$(get_major_version)"
MED_PV="$(get_version_component_range 2)"
MIN_PV="$(get_version_component_range 3)"

DESCRIPTION="An open source, highly scalable, schema-free document-oriented database"
HOMEPAGE="http://www.basho.com/"
SRC_URI="http://downloads.basho.com/${PN}/${PN}-${MAJ_PV}.${MED_PV}.${MIN_PV}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-lang/erlang"
DEPEND="${RDEPEND}"

pkg_setup() {
	enewgroup riak
	enewuser riak -1 -1 /var/lib/${PN} riak
}

src_prepare() {
	epatch "${FILESDIR}/riak-1.0.2-rel.patch"
	sed -i -e 's/R14B0\[23\]/R14B0\[234\]/g' rebar.config || die
	sed -i -e 's/XLDFLAGS="$(LDFLAGS)"//g' -e 's/ $(CFLAGS)//g' deps/erlang_js/c_src/Makefile || die
}

src_compile() {
	emake rel
}

src_install() {
	# install /usr/lib stuff
	insinto /usr/lib/${PN}
	cp -R rel/riak/lib "${D}"/usr/lib/riak
	cp -R rel/riak/releases "${D}"/usr/lib/riak
	cp -R rel/riak/erts* "${D}"/usr/lib/riak
	chmod 0755 "${D}"/usr/lib/riak/erts*/bin/*

	# install /usr/sbin stuff
	dosbin rel/riak/bin/*

	# install /etc/riak stuff
	insinto /etc/${PN}
	doins rel/riak/etc/*

	# create neccessary directories
	keepdir /var/lib/${PN}/{bitcask,ring}
	keepdir /var/log/${PN}/sasl
	keepdir /var/run/${PN}

	# create docs
	doman doc/man/man1/*
	dodoc doc/*.txt

	# TODO: init.d / conf.d files
}
