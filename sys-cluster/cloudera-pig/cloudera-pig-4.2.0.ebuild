# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils java-utils-2

MY_PV="0.10.0"
MY_PN="pig"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Cloudera’s Distribution for Apache Pig"
HOMEPAGE="http://pig.apache.org/"
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

S=${WORKDIR}/pig-"${MY_PV}"-cdh"${PV}"

src_install() {
	# config dir
	JAVA_HOME=$(java-config -g JAVA_HOME)
	echo "JAVA_HOME=${JAVA_HOME}" > conf/pig-env.sh
	insinto ${CONFIG_DIR}
	doins conf/*

	# lib dir
	insinto /usr/lib/"${MY_PN}"
	doins -r bin lib
	doins pig-0.10.0-cdh4.2.0-withouthadoop.jar
	dosym ${CONFIG_DIR} /usr/lib/"${MY_PN}"/conf

	# bin
	dobin "${FILESDIR}"/pig
	fperms 755 /usr/lib/pig/bin/pig
}
