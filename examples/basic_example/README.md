# Basic Usage

## Introduction

This project serves as an example of how to use the Taple SDK. We will deploy a *Bootstrap Node* in a PC and then connect to it with our mobile and create a subject and an event for it to check that it is working correctly.

## Repositories and tools

- Taple-sdk-ios [https://github.com/opencanarias/taple-sdk-ios](https://github.com/opencanarias/taple-sdk-ios)
- Xcode
- An HTTP client like Curl
- Docker

## *Bootstrap Node*

The *Bootstrap Node* will need to be hosted on a machine that is network accessible for our phone (a WiFi LAN network, for example). This node will serve the purpose of hosting the Governance and acting as a meeting point for different phones. We need to run the *Bootstrap Node* before running the app because, for configuring the app, we will need parameters from the node.

```bash
docker run -p 3000:3000 -p 50000:50000 \
-e TAPLE_ID_PRIVATE_KEY=f78e9b42c3f265d0c5bf613f47bf4fb8fa3f18b3b38dd4e90ca7eed497e3394a \
-e TAPLE_HTTP=true \
-e TAPLE_NETWORK_LISTEN_ADDR=/ip4/0.0.0.0/tcp/50000 \
-e RUST_LOG=info \
opencanarias/taple-client
```

Once our node is initialized, we need to create a Governance for our mobile node to connect to.

```bash
curl --location 'http://localhost:3000/api/event-requests' \
--header 'Content-Type: application/json' \
--data '{
    "request": {
        "Create": {
            "governance_id": "",
            "schema_id": "governance",
            "namespace": "",
            "name": "MyGovernance"
        }
    }
}'
```

We need the *Governance ID* to continue. To get the current *Governance ID* we can execute the next petition to the API and get the ID from the response. We will need this ID further in the tutorial.

```bash
curl --location 'http://localhost:3000/api/subjects'
```

With the retrieved *Governance ID* from the previous step, we can use it to update our Governance and add a schema to it. This schema will allow us to create new subjects in our mobile node and check the events that our subject will create in our mobile node.

> Is important that you change the *subject_id* in the body os the request for the *Governance ID* that we previously obtained.

```bash
curl --location 'http://localhost:3000/api/event-requests' \
--header 'Content-Type: application/json' \
--data '{
    "request": {
        "Fact": {
            "subject_id": "[HERE GOES YOUR GOVERNANCE ID]",
            "payload": {
                "Patch": {
                    "data": [
                        {
                            "op": "add",
                            "path": "/schemas/0",
                            "value": {
                                "id": "test",
                                "schema": {
                                    "type": "object",
                                    "properties": {
                                        "one": {
                                            "type": "integer"
                                        },
                                        "two": {
                                            "type": "integer"
                                        },
                                        "three": {
                                            "type": "integer"
                                        }
                                    },
                                    "required": [
                                        "one",
                                        "two",
                                        "three"
                                    ]
                                },
                                "initial_value": {
                                    "one": 1,
                                    "two": 2,
                                    "three": 3
                                },
                                "contract": {
                                    "raw": "dXNlIHNlcmRlOjp7U2VyaWFsaXplLCBEZXNlcmlhbGl6ZX07DQoNCnVzZSB0YXBsZV9zY19ydXN0IGFzIHNkazsNCg0KI1tkZXJpdmUoU2VyaWFsaXplLCBEZXNlcmlhbGl6ZSwgQ2xvbmUpXQ0Kc3RydWN0IFN0YXRlIHsNCiAgcHViIG9uZTogdTMyLA0KICBwdWIgdHdvOiB1MzIsDQogIHB1YiB0aHJlZTogdTMyDQp9DQoNCiNbZGVyaXZlKFNlcmlhbGl6ZSwgRGVzZXJpYWxpemUpXQ0KZW51bSBTdGF0ZUV2ZW50IHsNCiAgTW9kT25lIHsgZGF0YTogdTMyIH0sDQogIE1vZFR3byB7IGRhdGE6IHUzMiB9LA0KICBNb2RUaHJlZSB7IGRhdGE6IHUzMiB9LA0KICBNb2RBbGwgeyBvbmU6IHUzMiwgdHdvOiB1MzIsIHRocmVlOiB1MzIgfQ0KfQ0KDQojW25vX21hbmdsZV0NCnB1YiB1bnNhZmUgZm4gbWFpbl9mdW5jdGlvbihzdGF0ZV9wdHI6IGkzMiwgZXZlbnRfcHRyOiBpMzIsIGlzX293bmVyOiBpMzIpIC0+IHUzMiB7DQogICAgc2RrOjpleGVjdXRlX2NvbnRyYWN0KHN0YXRlX3B0ciwgZXZlbnRfcHRyLCBpc19vd25lciwgY29udHJhY3RfbG9naWMpDQp9DQoNCmZuIGNvbnRyYWN0X2xvZ2ljKA0KICBjb250ZXh0OiAmc2RrOjpDb250ZXh0PFN0YXRlLCBTdGF0ZUV2ZW50PiwNCiAgY29udHJhY3RfcmVzdWx0OiAmbXV0IHNkazo6Q29udHJhY3RSZXN1bHQ8U3RhdGU+LA0KKSB7DQogIGxldCBzdGF0ZSA9ICZtdXQgY29udHJhY3RfcmVzdWx0LmZpbmFsX3N0YXRlOw0KICBtYXRjaCBjb250ZXh0LmV2ZW50IHsNCiAgICAgIFN0YXRlRXZlbnQ6Ok1vZE9uZSB7IGRhdGEgfSA9PiB7DQogICAgICAgIHN0YXRlLm9uZSA9IGRhdGE7DQogICAgICB9LA0KICAgICAgU3RhdGVFdmVudDo6TW9kVHdvIHsgZGF0YSB9ID0+IHsNCiAgICAgICAgc3RhdGUudHdvID0gZGF0YTsNCiAgICAgIH0sDQogICAgICBTdGF0ZUV2ZW50OjpNb2RUaHJlZSB7IGRhdGEgfSA9PiB7DQogICAgICAgIHN0YXRlLnRocmVlID0gZGF0YTsNCiAgICAgIH0sDQogICAgICBTdGF0ZUV2ZW50OjpNb2RBbGwgeyBvbmUsIHR3bywgdGhyZWUgfSA9PiB7DQogICAgICAgIHN0YXRlLm9uZSA9IG9uZTsNCiAgICAgICAgc3RhdGUudHdvID0gdHdvOw0KICAgICAgICBzdGF0ZS50aHJlZSA9IHRocmVlOw0KICAgICAgfQ0KICB9DQogIGNvbnRyYWN0X3Jlc3VsdC5zdWNjZXNzID0gdHJ1ZTsNCn0="
                                }
                            }
                        },
                        {
                            "op": "add",
                            "path": "/policies/1",
                            "value": {
                                "id": "test",
                                "approve": {
                                    "quorum": "MAJORITY"
                                },
                                "evaluate": {
                                    "quorum": "MAJORITY"
                                },
                                "validate": {
                                    "quorum": "MAJORITY"
                                }
                            }
                        },
                        {
                            "op": "add",
                            "path": "/roles/0",
                            "value": {
                                "namespace": "",
                                "role": "CREATOR",
                                "who": "ALL",
                                "schema": {
                                    "ID": "test"
                                }
                            }
                        }
                    ]
                }
            }
        }
    }
}'
```

Once we send petition to update the governance we need the *approval-request* ID of this petition to approve it. 

```bash
curl --location 'http://localhost:3000/api/approval-requests?status=Pending'
```

When we got this ID we can approve it replacing in the url the last part with the petition ID.

```bash
curl --location 'http://localhost:3000/api/approval-requests/[HERE GOES YOUR APPROVAL REQUEST ID]' \
--request PATCH \
--header 'Content-Type: application/json' \
--data '{"state": "RespondedAccepted"}'
```

If we execute again the `curl --location 'http://localhost:3000/api/subjects'` we should be able to see that our *Governance* is now updated and with the configuration that we specified before.

## Mobile Demo
First, we need the `taple_sdk` to be compiled locally, or we can use the default .zip file in the release section to have the binaries (in this case, we don't have to do anything). Once we get the binaries, we can proceed to open Xcode and select the basic_example folder.

We need to configure the app for the current *Bootstrap Node* and Governance configuration. To do this, we will modify the `Config.swift` that is in this project.

Once we configure it, we can compile the app and run it in Xcode. Once it is launched, we should follow the next steps to verify Taple:

1. Start the taple node and, very importantly, wait a couple of seconds to update the Governance in the mobile
2. Once we got the updated Governance we can create a subject and check it in the *Bootstrap Node* with the `getGovernances` petition previously used
3. Once the subject is created, we can create an event for this subject and check it the same way as before

You are done running a basic example with Taple. You can go to [www.taple.es](www.taple.es) to see more information about the technology and use cases in which it can be useful !