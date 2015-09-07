# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

CMAKE_IN_SOURCE_BUILD=yes
CMAKE_MIN_VERSION="2.8.9"

inherit cmake-utils

DESCRIPTION="Couchbase C Client Library"
HOMEPAGE="http://www.couchbase.com/communities/c-client-library"
SRC_URI="http://packages.couchbase.com/clients/c/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc snappy ssl static-libs"

RDEPEND="dev-libs/libev
	dev-libs/libuv
	>=dev-libs/libevent-1.4.13
	snappy? ( app-arch/snappy )
	ssl? ( >=dev-libs/openssl-1.0.1g:= )"
DEPEND="${RDEPEND}"

src_configure() {
	# TODO: downloads something but what and why ?..
	local mycmakeargs=""
	use snappy && mycmakeargs+="-DLCB_NO_SNAPPY=OFF"
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	use doc || rm -rf "${D}"/usr/share
	use static-libs || find "${D}" -type f -name "*.la" -delete
}
