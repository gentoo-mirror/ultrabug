# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

MY_PYP_N=${PV/_p/.}
MY_PVP=${PV/_p/+}
MY_PV=${PV%_p*}

inherit eutils unpacker multilib

DESCRIPTION="LeapMotion runtime and drivers"
HOMEPAGE="http://www.leapmotion.com/"
SRC_URI="Leap_Packages_${MY_PVP}_Linux.tgz"

LICENSE="LeapMotionSDK"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE=""

RESTRICT="fetch"
QA_PREBUILT="*"

S="${WORKDIR}/Leap_Packages_${MY_PVP}_Linux"

pkg_nofetch() {
	ewarn "Please visit https://developer.leapmotion.com/downloads and get the linux device drivers package."
	ewarn "After downloading the package with version ${MY_PVP_N} move it to \"${DISTDIR}/${SRC_URI}\""
}

src_install() {
	#NB: we dont need the etc folder
	unpack_deb "Leap-${MY_PVP}-$(usex amd64 x64 x86).deb"
	insinto /opt/Leap
	doins -r usr lib

	cd usr/bin
	local i
	for i in *; do
		make_wrapper "$i" "/opt/Leap/usr/bin/$i" . "/opt/Leap/lib:/opt/Leap/usr/lib/Leap"
		fperms +x "/opt/Leap/usr/bin/$i"
	done

	dosym /opt/Leap/lib/udev/rules.d/25-com-leapmotion-leap.rules /lib/udev/rules.d/25-com-leapmotion-leap.rules

	fperms +x "/opt/Leap/usr/sbin/leapd"
	newinitd "${FILESDIR}"/leapd.initd leapd
}
