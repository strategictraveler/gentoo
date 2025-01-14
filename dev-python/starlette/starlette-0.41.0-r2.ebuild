# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( pypy3 python3_{10..13} )

inherit distutils-r1

MY_P=${P/_p/.post}
DESCRIPTION="The little ASGI framework that shines"
HOMEPAGE="
	https://www.starlette.io/
	https://github.com/encode/starlette/
	https://pypi.org/project/starlette/
"
# no docs or tests in sdist, as of 0.27.0
SRC_URI="
	https://github.com/encode/starlette/archive/${PV/_p/.post}.tar.gz
		-> ${MY_P}.gh.tar.gz
"
S=${WORKDIR}/${MY_P}

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"

RDEPEND="
	<dev-python/anyio-5[${PYTHON_USEDEP}]
	>=dev-python/anyio-3.4.0[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.22.0[${PYTHON_USEDEP}]
	dev-python/itsdangerous[${PYTHON_USEDEP}]
	dev-python/jinja[${PYTHON_USEDEP}]
	>=dev-python/python-multipart-0.0.12-r100[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/pytest-8[${PYTHON_USEDEP}]
		dev-python/trio[${PYTHON_USEDEP}]
	)
"

: ${EPYTEST_TIMEOUT:-180}
distutils_enable_tests pytest

src_prepare() {
	distutils-r1_src_prepare

	# python-multipart package renamed in Gentoo to python_multipart
	sed -e "s:from multipart:from python_multipart:" \
		-e "s:import multipart:import python_multipart as multipart:" \
		-i starlette/*.py || die
}

python_test() {
	local EPYTEST_IGNORE=(
		# Unpackaged 'databases' dependency
		tests/test_database.py
	)

	local -x PYTEST_DISABLE_PLUGIN_AUTOLOAD=1
	epytest -p anyio
}
