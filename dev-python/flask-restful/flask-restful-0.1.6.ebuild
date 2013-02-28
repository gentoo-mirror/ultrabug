# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

EAPI="4"
PYTHON_DEPEND="*:2.6"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="2.4 2.5"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="Flask-RESTful"
MY_P="${MY_PN}-${PV/_/-}"

DESCRIPTION="Simple framework for creating REST APIs with Flask"
HOMEPAGE="https://github.com/twilio/flask-restful"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-python/flask-0.8
	>=dev-python/pycrypto-2.6"
RDEPEND="${DEPEND}
	dev-python/nose"

S="${WORKDIR}/${MY_P}"
