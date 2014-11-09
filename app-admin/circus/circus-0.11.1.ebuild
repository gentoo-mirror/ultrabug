# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="5"
PYTHON_COMPAT=( python{2_7,3_2,3_3} )
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Circus is a program that will let you run and watch multiple processes and sockets"
HOMEPAGE="http://circus.readthedocs.org"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

DEPEND="dev-python/psutil
        dev-python/pyzmq
        >=www-servers/tornado-3.0
        test? ( dev-python/mock )"
RDEPEND="${DEPEND}"

python_test() {
    nosetests -sw "${BUILD_DIR}/lib/"
}
