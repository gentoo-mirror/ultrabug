# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/flask-pymongo/flask-pymongo-0.1.1.ebuild,v 1.1 2012/06/18 08:45:36 ultrabug Exp $

EAPI="3"
PYTHON_DEPEND="2:2.6"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.4 3.*"
DISTUTILS_SRC_TEST=""

EGIT_REPO_URI="git://github.com/martinblech/mimerender.git
	https://github.com/martinblech/mimerender.git"

inherit distutils git-2

MY_PN="mimerender"
MY_P="${MY_PN}-${PV/_/-}"

DESCRIPTION="Python module for RESTful HTTP Content Negotiation"
HOMEPAGE="https://github.com/martinblech/mimerender"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	dev-python/mimeparse
	dev-python/setuptools"

S="${WORKDIR}/${MY_P}"