# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils user

DESCRIPTION="Distributed key-value database management system"
HOMEPAGE="http://www.couchbase.com"
SRC_URI="http://packages.couchbase.com/releases/${PV}/${PN}_${PV}-debian7_amd64.deb"

LICENSE="COUCHBASE_COMMUNITY_EDITION"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="sys-libs/ncurses:5=[tinfo]
		>=dev-libs/libevent-1.4.13
		>=dev-libs/cyrus-sasl-2
		>=media-video/rtmpdump-2.4
		virtual/jre:*"
DEPEND="${RDEPEND}"

export CONFIG_PROTECT="${CONFIG_PROTECT} /opt/${PN}/var/lib/${PN}/"

S=${WORKDIR}

pkg_setup() {
	enewgroup couchbase
	enewuser couchbase -1 /bin/bash /opt/couchbase couchbase
}

src_unpack() {
	ar x "${DISTDIR}"/${A}
	cd "${WORKDIR}"
	tar xzf data.tar.gz
}

src_prepare() {
	default
}

src_install() {
	# basic cleanup
	rm -rf opt/couchbase/etc/{couchbase_init.d,couchbase_init.d.tmpl,init.d}
	find opt/couchbase/var/lib/couchbase/ -type f -delete || die

	# bin install / copy
	dodir /opt/couchbase
	cp -a opt/couchbase/* "${D}"/opt/couchbase/

	dodir /opt/couchbase/var/lib/couchbase/{data,mnesia,tmp}

	fperms o+x /opt/couchbase/lib/python/pysqlite2/
	fperms -R o+r /opt/couchbase/lib/python/pysqlite2/
	fowners -R couchbase:couchbase /opt/couchbase/

	doinitd "${FILESDIR}"/couchbase-server
	dosym /opt/couchbase/etc/logrotate.d/couchdb /etc/logrotate.d/couchdb

	insinto /etc/security/limits.d/
	doins "${FILESDIR}"/90-couchbase.conf
}
