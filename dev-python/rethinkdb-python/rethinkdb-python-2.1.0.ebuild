# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 python3_{3,4} )

inherit distutils-r1

MY_PN="rethinkdb"
DESCRIPTION="Python driver library for the RethinkDB database server."
HOMEPAGE="http://rethinkdb.com/api/python/"
SRC_URI="mirror://pypi/${P:0:1}/${MY_PN}/${MY_PN}-${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc"

RDEPEND=""
DEPEND="${RDEPEND}"

RESTRICT="test"
S="${WORKDIR}/${MY_PN}-${PV}"