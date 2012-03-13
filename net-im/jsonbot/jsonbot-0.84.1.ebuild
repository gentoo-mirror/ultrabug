# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
PYTHON_DEPEND="2"
MY_P="jsb-${PV}"

inherit distutils

DESCRIPTION=""
HOMEPAGE="http://code.google.com/p/jsonbot/"
SRC_URI="http://jsonbot.googlecode.com/files/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# Missing deps (will be bundled) : hapi, sleekxmpp
RDEPEND="dev-python/beautifulsoup
	dev-python/dnspython
	dev-python/feedparser
	dev-python/oauth
	dev-python/pysqlite
	dev-python/requests
	dev-python/simplejson
	>=www-servers/tornado-2.2"
DEPEND="${RDEPEND}
	dev-lang/python[sqlite]
	dev-python/setuptools"

S="${WORKDIR}/${MY_P}"

src_install() {
	distutils_src_install
	rm -rf "${D}"/usr/jsb/
}
