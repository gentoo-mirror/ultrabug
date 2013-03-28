# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils java-utils-2

MY_PV="2.0.0"
MY_PN="hadoop"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Cloudera’s Distribution for Apache Hadoop"
HOMEPAGE="http://hadoop.apache.org"
SRC_URI="http://archive.cloudera.com/cdh4/cdh/4/${MY_PN}-${MY_PV}-cdh${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror" # binchecks
IUSE="hdfs mapreduce"

#TODO: mapreduce use is missing hadoop-yarn dep
DEPEND=">=dev-java/maven-bin-3.0"
RDEPEND=">=virtual/jre-1.6
	dev-java/java-config-wrapper
	=dev-libs/protobuf-2.4.0a"

CONFIG_DIR=/etc/"${MY_PN}"/conf
export CONFIG_PROTECT="${CONFIG_PROTECT} ${CONFIG_DIR}"

S=${WORKDIR}/hadoop-"${MY_PV}"-cdh"${PV}"

pkg_setup(){
	enewgroup hadoop
	if use hdfs; then
		enewgroup hdfs
		enewuser hdfs -1 /bin/bash /var/lib/hdfs "hdfs,hadoop"
	fi
	if use mapreduce; then
		enewgroup mapred
		enewuser mapred -1 /bin/bash /var/lib/hadoop-mapreduce "mapred,hadoop"
	fi
}

src_compile() {
	export JAVA_HOME=$(java-config -g JAVA_HOME)

	pushd src
		mvn package -DskipTests -Pnative || die
	popd
}

install_hdfs() {
	diropts -m755 -o root -g root
	pushd src/hadoop-hdfs-project/hadoop-hdfs/target
		insinto /usr/$(get_libdir)
		dolib.so native/target/usr/local/lib/libhdfs.so.0.0.0
		#
		insinto /usr/lib/hadoop-hdfs
		doins hadoop-hdfs-"${MY_PV}"-cdh"${PV}".jar
		doins hadoop-hdfs-"${MY_PV}"-cdh"${PV}"-tests.jar
		dosym hadoop-hdfs-"${MY_PV}"-cdh"${PV}".jar /usr/lib/hadoop-hdfs/hadoop-hdfs.jar
		#
		doins -r webapps
	popd
	doins -r share/hadoop/hdfs/lib

	insinto /usr/lib/hadoop-hdfs/bin
	doins bin/hdfs
	fperms 755 /usr/lib/hadoop-hdfs/bin/hdfs

	insinto /usr/lib/hadoop-hdfs/sbin
	doins sbin/distribute-exclude.sh
	doins sbin/refresh-namenodes.sh
	fperms 0755 /usr/lib/hadoop-hdfs/sbin/{distribute-exclude.sh,refresh-namenodes.sh}

	insinto /usr/lib/hadoop/libexec
	doins libexec/hdfs-config.sh
	fperms 0755 /usr/lib/hadoop/libexec/hdfs-config.sh

	insinto /etc/security/limits.d
	newins "${FILESDIR}"/hdfs/hdfs.limitsd hdfs.conf

	insinto /etc/hadoop/conf
	doins "${FILESDIR}"/hdfs/hdfs-site.xml

	dobin "${FILESDIR}"/hdfs/hdfs

	diropts -m775 -o root -g hadoop
	dodir /var/log/hadoop-hdfs

	diropts -m775 -o hdfs -g hadoop
	dodir /var/lib/hadoop-hdfs/ /var/lib/hadoop-hdfs/cache
	fperms 1777 /var/lib/hadoop-hdfs/cache

	newinitd "${FILESDIR}"/hdfs/hadoop-hdfs.initd hadoop-hdfs
	for daemon in "datanode" "namenode" "secondarynamenode"; do
		dosym hadoop-hdfs /etc/init.d/hadoop-hdfs-"${daemon}"
	done
}

