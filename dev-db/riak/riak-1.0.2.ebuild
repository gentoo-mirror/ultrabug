# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils versionator

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

PATCHES=()

src_prepare() {
# 	epatch "${FILESDIR}/riak-1.0.2-erlang_js.patch"
	sed -i -e 's/R14B0\[23\]/R14B0\[234\]/g' -e "s@compile generate@compile generate --target_dir=${D}@g" rebar.config || die
	sed -i -e 's/XLDFLAGS="$(LDFLAGS)"//g' -e 's/ $(CFLAGS)//g' deps/erlang_js/c_src/Makefile || die
}

src_install() {
	emake DESTDIR="${D}" rel

	mkdir -p ${D}/{usr/sbin,etc,var/lib/${PN}}

	cp -a rel/riak/bin/ "${D}"/usr/sbin
	cp -a rel/riak/etc/ "${D}"/etc
	cp -a rel/riak/lib/* "${D}"/var/lib/${PN}
	cp -a rel/riak/data/* "${D}"/var/lib/${PN}
}
