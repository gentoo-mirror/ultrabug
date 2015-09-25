# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

# MAINTAINER NOTE
# CHANGE ME AT EACH VERSION BUMP
MY_COMMIT="18cf9a7717dad0d8106a5205900a17617043fe2c"

inherit eutils

DESCRIPTION="C library for consistent hashing"
HOMEPAGE="https://github.com/RJ/ketama"
SRC_URI="https://github.com/RJ/ketama/archive/${MY_COMMIT}.zip -> ${P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/ketama-${MY_COMMIT}/libketama"
