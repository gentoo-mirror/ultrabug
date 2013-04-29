# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="4"
PYTHON_DEPEND="*:2.6"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.4 2.5"

DESCRIPTION="GRequests allows you to use Requests with Gevent to make asyncronous HTTP Requests easily."
HOMEPAGE="https://crate.io/packages/grequests"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/gevent
	>=dev-python/requests-1.0.0"
RDEPEND="${DEPEND} =dev-python/charade-1.0.3"

RESTRICT="test"
