# Interface between JEDI and FV3 based models

### Continuous integration:
| Platform      |  JCSDA-internal       | JCSDA      |
| ------------- | ------------- |------------- |
| GNU           | [![AWS-gnu](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiTWc5ckc5K0svcnVNNFNFakMvUDA4akFjUzFNZkRwYmZIaTRmMHhFOHNKYkR3NXdycE4yYnc2b0xkVVJ4a3NTSHl2WTA0R09CUTB2dFdZeGlOZ2hUR2dFPSIsIml2UGFyYW1ldGVyU3BlYyI6Im9hSVQxK0I2ZGZCV1IwN3QiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=develop)](https://console.aws.amazon.com/codesuite/codebuild/469205354006/projects/fv3-internal-gnu/history) | [![AWS-gnu](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiUEFLOXlGNjI2OUYybE9RTncyWS9hRjhXMGVXOXdKTUh1aVNuempFRHRMRjA1dmd5UDRienNaa2x6MDFHcWhhYmwvUmtRcnA5Y0FsbG8zS0xib3NtYTkwPSIsIml2UGFyYW1ldGVyU3BlYyI6Iks4Zkx2S3FKZGhwbXZzeEwiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=develop)](https://us-east-1.console.aws.amazon.com/codesuite/codebuild/projects/automated-testing-fv3-gnu/history)
| Intel         | [![AWS-intel](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiaDBtUlhjeElETU5UMVhnSUEralpxb3Y4REJBQjB1d2xONk9RTU0xS2RRcWROZ3hoR0RFb2N6dDE5eTl5WEpQejI0TmJ5ZFBWaXo0RWMrYS9tSnhNZ29nPSIsIml2UGFyYW1ldGVyU3BlYyI6IklSSndPZHdFZUR3ZFQvUGwiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=develop)](https://console.aws.amazon.com/codesuite/codebuild/469205354006/projects/fv3-internal-intel/history) | [![AWS-intel](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiVHRMaWZsV1VSd2luTzM1eEhwS0VjRWx3ajNHSTBkRThLZzFaWnJVQ3VBTkJGY0wwazllSHJXVVRVM3BLTlo5YUtWZ0N5Z2hNWTlOU1M1WWJMVklBeEZNPSIsIml2UGFyYW1ldGVyU3BlYyI6IlFpOVlIWFFGOXo3UlhnQlAiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=develop)](https://us-east-1.console.aws.amazon.com/codesuite/codebuild/projects/automated-testing-fv3-intel/history)
| CLANG         | [![AWS-clang](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoieXZSZ21oQ3lueWtTTExxb3VOMlNNWTRlUG1BbENlVWVQZlY2Y2wvYkt3bGtmVnVQdS9SMEtRWWpaRUNic3ozalRTVnczelZJS3o1TTVkU1ZxMjhQOU04PSIsIml2UGFyYW1ldGVyU3BlYyI6Inowd2VWS0prUUlPUEpaQTIiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=develop)](https://console.aws.amazon.com/codesuite/codebuild/469205354006/projects/fv3-internal-clang/history) | [![AWS-clang](https://codebuild.us-east-1.amazonaws.com/badges?uuid=eyJlbmNyeXB0ZWREYXRhIjoiVVFhVEwxbmo1YVBXUWVYT3lJR3hla1hmd2Z3dG51dWplTHF3QzRMblVZamFnNGhneWd5MnhqL1B2VnpCdW9QQ3llYWhNMDFLMGNCY0lDejZqSXJzOTBRPSIsIml2UGFyYW1ldGVyU3BlYyI6IlhRR21ITDh2NjlaVTFpaUMiLCJtYXRlcmlhbFNldFNlcmlhbCI6MX0%3D&branch=develop)](https://us-east-1.console.aws.amazon.com/codesuite/codebuild/projects/automated-testing-fv3-clang/history)  
| Code Coverage | [![codecov](https://codecov.io/gh/JCSDA/fv3-jedi/branch/develop/graph/badge.svg?token=Y2B418LACJ)](https://codecov.io/gh/JCSDA/fv3-jedi) |



### Licence:

(C) Copyright 2017-2021 UCAR

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

### Description:

Interface between the generic components of the JEDI data assimilation system and forecast models based on the FV3 dynamical core and geometry, namely GEOS and GFS.

### Installation:

For details about JEDI, including installation instructions see: https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/

The fv3-bundle is a convenient way of building fv3-jedi with all the necessary JEDI software. https://github.com/JCSDA/fv3-bundle
