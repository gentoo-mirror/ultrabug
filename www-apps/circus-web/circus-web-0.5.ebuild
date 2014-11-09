# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="5"
PYTHON_COMPAT=( python2_7 )

inherit distutils

DESCRIPTION="Circus Web Dashboard"
HOMEPAGE="http://circus.readthedocs.org/en/latest/for-ops/circusweb/#circushttpd"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-admin/circus"
RDEPEND="${DEPEND}"
