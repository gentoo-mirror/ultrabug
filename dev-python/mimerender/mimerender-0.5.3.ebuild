# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
PYTHON_COMPAT=( python{2_6,2_7} )

inherit distutils-r1

MY_PN="mimerender"
MY_P="${MY_PN}-${PV/_/-}"

DESCRIPTION="Python module for RESTful HTTP Content Negotiation"
HOMEPAGE="https://github.com/martinblech/mimerender"
SRC_URI="https://github.com/martinblech/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=dev-python/mimeparse-0.1.4
	dev-python/setuptools"

S="${WORKDIR}/${MY_P}"
