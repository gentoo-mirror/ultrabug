# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit eutils user

DESCRIPTION="Web UI based monitoring tool for Aerospike Community Edition Server"
HOMEPAGE="http://www.aerospike.com"
SRC_URI="http://www.aerospike.com/artifacts/${PN}/${PV}/${P}.all.x86_64.deb"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="app-crypt/gcr"
DEPEND="${RDEPEND}"

src_unpack() {
	default
	mkdir "${P}"
	tar -xzf data.tar.gz -C "${S}" || die
}

src_install() {
	tar -xzf opt/amc.tar.gz -C opt/ || die
	rm opt/amc.tar.gz

	mv opt/amc/amc/* opt/amc/
	rm -rf opt/amc/amc
	rm -f opt/amc/install
	rm -f opt/amc/bin/uninstall
	rm -f opt/amc/bin/amc_*.sh

	insinto /etc/logrotate.d
	newins opt/amc/config/logrotate amc
	rm -f opt/amc/config/logrotate

	insinto /etc/cron.daily
	newins opt/amc/config/logcron amc
	rm -f opt/amc/config/logcron

	sed -e 's@/tmp/amc.pid@/run/amc.pid@g' -i opt/amc/config/gunicorn_config.py

	insinto /etc/amc/config
	doins -r opt/amc/config/*
	rm -rf opt/amc/config/

	echo "${PV}" > opt/amc/amc_version

	insinto /opt/amc/
	doins -r opt/amc/*

	keepdir /var/log/amc
	fperms +x /opt/amc/bin/gunicorn

	newinitd "${FILESDIR}"/amc.init amc
}
