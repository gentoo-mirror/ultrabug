# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

CMAKE_VERBOSE="OFF"
EGIT_REPO_URI="https://github.com/ContinuumIO/libhdfs3-downstream.git"

inherit cmake-utils git-r3

DESCRIPTION="A Native C/C++ HDFS Client"
HOMEPAGE="https://github.com/ContinuumIO/libhdfs3-downstream/"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-cpp/gtest[static-libs]
	dev-cpp/gmock[static-libs]
	dev-libs/libxml2
	dev-libs/protobuf
	net-libs/libgsasl[kerberos]
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}/libhdfs3"

src_prepare() {
	cmake-utils_src_prepare
	sed -e "s/DESTINATION lib/DESTINATION $(get_libdir)/g" -i src/CMakeLists.txt || die
}
