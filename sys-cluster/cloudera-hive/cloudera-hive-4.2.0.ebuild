# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils java-utils-2

MY_PV="0.10.0"
MY_PN="hive"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Cloudera’s Distribution for Apache Hive"
HOMEPAGE="http://hive.apache.org"
SRC_URI="http://archive.cloudera.com/cdh4/cdh/4/${MY_PN}-${MY_PV}-cdh${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror binchecks"
IUSE=""

DEPEND="=sys-cluster/cloudera-hadoop-${PV}"
RDEPEND=">=virtual/jre-1.6
	dev-java/java-config-wrapper"

CONFIG_DIR=/etc/"${MY_PN}"/conf
export CONFIG_PROTECT="${CONFIG_PROTECT} ${CONFIG_DIR}"

S=${WORKDIR}/hive-"${MY_PV}"-cdh"${PV}"

pkg_setup(){
	enewgroup hive
	enewuser hive -1 -1 /var/lib/hive hive
}

src_install() {
	# home and log dir
	diropts -m755 -o hive -g hive
	dodir /var/lib/hive
	dodir /var/log/hive

	# config dir
	diropts -m755 -o root -g root
	cp "${FILESDIR}"/hive-site.xml conf/
	mv conf/hive-exec-log4j.properties.template conf/hive-exec-log4j.properties
	mv conf/hive-log4j.properties.template conf/hive-log4j.properties
	insinto ${CONFIG_DIR}
	doins conf/*

	# lib dir
	insinto /usr/lib/"${MY_PN}"
	doins -r bin lib
	dosym ${CONFIG_DIR} /usr/lib/"${MY_PN}"/conf

	# bin
	dobin "${FILESDIR}"/hive
	dobin "${FILESDIR}"/beeline
	dobin "${FILESDIR}"/hiveserver2
	fperms 755 /usr/lib/hive/bin/hive
	fperms 755 /usr/lib/hive/bin/beeline
	fperms 755 /usr/lib/hive/bin/hiveserver2

	# init script
	newinitd "${FILESDIR}"/"${MY_PN}".initd "${MY_PN}"-metastore
	newconfd "${FILESDIR}"/"${MY_PN}".confd "${MY_PN}"-metastore
	newinitd "${FILESDIR}"/"${MY_PN}".initd "${MY_PN}"-server
	newconfd "${FILESDIR}"/"${MY_PN}".confd "${MY_PN}"-server
	newinitd "${FILESDIR}"/"${MY_PN}".initd "${MY_PN}"-server2
	newconfd "${FILESDIR}"/"${MY_PN}".confd "${MY_PN}"-server2
}

pkg_config() {
	hadoop_username=hdfs

	# Set up directories on HDFS
	einfon "Setting up hive metastore directories on HDFS"
	su -s /bin/bash - ${hadoop_username} -c 'hadoop fs -mkdir /tmp'
	su -s /bin/bash - ${hadoop_username} -c 'hadoop fs -mkdir /user/hive/warehouse'
	su -s /bin/bash - ${hadoop_username} -c 'hadoop fs -chmod g+w /tmp'
	su -s /bin/bash - ${hadoop_username} -c 'hadoop fs -chmod g+w /user/hive/warehouse'

	# Ensure sticky bit on metastore dir
	chmod 1777 /var/lib/hive/metastore
}
