# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils

DESCRIPTION="Couchbase C Client Library"
HOMEPAGE="http://www.couchbase.com/communities/c-client-library"
SRC_URI="http://packages.couchbase.com/clients/c/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc ssl static-libs"

# tests fails to build ?
RESTRICT="test"

RDEPEND=">=dev-util/cmake-2.8.9
	>=dev-libs/libevent-1.4.13
	ssl? ( >=dev-libs/openssl-1.0.1g:= )"
DEPEND="${RDEPEND}"

src_install() {
	cmake-utils_src_install
	use doc || rm -rf "${D}"/usr/share
	use static-libs || find "${D}" -type f -name "*.la" -delete
}
