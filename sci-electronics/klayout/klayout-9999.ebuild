# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

USE_RUBY="ruby22"
# note: define maximally ONE implementation here

RUBY_OPTIONAL=no

inherit eutils multilib toolchain-funcs ruby-ng

if [[ ${PV} = 9999* ]]; then
	EGIT_REPO_URI="https://github.com/klayoutmatthias/${PN}.git"
	inherit git-r3
	EGIT_CHECKOUT_DIR=${WORKDIR}/all/${P}
else
	SRC_URI="http://www.klayout.org/downloads/source/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

DESCRIPTION="Viewer and editor for GDS and OASIS integrated circuit layouts"
HOMEPAGE="http://www.klayout.de/"
LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND="
	dev-qt/designer:5
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	sys-libs/zlib
	$(ruby_implementations_depend)
"
DEPEND="${RDEPEND}"

all_ruby_prepare() {
	default
}

each_ruby_configure() {
	tc-export CC CXX AR LD RANLIB
	export CFLAGS CXXFLAGS
	./build.sh \
		-dry-run \
		-qmake /usr/lib64/qt5/bin/qmake \
		-ruby "${RUBY}" \
		-nopython \
		-build . \
		-bin "${T}/bin" \
		-rpath "/usr/$(get_libdir)/klayout" \
		-option "${MAKEOPTS}" \
		-with-qtbinding \
		-without-64bit-coord \
		-qt5 \
		-qtbin /usr/lib64/qt5/bin \
		-qtinc /usr/include/qt5 \
		-qtlib "/usr/$(get_libdir)/qt5" || die "Configuration failed"
}

each_ruby_compile() {
	emake all
}

each_ruby_install() {
	emake install

	cd "${T}/bin" || die

	dodir "/usr/$(get_libdir)/klayout"
	mv lib* "${ED}/usr/$(get_libdir)/klayout/" || die

	dobin *
}