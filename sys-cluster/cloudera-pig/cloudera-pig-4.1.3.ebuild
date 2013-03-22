# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils java-utils-2

DESCRIPTION="Cloudera’s Distribution for Apache Hadoop"
HOMEPAGE="https://ccp.cloudera.com"
SRC_URI="
	http://archive.cloudera.com/cdh4/cdh/4/pig-0.10.0-cdh4.1.3.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror binchecks"
IUSE=""

DEPEND=""
RDEPEND=">=virtual/jre-1.6
	net-misc/openssh
	net-misc/rsync"

MY_PN="pig"
MY_P="${MY_PN}-${PV}"

S=${WORKDIR}/pig-0.10.0-cdh4.1.3
INSTALL_DIR=/opt/cloudera-pig
export CONFIG_PROTECT="${CONFIG_PROTECT} ${INSTALL_DIR}/conf"

src_install() {
	sed -i -e '/^export PIG_HOME/d' ${S}/bin/pig || die

	# env file
	cat > 99pig <<-EOF
		PIG_HOME="${INSTALL_DIR}"
		PIG_CONF_DIR="${INSTALL_DIR}/conf"
		CONFIG_PROTECT="${INSTALL_DIR}/conf"
	EOF
	doenvd 99pig || die "doenvd failed"

	# bin
	dobin bin/pig

	# install dir
	dodir "${INSTALL_DIR}"
	mv "${S}"/* "${D}${INSTALL_DIR}" || die "install failed"
	chown -Rf root:hadoop "${D}${INSTALL_DIR}"
}
