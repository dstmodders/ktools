# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased][]

### Changed

- Bump [Boost.Endian][] library from 1.54.0 to 1.80.0
- Bump [TCLAP][] library from 1.2.1 to 1.2.5
- Bump [pugixml][] library from 1.4 to 1.13
- Bump [squish][] library from 1.10 to 1.15
- Improve code consistency

### Fixed

- Fix big-endian and little-endian detection for some architectures

## [4.5.1][] - 2021-09-15

### Fixed

- Fix issues with alpha channel

## [4.5.0][] - 2021-08-27

### Changed

- Enable `--no-premultiply` option
- Improve code consistency
- Migrate [ImageMagick][] from 6 to 7

## [4.4.1][] - 2021-08-23

### Changed

- Improve code consistency
- Improve CPU detection during compilation
- Improve low animation scales numerical stability

### Fixed

- Fix `KTools::inverseOf()` return type

## [4.4.0][] - 2016-03-24

### Added

- Add support for animations with 5+ sides

## [4.3.1][] - 2016-03-23

### Changed

- Replace duplicate animations' error with a warning

## 4.3.0 - 2016-03-23

First release.

[unreleased]: https://github.com/dstmodders/ktools/compare/v4.5.1...HEAD
[4.5.1]: https://github.com/dstmodders/ktools/compare/v4.5.0...v4.5.1
[4.5.0]: https://github.com/dstmodders/ktools/compare/v4.4.1...v4.5.0
[4.4.1]: https://github.com/dstmodders/ktools/compare/4.4.0...v4.4.1
[4.4.0]: https://github.com/dstmodders/ktools/compare/4.3.1...4.4.0
[4.3.1]: https://github.com/dstmodders/ktools/compare/4.3.0...4.3.1
[boost.endian]: https://www.boost.org/
[eslint]: https://eslint.org/
[github actions]: https://github.com/features/actions
[github]: https://github.com/
[imagemagick]: https://imagemagick.org/index.php
[prettier]: https://prettier.io/
[pugixml]: https://pugixml.org/
[remark]: https://remark.js.org/
[squish]: https://libsquish.sourceforge.io/
[stylelint]: https://stylelint.io/
[tclap]: https://tclap.sourceforge.net/
[travis ci]: https://travis-ci.org/
[webpack]: https://webpack.js.org/
