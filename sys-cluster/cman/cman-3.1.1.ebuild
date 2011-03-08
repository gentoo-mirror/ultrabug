# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit linux-info multilib toolchain-funcs versionator

CLUSTER_RELEASE="${PV}"
MY_P="cluster-${CLUSTER_RELEASE}"

MAJ_PV="$(get_major_version)"
MIN_PV="$(get_version_component_range 2).$(get_version_component_range 3)"

DESCRIPTION="Cluster Manager"
HOMEPAGE="http://sources.redhat.com/cluster/wiki/"
SRC_URI="https://fedorahosted.org/releases/c/l/cluster/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-libs/libxml2
	sys-cluster/corosync
	~sys-cluster/libccs-${PV}
	~sys-cluster/libfence-${PV}
	~sys-cluster/libcman-${PV}
	~sys-cluster/libdlm-${PV}
	~sys-cluster/libdlmcontrol-${PV}
	~sys-cluster/liblogthread-${PV}"
DEPEND="${RDEPEND}
    >=sys-kernel/linux-headers-2.6.24"

S="${WORKDIR}/${MY_P}"

# TODO:
# * man pages for functions and libs should be installed by the corresponding
#   lib ebuilds
# * Gentoo'ise the init script
# * fix magic dep on openldap

src_configure() {
	# cluster libs have their own separate packages
	sed -i -e 's|lib||' "${S}/cman/Makefile" || die
	sed -i -e 's|liblogthread||' "${S}/common/Makefile" || die
	sed -i -e 's|libs||' "${S}/config/Makefile" || die
	sed -i -e 's|libdlm libdlmcontrol||' "${S}/dlm/Makefile" || die
	sed -i -e 's|libfence libfenced||' "${S}/fence/Makefile" || die
	sed -i -e 's|fence/libfenced||' "${S}/Makefile" || die

	sed -i \
		-e 's|\(^all:.*\)depends |\1|' \
		config/tools/ccs_tool/Makefile \
		fence/fence{d,_node,_tool}/Makefile \
		cman/{cman_tool,daemon,tests,qdisk,notifyd}/Makefile \
		dlm/{tool,tests/usertest}/Makefile \
		|| die "sed failed"

	./configure \
		--cc=$(tc-getCC) \
		--cflags="-Wall" \
		--libdir=/usr/$(get_libdir) \
		--disable_kernel_check \
		--kernel_src=${KERNEL_DIR} \
		--somajor="$MAJ_PV" \
		--sominor="$MIN_PV" \
		--without_rgmanager \
		--without_bindings \
		|| die "configure problem"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake failed"

	keepdir /var/{lib,log,run}/cluster

	rm -rf "${D}/usr/share/doc"
	dodoc \
		doc/{usage.txt,cman_notify_template.sh} \
		config/plugins/ldap/*.ldif
	dohtml doc/*.html
}
