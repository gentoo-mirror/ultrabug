# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

MY_V="2.1.2-0.20200816.76cc4dcc"

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

src_unpack() {
	for rpm in ${A}; do
		rpmunpack "${DISTDIR}/${rpm}" || die
	done
}

src_prepare() {
	default
	sed -e 's/User=scylla-manager/User=scylla/g' -i usr/lib/systemd/system/*.service || die
	sed -e 's/Group=scylla-manager/User=scylla/g' -i usr/lib/systemd/system/*.service || die

	rm -rf usr/share || die
}

src_install() {
	default

	keepdir /var/lib/scylla-manager
	fowners scylla:scylla "/var/lib/scylla-manager"

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
	/usr/lib/scylla-manager/scyllamgr_agent_setup -y --no-enable-service
}
