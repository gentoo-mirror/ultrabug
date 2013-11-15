# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1

MY_P="jsb-${PV}"

DESCRIPTION="Python based extensible and multi-protocol bot framework"
HOMEPAGE="http://code.google.com/p/jsonbot/"
SRC_URI="http://jsonbot.googlecode.com/files/${MY_P}.tar.gz"
SRC_URI="https://bthate-jsb090.googlecode.com/archive/f69e1ab43e07c348280cde4c047951a117b4c4cd.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# Missing deps (will be bundled) : hapi, sleekxmpp
RDEPEND="dev-python/beautifulsoup
	dev-python/dnspython
	dev-python/feedparser
	dev-python/oauth
	dev-python/requests
	dev-python/simplejson
	>=www-servers/tornado-2.2"
DEPEND="${RDEPEND}
	dev-lang/python[sqlite]
	dev-python/setuptools"

S="${WORKDIR}/${MY_P}"
S="${WORKDIR}/bthate-jsb090-f69e1ab43e07"

#src_install() {
#	distutils_src_install
#	rm -rf "${D}"/usr/jsb/
#}
