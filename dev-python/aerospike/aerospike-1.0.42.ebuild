# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 flag-o-matic

DESCRIPTION="Python Client for Aerospike"
HOMEPAGE="https://github.com/aerospike/aerospike-client-python"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-libs/libaerospike[static-libs]
	!dev-libs/libaerospike[luajit]
	>=dev-libs/openssl-1.0.1g:="
DEPEND="${RDEPEND}"

RESTRICT="test"

src_prepare() {
	sed -e "s@aerospike_c_prefix = './aerospike-client-c'@aerospike_c_prefix = '/usr'@g" -i setup.py || die
}

python_install_all() {
	AEROSPIKE_LUA_PATH=/opt/aerospike/client/sys/udf/lua/ PREFIX=/usr distutils-r1_python_install_all
	rm -rf "${D}"/usr/aerospike
}
