# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python2_7 )

inherit cmake-utils python-single-r1

DESCRIPTION="A GraphQL query parser in C++ with C and C++ APIs"
HOMEPAGE="https://github.com/graphql/libgraphqlparser"
SRC_URI="https://github.com/graphql/libgraphqlparser/archive/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
