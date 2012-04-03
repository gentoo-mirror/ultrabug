# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

# inherit apache-module python multilib ruby-ng

DESCRIPTION="Popular, blazing fast open source enterprise search platform from the Apache Lucene project"
HOMEPAGE="http://lucene.apache.org/solr/"
SRC_URI="http://www.apache.org/dist/lucene/${PN}/${PV}/apache-${P}.tgz"

LICENSE="Apache"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="www-servers/jetty-bin"
RDEPEND="${DEPEND}"

S="${WORKDIR}/apache-${P}"


# 	cd "$srcdir/apache-solr-$pkgver"
# 
# 	install -d "$pkgdir/etc/solr"
# 	install -d "$pkgdir/usr/share/solr"
# 	install -d "$pkgdir/opt/jetty/webapps"
# 
# 	unzip "dist/apache-solr-$pkgver.war" -d "$pkgdir/usr/share/solr"
# 	rm -rf "$pkgdir/usr/share/solr/META-INF"
# 
# 	cp -R example/solr/conf "$pkgdir/etc/solr"
# 	ln -s /etc/solr/conf "$pkgdir/usr/share/solr/conf"
# 
# 	mv "$pkgdir/usr/share/solr/WEB-INF/web.xml" "$pkgdir/etc/solr"
# 	ln -s /etc/solr/web.xml "$pkgdir/usr/share/solr/WEB-INF/web.xml"
# 
# 	install -m0644 "$srcdir/jetty-env.xml" "$pkgdir/usr/share/solr/WEB-INF/jetty-env.xml"
# 	ln -s /usr/share/solr "$pkgdir/opt/jetty/webapps/solr"


src_install() {
	dodir /usr/share/solr
	unzip dist/apache-"${P}.war" -d "${D}"/usr/share/solr || die
	rm -rf "${D}"/usr/share/solr/META-INF  || die

	dodir /etc/solr
	cp -R example/solr/conf "${D}"/etc/solr || die
	dosym /etc/solr/conf /usr/share/solr/conf

	mv "${D}"/usr/share/solr/WEB-INF/web.xml "${D}"/etc/solr/ || die
	dosym /etc/solr/web.xml /usr/share/solr/WEB-INF/web.xml

	cp ${FILESDIR}/jetty-env.xml ${D}/usr/share/solr/WEB-INF/
}
