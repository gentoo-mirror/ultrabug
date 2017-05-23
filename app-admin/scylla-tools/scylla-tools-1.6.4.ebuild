# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

JAVA_PKG_IUSE="source doc"

inherit java-pkg-2 java-ant-2

MY_PN="${PN%%-*}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="scylla tools (Java part)"
HOMEPAGE="https://github.com/scylladb/scylla-tools-java"
SRC_URI="
	https://github.com/scylladb/${PN}-java/archive/${MY_P}.tar.gz -> ${P}.tar.gz
	https://repo1.maven.org/maven2/net/nicoulaj/compile-command-annotations/compile-command-annotations/1.2.1/compile-command-annotations-1.2.1.jar
	https://repo1.maven.org/maven2/com/google/code/findbugs/jsr305/3.0.2/jsr305-3.0.2.jar
	https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-core/0.20.2/hadoop-core-0.20.2.jar
	https://repo1.maven.org/maven2/org/apache/pig/pig/0.8.0/pig-0.8.0.jar
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

CDEPEND="dev-java/antlr:3.5"
RDEPEND="
	${CDEPEND}
	>=virtual/jre-1.8"
DEPEND="
	${CDEPEND}
	>=virtual/jdk-1.8"

S="${WORKDIR}/${PN}-java-scylla-${PV}"

EANT_BUILD_TARGET="jar"

RESTRICT="test"

src_prepare() {
	default
	find examples -type f -name \*.xml -exec rm -v {} \; || die
	cp -v "${FILESDIR}/${P}-build.xml" "${S}/build.xml" || die
	cp -v "${DISTDIR}"/*.jar lib || die
}

#src_install() {
#	java-pkg_newjar "build/apache-cassandra-clientutils-2.1.8.jar" "apache-cassandra-clientutils.jar"
#	java-pkg_newjar "build/apache-cassandra-thrift-2.1.8.jar" "apache-cassandra-thrift.jar"
#	java-pkg_newjar "build/apache-cassandra-2.1.8.jar" "apache-cassandra.jar"
#}
