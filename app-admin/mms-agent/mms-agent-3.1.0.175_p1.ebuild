# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-db/mongodb/mongodb-2.6.8.ebuild,v 1.1 2015/02/27 09:55:48 ultrabug Exp $

EAPI=5

inherit eutils

MY_PV=${PV/_p/-}

DESCRIPTION="A high-performance, open source, schema-free document-oriented database"
HOMEPAGE="http://www.mongodb.org"
SRC_URI="
	monitoring? (
		amd64? ( https://mms.mongodb.com/download/agent/monitoring/mongodb-mms-monitoring-agent-${MY_PV}.linux_x86_64.tar.gz )
		x86? ( https://mms.mongodb.com/download/agent/monitoring/mongodb-mms-monitoring-agent-${MY_PV}.linux_i386.tar.gz )
	)
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+monitoring"

REQUIRED_USE="|| ( monitoring )"

RDEPEND=""
DEPEND=""

S=${WORKDIR}

src_install() {
	if use amd64; then
		local arch="x86_64"
	else
		local arch="i386"
	fi

	if use monitoring; then
		local MY_PN="mms-monitoring-agent"
		local MY_D="/opt/${MY_PN}"

		pushd "${S}/mongodb-mms-monitoring-agent-${MY_PV}.linux_${arch}"

		insinto ${MY_D}
		doins mongodb-mms-monitoring-agent

		insinto /etc
		doins monitoring-agent.config
		rm monitoring-agent.config
		dosym /etc/monitoring-agent.config ${MY_D}/monitoring-agent.config

		fowners -R mongodb:mongodb ${MY_D}
		newinitd "${FILESDIR}/${MY_PN}.initd" ${MY_PN}

		popd
	fi
}

pkg_postinst() {
	if use monitoring; then
		elog "MMS Monitoring Agent configuration file :"
		elog "  /etc/monitoring-agent.config"
	fi
}