install_mapreduce() {
	diropts -m755 -o root -g root
	pushd src/hadoop-mapreduce-project
		insinto /usr/lib/hadoop-mapreduce
		for jar in $(find hadoop-mapreduce-client/ -type f -name "*.jar"); do
			doins "${jar}"
		done
		# rename mapreduce-client-app
		mv "${D}"/usr/lib/hadoop-mapreduce/mr-app.jar "${D}"/usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-app-"${MY_PV}"-cdh"${PV}".jar
		mv "${D}"/usr/lib/hadoop-mapreduce/mr-app-tests.jar "${D}"/usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-app-"${MY_PV}"-cdh"${PV}"-tests.jar
		# symlinks
		for categ in "app" "common" "core" "hs" "jobclient" "shuffle"; do
			dosym hadoop-mapreduce-client-"${categ}"-"${MY_PV}"-cdh"${PV}".jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-client-"${categ}".jar
		done
		# examples
		doins hadoop-mapreduce-examples/target/hadoop-mapreduce-examples-"${MY_PV}"-cdh"${PV}".jar
		dosym hadoop-mapreduce-examples-"${MY_PV}"-cdh"${PV}".jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar
	popd
	pushd src/hadoop-tools
		for categ in "archives" "datajoin" "distcp" "extras" "gridmix" "rumen" "streaming"; do
			doins hadoop-"${categ}"/target/hadoop-"${categ}"-"${MY_PV}"-cdh"${PV}".jar
			dosym hadoop-"${categ}"-"${MY_PV}"-cdh"${PV}".jar /usr/lib/hadoop-mapreduce/hadoop-"${categ}".jar
		done
	popd
	doins -r share/hadoop/mapreduce/lib

	insinto /usr/lib/hadoop-mapreduce/bin
	doins bin/mapred
	doins src/hadoop-tools/hadoop-pipes/target/native/examples/*
	fperms 755 /usr/lib/hadoop-mapreduce/bin/{mapred,pipes-sort,wordcount-nopipe,wordcount-part,wordcount-simple}

	insinto /usr/lib/hadoop-mapreduce/sbin
	doins sbin/mr-jobhistory-daemon.sh
	fperms 0755 /usr/lib/hadoop-mapreduce/sbin/mr-jobhistory-daemon.sh

	insinto /usr/lib/hadoop/libexec
	doins libexec/mapred-config.sh
	fperms 0755 /usr/lib/hadoop/libexec/mapred-config.sh

	insinto /etc/security/limits.d
	newins "${FILESDIR}"/mapred/mapreduce.limitsd mapreduce.conf

	insinto /etc/hadoop/conf
	doins "${FILESDIR}"/mapred/mapred-site.xml

	dobin "${FILESDIR}"/mapred/mapred

	diropts -m775 -o root -g hadoop
	dodir /var/log/hadoop-mapreduce

	diropts -m775 -o mapred -g hadoop
	dodir /var/lib/hadoop-mapreduce/ /var/lib/hadoop-mapreduce/cache
	fperms 1777 /var/lib/hadoop-mapreduce/cache
}

src_install() {
	# config dir
	insinto ${CONFIG_DIR}
	for config_file in "core-site.xml" "hadoop-metrics.properties" \
		"hadoop-metrics2.properties" "log4j.properties" "slaves" \
		"ssl-client.xml.example" "ssl-server.xml.example"; do
		doins etc/hadoop/"${config_file}"
	done
	echo "JAVA_HOME='$(java-config -g JAVA_HOME)'" > "${T}"/hadoop-env.sh
	doins "${T}"/hadoop-env.sh

	# /usr/lib dirs
	diropts -m755 -o root -g root
	insinto /usr/lib/"${MY_PN}"

	# common
	pushd src/hadoop-common-project/hadoop-common/target
		doins hadoop-common-"${MY_PV}"-cdh"${PV}".jar
		doins hadoop-common-"${MY_PV}"-cdh"${PV}"-tests.jar
	popd
	dosym hadoop-common-2.0.0-cdh4.2.0.jar /usr/lib/"${MY_PN}"/hadoop-common.jar

	# annotations
	pushd src/hadoop-common-project/hadoop-annotations/target
		doins hadoop-annotations-"${MY_PV}"-cdh"${PV}".jar
	popd
	dosym hadoop-annotations-2.0.0-cdh4.2.0.jar /usr/lib/"${MY_PN}"/hadoop-annotations.jar

	# auth
	pushd src/hadoop-common-project/hadoop-auth/target
		doins hadoop-auth-"${MY_PV}"-cdh"${PV}".jar
	popd
	dosym hadoop-auth-2.0.0-cdh4.2.0.jar /usr/lib/"${MY_PN}"/hadoop-auth.jar

	## bin
	insinto /usr/lib/"${MY_PN}"/bin
	doins bin/hadoop bin/rcc

	## lib
	insinto /usr/lib/"${MY_PN}"/lib
	pushd src/hadoop-tools
		for jar in $(find . -type f -name "*.jar"); do
			doins "${jar}"
		done
	popd
	find "${D}"/usr/lib/"${MY_PN}"/lib -type f -name "hadoop-*.jar" -delete

	## lib/native
	insinto /usr/lib/"${MY_PN}"/lib/native
	doins src/hadoop-hdfs-project/hadoop-hdfs/target/native/target/usr/local/lib/libhdfs.a
	doins src/hadoop-tools/hadoop-pipes/target/native/libhadooputils.a
	doins src/hadoop-tools/hadoop-pipes/target/native/libhadooppipes.a
	doins src/hadoop-common-project/hadoop-common/target/native/target/usr/local/lib/libhadoop.a
	#
	doins src/hadoop-common-project/hadoop-common/target/native/target/usr/local/lib/libhadoop.so
	doins src/hadoop-common-project/hadoop-common/target/native/target/usr/local/lib/libhadoop.so.1.0.0

	## libexec
	insinto /usr/lib/"${MY_PN}"/libexec
	doins libexec/hadoop-config.sh
	doins "${FILESDIR}"/hadoop-layout.sh
	fperms 0755 /usr/lib/"${MY_PN}"/libexec/{hadoop-config.sh,hadoop-layout.sh}

	## sbin
	insinto /usr/lib/"${MY_PN}"/sbin
	doins sbin/hadoop-daemon.sh sbin/hadoop-daemons.sh sbin/slaves.sh
	fperms 0755 /usr/lib/"${MY_PN}"/sbin/{hadoop-daemon.sh,hadoop-daemons.sh,slaves.sh}

	## conf
	dosym ${CONFIG_DIR} /usr/lib/"${MY_PN}"/etc/hadoop

	# bin
	dobin "${FILESDIR}"/hadoop
	fperms 0755 /usr/lib/hadoop/bin/hadoop

	# HDFS ?
	use hdfs && install_hdfs

	# MAPREDUCE ?
	use mapreduce && install_mapreduce
}
