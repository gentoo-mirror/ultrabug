# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit user

MY_V="1.3.1-0.20190124.08fc477"

DESCRIPTION="Scylla Manager"
HOMEPAGE="http://docs.scylladb.com/operating-scylla/manager/"
SRC_URI="${PN}-${MY_V}.x86_64.rpm ${PN}-client-${MY_V}.x86_64.rpm ${PN}-server-${MY_V}.x86_64.rpm"

LICENSE="SCYLLADB-PROPRIETARY"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
	app-arch/rpm2targz
	dev-db/scylla
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
	fowners scylla-manager:scylla-manager "/var/lib/${PN}"

	insinto /etc
	doins -r */etc/*

	insinto /usr
	doins -r */usr/*

	fperms +x /usr/bin/scylla-manager
	fperms +x /usr/bin/sctool
	fperms +x /usr/lib/scylla-manager/scyllamgr_setup
	fperms +x /usr/lib/scylla-manager/scyllamgr_ssh_setup
	fperms +x /usr/lib/scylla-manager/scyllamgr_ssh_test
	fperms +x /usr/lib/scylla-manager/scyllamgr_ssl_cert_gen

	newinitd "${FILESDIR}/scylla-manager.initd" ${PN}
}
