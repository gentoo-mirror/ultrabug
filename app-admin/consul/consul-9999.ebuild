# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="tool for service discovery, monitoring and configuration."
HOMEPAGE="http://www.consul.io"
SRC_URI=""

EGIT_REPO_URI="git://github.com/hashicorp/consul.git"
S="${WORKDIR}/src/github.com/hashicorp/${PN}"

if [[ ${PV} == *9999 ]]; then
	KEYWORDS=""
else
	EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~x86"
fi

inherit git-2 user

LICENSE="MPL-2.0"
SLOT="0"
IUSE="web"

DEPEND=">=dev-lang/go-1.4
	dev-vcs/git
	dev-vcs/mercurial
	web? ( dev-ruby/bundler dev-ruby/sass )"
RDEPEND="${DEPEND}"

pkg_setup() {
	enewgroup consul
	enewuser consul -1 -1 /var/lib/${PN} consul
}

src_compile() {
	# create a suitable GOPATH
	export GOPATH="${WORKDIR}"

	# let's do something fun
	emake

	# build the web UI
	if use web; then
		cd ui
		bundle
		emake dist
	fi
}

src_install() {
	dobin bin/consul

	dodir /etc/consul.d

	for x in /var/{lib,log}/${PN}; do
		keepdir "${x}"
		fowners consul:consul "${x}"
	done

	if use web; then
		insinto /var/lib/${PN}/ui
		doins -r ui/dist/*
	fi

	newinitd "${FILESDIR}/consul-agent.initd" "${PN}-agent"
	newconfd "${FILESDIR}/consul-agent.confd" "${PN}-agent"
}
