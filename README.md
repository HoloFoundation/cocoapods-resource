# cocoapods-resource

Resource file management configuration tool for Pod.

Configure the pod with Preprocessor Macros to get the name of the current Pod at the line of code execution.

Also for [HoloResource](https://github.com/HoloFoundation/HoloResource)

## Installation

    $ gem install cocoapods-resource

## Usage

By default, add configuration to all current Pods.

    $ pod resource MACRO_NAME

Pass in the Pod name array, and configure the Preprocessor Macros for these specified Pods.

    $ pod resource MACRO_NAME --pod=POD_NAME


