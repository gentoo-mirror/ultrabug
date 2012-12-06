# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/flask-pymongo/flask-pymongo-0.1.1.ebuild,v 1.1 2012/06/18 08:45:36 ultrabug Exp $

EAPI="5"
DISTUTILS_SRC_TEST=""

EGIT_REPO_URI="git://github.com/technomancy/leiningen.git
	https://github.com/technomancy/leiningen.git"

inherit git-2

MY_P="${MY_PN}-${PV/_/-}"

DESCRIPTION="Automate Clojure projects without setting your hair on fire"
HOMEPAGE="https://github.com/technomancy/leiningen"

LICENSE="EPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# NOTE: you need the java-overlay for this ebuild to work
RDEPEND=""
DEPEND="${RDEPEND}
	>=virtual/jre-1.6
	dev-lang/clojure-contrib
	"

src_install() {
	dobin bin/lein
}