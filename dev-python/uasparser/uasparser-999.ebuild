# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

PYTHON_DEPEND="2"

inherit python

DESCRIPTION="Python User Agent parser library"
HOMEPAGE="http://user-agent-string.info"
SRC_URI="http://user-agent-string.info/ua_rep/${PN}.py.zip"

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

S="${WORKDIR}/"

pkg_setup() {
    python_set_active_version 2
    python_pkg_setup
}

src_install() {
	insinto "$(python_get_sitedir)"
	doins *.py
}