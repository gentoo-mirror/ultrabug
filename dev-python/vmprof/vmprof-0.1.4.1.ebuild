# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4} )

inherit distutils-r1

DESCRIPTION="vmprof Python client"
HOMEPAGE="https://vmprof.readthedocs.org/en/latest/"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	dev-libs/elfutils
	dev-libs/libdwarf
	dev-python/click
	dev-python/six
	sys-libs/libunwind"

RESTRICT="test"

src_prepare() {
	rm -rf tests
}
