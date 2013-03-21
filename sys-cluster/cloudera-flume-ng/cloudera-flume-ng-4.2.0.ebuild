# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils java-utils-2

MY_PV="1.3.0"
MY_PN="flume-ng"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Cloudera’s Distribution for Apache Flume"
HOMEPAGE="http://flume.apache.org"
SRC_URI="http://archive.cloudera.com/cdh4/cdh/4/${MY_PN}-${MY_PV}-cdh${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror binchecks"
IUSE=""

DEPEND="=sys-cluster/cloudera-hadoop-${PV}"
RDEPEND=">=virtual/jre-1.6"

CONFIG_DIR=/etc/"${MY_PN}"/conf
export CONFIG_PROTECT="${CONFIG_PROTECT} ${CONFIG_DIR}"

S=${WORKDIR}/apache-flume-"${MY_PV}"-cdh"${PV}"-bin

pkg_setup(){
	enewgroup flume
	enewuser flume -1 -1 /var/lib/flume-ng flume
}

src_install() {
	# home and log dir
	diropts -m755 -o flume -g flume
	dodir /var/lib/flume-ng
	dodir /var/log/flume-ng

	# config dir
	diropts -m755 -o root -g root
	touch conf/flume.conf
	cp conf/flume-env.sh.template conf/flume-env.sh
	JAVA_HOME=$(java-config -g JAVA_HOME)
	sed -i -e "s@#JAVA_HOME=.*@JAVA_HOME=${JAVA_HOME}@g" conf/flume-env.sh || die
	sed -i -e "s@flume.log.dir=./logs@flume.log.dir=/var/log/${MY_PN}@g" conf/log4j.properties || die
	insinto ${CONFIG_DIR}
	doins conf/*

	# lib dir
	insinto /usr/lib/"${MY_PN}"
	doins -r bin lib
	dosym ${CONFIG_DIR} /usr/lib/"${MY_PN}"/conf

	# bin
	dobin bin/flume-ng

	# init script
	newinitd "${FILESDIR}"/"${MY_PN}".initd "${MY_PN}"
	newconfd "${FILESDIR}"/"${MY_PN}".confd "${MY_PN}"
}
