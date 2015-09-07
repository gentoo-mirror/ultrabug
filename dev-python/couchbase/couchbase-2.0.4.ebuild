# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{2,3,4} )

inherit distutils-r1

DESCRIPTION="Python Client for Couchbase"
HOMEPAGE="https://github.com/couchbase/couchbase-python-client"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND=">=dev-libs/libcouchbase-2.4.8"
DEPEND="${RDEPEND}
	doc? ( dev-python/sphinx[${PYTHON_USEDEP}] )"

RESTRICT="test"

python_compile_all() {
	if use doc; then
		mkdir html || die
		sphinx-build doc html || die
	fi
}

python_install_all() {
	distutils-r1_python_install_all
	use doc || rm -rf "${D}"/usr/share
}
