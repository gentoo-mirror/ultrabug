# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_{6,7} python3_{2,3,4} )

inherit distutils-r1

DESCRIPTION="Python client for the Consul HTTP API"
HOMEPAGE="https://github.com/gmr/consulate"
SRC_URI="https://github.com/gmr/${PN}/archive/${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-python/requests
	www-servers/tornado
"
DEPEND="${RDEPEND}
	dev-python/setuptools"
