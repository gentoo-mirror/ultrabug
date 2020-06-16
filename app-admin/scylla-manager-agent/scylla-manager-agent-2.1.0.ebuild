# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit user

MY_V="2.1.0-0.20200611.9be1c609"

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
S=${WORKDIR}

pkg_setup() {
	enewgroup scylla-manager
	enewuser scylla-manager -1 -1 /var/lib/${PN} scylla-manager
}

src_unpack() {
	for rpm in ${A}; do
		rpmunpack "${DISTDIR}/${rpm}" || die
	done
}

src_install() {
	default

	keepdir /var/lib/scylla-manager
	fowners scylla-manager:scylla-manager "/var/lib/scylla-manager"

	insinto /etc
	doins -r */etc/*

	rm -rf */usr/share || die
	rm -rf */usr/lib/systemd || die

	insinto /usr
	doins -r */usr/*

	fperms +x /usr/bin/scylla-manager-agent
	fperms +x /usr/lib/scylla-manager/scyllamgr_agent_setup
	fperms +x /usr/lib/scylla-manager/scyllamgr_auth_token_gen
	fperms +x /usr/lib/scylla-manager/scyllamgr_ssl_cert_gen

	newinitd "${FILESDIR}/scylla-manager-agent.initd" ${PN}
}
