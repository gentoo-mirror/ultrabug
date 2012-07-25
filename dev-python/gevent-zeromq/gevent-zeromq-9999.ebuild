# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/flask-pymongo/flask-pymongo-0.1.1.ebuild,v 1.1 2012/06/18 08:45:36 ultrabug Exp $

EAPI="3"
PYTHON_DEPEND="2:2.5"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.4 3.*"
# DISTUTILS_SRC_TEST=""

EGIT_REPO_URI="git://github.com/traviscline/gevent-zeromq.git
	https://github.com/traviscline/gevent-zeromq.git"

inherit distutils git-2

MY_PN="gevent-zeromq"
MY_P="${MY_PN}-${PV/_/-}"

DESCRIPTION="PyZMQ wrapper to work with gevent"
HOMEPAGE="https://github.com/traviscline/gevent-zeromq"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	dev-python/gevent
	dev-python/setuptools"

S="${WORKDIR}/${MY_P}"
