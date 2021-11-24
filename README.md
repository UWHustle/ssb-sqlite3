# SSB on SQLite3

## Project structure

**bloom.c**: Bloom filter extension for SQLite3. Can be built with CMake or by following [these instructions](https://www.sqlite.org/loadext.html).

**queries**: Directory containing SSB queries. Queries with a `_bf` suffix are those that use Bloom filters.

**analysis**: Directory containing data, analysis code, and plots.
