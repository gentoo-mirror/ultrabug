# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_V="2.3.0-0.20210322.74f75d4a"

inherit user

DESCRIPTION="Scylla Manager Agent"
HOMEPAGE="https://docs.scylladb.com/operating-scylla/manager/2.0/install-agent"
SRC_URI="${PN}-${MY_V}.x86_64.rpm"

LICENSE="SCYLLADB-PROPRIETARY"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	app-arch/rpm2targz
"
DEPEND="${RDEPEND}"

RESTRICT="fetch"
S="${WORKDIR}/${PN}-${MY_V}.x86_64"

pkg_setup() {
	enewgroup scylla-manager
	enewuser scylla-manager -1 -1 /var/lib/scylla-manager scylla-manager
}

src_unpack() {
	for rpm in ${A}; do
		rpmunpack "${DISTDIR}/${rpm}" || die
	done
}

src_prepare() {
	default
	rm -rf usr/share || die
}

src_install() {
	default

	keepdir /var/lib/scylla-manager
	fowners scylla-manager:scylla-manager "/var/lib/scylla-manager"

	insinto /etc
	doins -r etc/*

	insinto /usr
	doins -r usr/*

	fperms +x /usr/bin/scylla-manager-agent
	fperms +x /usr/lib/scylla-manager/scyllamgr_agent_setup
	fperms +x /usr/lib/scylla-manager/scyllamgr_auth_token_gen
	fperms +x /usr/lib/scylla-manager/scyllamgr_ssl_cert_gen

	newinitd "${FILESDIR}/scylla-manager-agent.initd" ${PN}
}

pkg_config() {
	usermod -ou $(id -u scylla) scylla-manager || die "failed to alias scylla-manager to scylla user"
	/usr/lib/scylla-manager/scyllamgr_agent_setup -y --no-enable-service
}
