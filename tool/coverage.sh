#!/bin/sh
# Runs the tests and prints line coverage for lib/country_time.dart.
# Set MIN_COVERAGE (e.g. 95) to exit non-zero when coverage is below it.
set -e
cd "$(dirname "$0")/.."
rm -rf coverage
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info \
  --report-on=lib/country_time.dart --packages=.dart_tool/package_config.json
awk -F'[:,]' '/^DA:/{t++; if($3>0)h++; else miss=miss" "$2}
  END{printf "Coverage: %d/%d lines = %.1f%%\n",h,t,100*h/t;
      if(miss) print "Uncovered lines:" miss;
      if(min != "" && 100*h/t < min+0){printf "FAIL: coverage below %s%%\n",min; exit 1}}' \
  min="$MIN_COVERAGE" coverage/lcov.info
