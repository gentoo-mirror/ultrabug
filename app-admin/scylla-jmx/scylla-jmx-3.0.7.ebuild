# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/scylladb/scylla-jmx.git"
	inherit git-r3
else
	MY_PV="${PV/_rc/.rc}"
	MY_P="${PN}-${MY_PV}"
	SRC_URI="https://github.com/scylladb/${PN}/archive/scylla-${MY_PV}.tar.gz -> ${MY_P}.tar.gz"
	KEYWORDS="~amd64"
	S="${WORKDIR}/scylla-jmx-scylla-${MY_PV}"
fi

PYTHON_COMPAT=( python2_7 )

inherit java-pkg-2 python-r1 systemd user

DESCRIPTION="Scylla JMX"
HOMEPAGE="https://github.com/scylladb/scylla-jmx"

LICENSE="Apache-2.0"
SLOT="0"

CDEPEND="dev-java/maven-bin:3.3"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${CDEPEND}
	${PYTHON_DEPS}
	>=virtual/jre-1.8"

DEPEND="
	${CDEPEND}
	>=virtual/jdk-1.8
	dev-python/pystache[${PYTHON_USEDEP}]"

RESTRICT="test"

pkg_setup() {
	enewgroup scylla
	enewuser scylla -1 -1 /var/lib/${PN} scylla
}

src_prepare() {
	default

	# fix symlink runtime error on scylla-jmx script
	# * scylla-jmx is not available for oracle-jdk-bin-1.8 on x86_64
	# * IMPORTANT: some Java tools are not available on some VMs on some architectures
	sed -e 's@"$LOCATION_SCRIPTS"/symlinks/scylla-jmx@/usr/bin/java@g' -i scripts/scylla-jmx || die
}

src_compile() {
	mvn -B install || die
}

src_install() {
	default

	insinto /etc/default
	doins dist/common/sysconfig/scylla-jmx

	insinto /usr/lib/scylla/jmx
	doins target/scylla-jmx-1.0.jar

	# removed because of src_prepare fix
	#dodir /usr/lib/scylla/jmx/symlinks
	#dosym /usr/bin/java /usr/lib/scylla/jmx/symlinks/scylla-jmx

	exeinto /usr/lib/scylla/jmx
	doexe scripts/scylla-jmx

	newinitd "${FILESDIR}/scylla-jmx.initd" ${PN}
	newconfd "${FILESDIR}/scylla-jmx.confd" ${PN}

	local MUSTACHE_DIST="\"debian\": true"
	pystache dist/common/systemd/scylla-jmx.service.mustache "{ $MUSTACHE_DIST }" > scylla-jmx.service
	systemd_dounit scylla-jmx.service
}

pkg_postinst() {
	ping -c1 `hostname` > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		ewarn
		ewarn "**************************************************************"
		ewarn "* WARNING: You need to add hostname on /etc/hosts, otherwise *"
		ewarn "*          scylla-jmx will not able to start up.             *"
		ewarn "**************************************************************"
		ewarn
	fi
}
