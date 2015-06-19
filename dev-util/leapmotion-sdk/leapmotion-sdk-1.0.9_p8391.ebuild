# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

MY_PYP_N=${PV/_p/.}
MY_PVP=${PV/_p/+}
MY_PV=${PV%_p*}

PYTHON_COMPAT=( python{2_6,2_7} )

inherit eutils multilib python-r1

DESCRIPTION="LeapMotion DeveloperKit SDK"
HOMEPAGE="http://www.leapmotion.com/"
SRC_URI="LeapDeveloperKit_release_linux_${MY_PVP}.tgz"

LICENSE="LeapMotionSDK"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE="doc examples"

RESTRICT="fetch"
QA_PREBUILT="*"

S="${WORKDIR}/LeapDeveloperKit"

pkg_nofetch() {
	ewarn "Please visit https://developer.leapmotion.com/downloads and get the linux SDK package."
	ewarn "After downloading the package with version ${MY_PVP_N} move it to \"${DISTDIR}/${SRC_URI}\""
}

src_install() {
	local libdir=$(get_libdir)

	rm LeapSDK/lib/*.dll

	insinto /opt/Leap
	use examples && doins -r Examples
	use doc || rm -rf LeapSDK/docs
	doins -r LeapSDK

	dosym /opt/Leap/LeapSDK/include /usr/include/Leap
	dosym /opt/Leap/LeapSDK/lib/x64 "/usr/${libdir}/Leap"

	if use amd64; then
		dosym /opt/Leap/LeapSDK/lib/x86 "/usr/$(ABI=x86 get_libdir)/Leap"
		python_foreach_impl python_domodule LeapSDK/lib/x64/LeapPython.so LeapSDK/lib/x64/libLeap.so
	else
		python_foreach_impl python_domodule LeapSDK/lib/x86/LeapPython.so LeapSDK/lib/x86/libLeap.so
	fi
	python_foreach_impl python_domodule LeapSDK/lib/Leap.py
}
