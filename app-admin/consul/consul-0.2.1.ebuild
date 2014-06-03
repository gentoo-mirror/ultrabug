# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="tool for service discovery, monitoring and configuration."
HOMEPAGE="http://www.consul.io"
SRC_URI=""

EGIT_REPO_URI="git://github.com/hashicorp/consul.git"
if [[ ${PV} == *9999 ]]; then
	KEYWORDS=""
else
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~x86"
fi

inherit git-2

LICENSE="MPL-2.0"
SLOT="0"
IUSE=""

DEPEND="
	>=dev-lang/go-1.2
	dev-vcs/git
"
RDEPEND="${DEPEND}"

src_prepare() {
	# see : https://github.com/hashicorp/consul/pull/188
	sed -e 's/format:/format: deps/g' -i Makefile
}

src_compile() {
	# create a suitable GOPATH
	export GOPATH="${WORKDIR}/gopath"
	mkdir -p "$GOPATH" || die

	local MY_S="${GOPATH}/src/github.com/hashicorp/consul"

	# make sure consul itself is in our GOPATH
	mkdir -p "${GOPATH}/src/github.com/hashicorp" || die
	mv "${S}" "${MY_S}" || die
	ln -sf "${MY_S}" "${S}"

	# let's do something fun
	emake
}

src_install() {
	dobin bin/consul
}
