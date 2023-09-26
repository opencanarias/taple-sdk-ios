<div align="center">
<img src="https://raw.githubusercontent.com/opencanarias/public-resources/master/images/taple-logo-readme.png">
</div>

# TAPLE Sdk Ios

TAPLE (pronounced T+🍎 ['tapəl]) stands for Tracking (Autonomous) of Provenance and Lifecycle Events. TAPLE is a permissioned DLT solution for traceability of assets and processes. It is:

- **Scalable**: Scaling to a sufficient level for traceability use cases.
- **Light**: Designed to support resource constrained devices.
- **Flexible**: Have a flexible and adaptable cryptographic scheme mechanism for a multitude of scenarios.
- **Energy-efficient**: Rust powered, TAPLE is sustainable and efficient from the point of view of energy consumption.

This repository includes:

- Scripts for compiling TAPLE FFI for Ios 64-bit architectures.
- Swift library for using TAPLE FFI on Ios. Includes an implementation of the TAPLE database interface using the Ios SQLite libraries.
- Examples of use of the library

[![AGPL licensed][agpl-badge]][agpl-url]

[agpl-badge]: https://img.shields.io/badge/license-AGPL-blue.svg
[agpl-url]: https://github.com/opencanarias/taple-core/blob/master/LICENSE

[Discover](https://www.taple.es/docs/discover) | [Learn](https://www.taple.es/docs/learn) | [Build](https://www.taple.es/docs/build) | [Code](https://github.com/search?q=topic%3Ataple+org%3Aopencanarias++fork%3Afalse+archived%3Afalse++is%3Apublic&type=repositories)

## Build

Building the library is optional. The library is distributed through [Github releases](https://github.com/opencanarias/taple-sdk-ios/releases).

### Requirements
TODO: IOS

### Download
Clone TAPLE FFI and TAPLE SDK Ios. 
```bash
git clone https://github.com/opencanarias/taple-ffi
git clone https://github.com/opencanarias/taple-sdk-ios
```

## Use
Explore the [examples](./examples/) folder to learn how to use TAPLE in your Ios applications.

## Current limitations
Mobile devices do not usually have a public IP address, which prevents another TAPLE node from making a direct P2P connection with them. This means that currently only use cases where the mobile device initiates the connection with other TAPLE nodes can be addressed. 

In the future TAPLE will be able to solve this problem by using Push Nodes and/or Hole Punching techniques. 

## License

This project is licensed under the [AGPL license](./LICENSE).
