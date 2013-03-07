# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/requests/requests-0.13.1.ebuild,v 1.4 2012/08/19 18:49:26 johu Exp $

EAPI="3"
PYTHON_DEPEND="*:2.6"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.4 2.5"

inherit distutils

DESCRIPTION="A general purpose Python data validator"
HOMEPAGE="http://validictory.readthedocs.org/en/latest/https://pypi.python.org/pypi/validictory/0.9.0"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="$DEPEND"

RESTRICT="test"
