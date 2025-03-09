# Changelog

All notable changes to the MicroKanren in Lua project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0]

### Added
- Initial implementation of microKanren core in Lua
  - Variables, values, and pair term representations
  - Unification algorithm
  - Substitution management
  - Goal combinators (conjunction and disjunction)
  - Fresh variable introduction
  - Stream operations for handling results
- Problem 1: Find the last element of a list
- Unit tests for core functionality
- Unit tests for Problem 1
- Basic project structure and documentation

### Fixed
- Issue with `unpack` function replaced with `table.unpack` for Lua 5.2+ compatibility
- Corrected recursive handling in the list last element algorithm

## [Unreleased]

### Planned
- Implementation of remaining problems from the 99 Prolog Problems
- Improved error handling and debugging tools
- More comprehensive documentation and examples
- Performance optimizations
- More advanced logic programming features
