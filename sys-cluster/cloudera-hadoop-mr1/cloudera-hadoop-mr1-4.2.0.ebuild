# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils java-utils-2 versionator

MY_PV="2.0.0"
MY_PN="hadoop-0.20-mapreduce"
MY_P="${MY_PN}-${PV}"
MY_V=$(get_version_component_range 1-3)
if [[ "$(get_libdir)" == "lib64" ]]; then
	MY_ARCH='Linux-amd64-64'
else
	MY_ARCH='Linux-i386-32'
fi

DESCRIPTION="Cloudera Distribution for Apache Hadoop MapReduce v1"
HOMEPAGE="http://hadoop.apache.org"
SRC_URI="http://archive.cloudera.com/cdh4/cdh/4/mr1-${MY_PV}-mr1-cdh${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
IUSE=""

DEPEND="~sys-cluster/cloudera-hadoop-${MY_V}[hdfs,-mapreduce]"
RDEPEND=">=virtual/jre-1.6
	dev-java/java-config-wrapper"

CONFIG_DIR=/etc/hadoop/conf
export CONFIG_PROTECT="${CONFIG_PROTECT} ${CONFIG_DIR}"

S=${WORKDIR}/hadoop-"${MY_PV}"-mr1-cdh"${PV}"

pkg_setup() {
	enewgroup mapred
	enewuser mapred -1 /bin/bash /usr/lib/"${MY_PN}" "mapred,hadoop"
}

src_configure() {
	pushd src/c++/task-controller
		econf --bindir=/"${MY_ARCH}"
	popd
	pushd src/c++/utils
		econf --libdir=/
	popd
	pushd src/c++/pipes
		# fix gcc-4.7
		sed -i -e '18i#include <unistd.h>' impl/HadoopPipes.cc || die
		econf --libdir=/ --with-hadoop-utils="${S}"/c++/"${MY_ARCH}"/
	popd
}

src_compile() {
	# make task-controller
	pushd src/c++/task-controller
		emake DESTDIR=./ install
	popd

	# make the native libs
	pushd src/c++/utils
		emake DESTDIR=./ install
	popd
	pushd src/c++/pipes
		emake DESTDIR=./ install
	popd
}

src_install() {
	# remove useless scripts and already provided jars
	rm bin/start-mapred.sh bin/stop-mapred.sh || die
	rm lib/slf4j-log4j*.jar || die

	# lib
	diropts -m755 -o root -g root
	insinto /usr/lib/"${MY_PN}"
	doins -r bin contrib example-confs ivy lib webapps
	fperms 0755 /usr/lib/"${MY_PN}"/bin/{hadoop,hadoop-config.sh,hadoop-daemon.sh,hadoop-daemons.sh,rcc,slaves.sh}

	doins -r *.jar *.xml
	doins -r c++/"${MY_ARCH}"/include
	for name in "ant" "core" "examples" "test" "tools"; do
		dosym hadoop-"${name}"-"${MY_PV}"-mr1-cdh"${PV}".jar /usr/lib/"${MY_PN}"/hadoop-"${name}".jar
		dosym hadoop-"${name}"-"${MY_PV}"-mr1-cdh"${PV}".jar /usr/lib/"${MY_PN}"/hadoop-"${MY_PV}"-mr1-cdh"${PV}"-"${name}".jar
	done

	# task-controller
	insinto /usr/lib/"${MY_PN}"/sbin/"${MY_ARCH}"
	doins src/c++/task-controller/task-controller
	fowners root:mapred /usr/lib/"${MY_PN}"/sbin/"${MY_ARCH}"/task-controller
	fperms 4754 /usr/lib/"${MY_PN}"/sbin/"${MY_ARCH}"/task-controller

	# static-libs
	insinto /usr/lib/"${MY_PN}"/lib/native
	doins src/c++/utils/libhadooputils.a
	doins src/c++/pipes/libhadooppipes.a
	ln -s ../../../hadoop/lib/native/ "${D}"/usr/lib/"${MY_PN}"/lib/native/"${MY_ARCH}" || die

	# bin
	dobin "${FILESDIR}"/hadoop-0.20
	fperms 755 /usr/lib/"${MY_PN}"/bin/hadoop

	# conf
	dosym "${CONFIG_DIR}" /usr/lib/"${MY_PN}"/conf

	# limits.d
	insinto /etc/security/limits.d
	newins "${FILESDIR}"/mapred.limitsd mapred.conf

	# home and log dir
	diropts -m775 -o root -g hadoop
	dodir /var/log/"${MY_PN}" /var/lib/"${MY_PN}"
	dodir /var/lib/"${MY_PN}"/cache /var/lib/"${MY_PN}"/cache/hadoop
	fperms 1777 /var/lib/"${MY_PN}"/cache

	# init script
	newinitd "${FILESDIR}"/hadoop-0.20.initd hadoop-0.20
	for daemon in "tasktracker" "jobtracker"; do
		dosym hadoop-0.20 /etc/init.d/hadoop-0.20-"${daemon}"
	done
}

pkg_config() {
	einfo "Setting up HDFS /tmp directory"
	su hdfs -- hdfs dfs -mkdir /tmp
	su hdfs -- hdfs dfs -chmod 777 /tmp
}
