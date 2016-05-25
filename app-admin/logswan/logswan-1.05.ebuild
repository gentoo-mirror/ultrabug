# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

CMAKE_MIN_VERSION="2.6"
inherit cmake-utils

DESCRIPTION="Web log analyzer using probabilistic data structures"
HOMEPAGE="https://github.com/fcambus/logswan"
SRC_URI="https://github.com/fcambus/${PN}/archive/${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-libs/geoip
		dev-libs/jansson"
RDEPEND="${DEPEND}"

src_prepare() {
	# fix GeoIP data files path
	sed -e 's@/usr/local/share/GeoIP/@/usr/share/GeoIP/@g' -i src/logswan.c || die
}

pkg_postinst() {
	elog "To download the GeoIP backend data files, run:"
	elog "  geoipupdate.sh -f"
}
