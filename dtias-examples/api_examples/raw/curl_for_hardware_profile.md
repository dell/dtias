curl ^"https://bmo.lan/gui/api/orchestration/hardwareprofile/getHardwareProfiles/default_tenant^" ^
  -H ^"accept: application/json, text/plain, */*^" ^
  -H ^"accept-language: en-US,en;q=0.6^" ^
  -H ^"authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJHd3RfSEdIUVNJZ1FZUElPNnZSS25qMTE5Rjd1V0pzVGtNME5tZUZ5cm1NIn0.eyJleHAiOjE3MzM1MDQ4MTIsImlhdCI6MTczMzUwNDUxMiwiYXV0aF90aW1lIjoxNzMzNDk5NzkwLCJqdGkiOiI0NjgzY2NhYy00MzI1LTRkODUtOTEyOS0xZGI2OGM4ZDI1NGEiLCJpc3MiOiJodHRwczovL2Jtby5sYW4va2V5Y2xvYWsvcmVhbG1zL0Z1bGNydW0iLCJhdWQiOiJjY3BhcGkiLCJzdWIiOiI2ODRlNWE1My1jNGY5LTQyMDEtYmJmMC1jM2QzZTVjMjc5ZTgiLCJ0eXAiOiJJRCIsImF6cCI6ImNjcGFwaSIsInNlc3Npb25fc3RhdGUiOiI3YTE3ZTNjYy1jZWYyLTQ3ZjYtYjk4My0zZDU5ZDI1MGEyMjgiLCJhdF9oYXNoIjoiNHlRRGdQOTBicDZvM3pUTzB0b2piQSIsImFjciI6IjAiLCJzaWQiOiI3YTE3ZTNjYy1jZWYyLTQ3ZjYtYjk4My0zZDU5ZDI1MGEyMjgiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsIm5hbWUiOiJncmFudCIsImdyb3VwcyI6WyJzeXN0ZW0tYWRtaW4iXSwicHJlZmVycmVkX3VzZXJuYW1lIjoiZ3JhbnQiLCJnaXZlbl9uYW1lIjoiZ3JhbnQifQ.I-iBLJJDved9NI2ygNGaODBtS0t4Uz2CnQztwe8Bbf09RH2H2kX8gdM5vSvX5ov6E3w2P35d-D9RzqWnjONw8-M2OqWLrvAb3-hv6Oud76wvtddVCLq1nUqhODNXlkEOpLl4W1FARRhMBFgoks_V3r_nD2gLxPpE_rASHjhHGD2jxPExza08sCiObw9Nli6luh6NKZBXNBI0wUICYx1fhPsiBZqnPr2wHxyZ5g_YKBy6skv8lGgjUqAmFYrKbQj87cArsnnDXHGJc-MWpxXX6E5Goxhg-6CPa_Tf7Z57zLMGtzBAajmwe6t3YGUtH5V3JMjM_naL2uKU87QujtPsYQ^" ^
  -H ^"priority: u=1, i^" ^
  -H ^"referer: https://bmo.lan/gui/^" ^
  -H ^"refreshtoken: eyJhbGciOiJIUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJiODE4NDNhNC05MjQ0LTQ0OWMtODQyNy0yOTJiZmUyMjU2OTYifQ.eyJleHAiOjE3MzM1MDYzMTIsImlhdCI6MTczMzUwNDUxMiwianRpIjoiMjg0ZDAzNTQtNzA2OS00OWI5LWFlYmItN2Q1ZTU4Y2M1ZGY2IiwiaXNzIjoiaHR0cHM6Ly9ibW8ubGFuL2tleWNsb2FrL3JlYWxtcy9GdWxjcnVtIiwiYXVkIjoiaHR0cHM6Ly9ibW8ubGFuL2tleWNsb2FrL3JlYWxtcy9GdWxjcnVtIiwic3ViIjoiNjg0ZTVhNTMtYzRmOS00MjAxLWJiZjAtYzNkM2U1YzI3OWU4IiwidHlwIjoiUmVmcmVzaCIsImF6cCI6ImNjcGFwaSIsInNlc3Npb25fc3RhdGUiOiI3YTE3ZTNjYy1jZWYyLTQ3ZjYtYjk4My0zZDU5ZDI1MGEyMjgiLCJzY29wZSI6Im9wZW5pZCBlbWFpbCBwcm9maWxlIiwic2lkIjoiN2ExN2UzY2MtY2VmMi00N2Y2LWI5ODMtM2Q1OWQyNTBhMjI4In0.5rA5_yRrYpzAskpdoJPdrhrV1xSCkExxD137lS2UIKY^" ^
  -H ^"sec-ch-ua: ^\^"Brave^\^";v=^\^"131^\^", ^\^"Chromium^\^";v=^\^"131^\^", ^\^"Not_A Brand^\^";v=^\^"24^\^"^" ^
  -H ^"sec-ch-ua-mobile: ?0^" ^
  -H ^"sec-ch-ua-platform: ^\^"Windows^\^"^" ^
  -H ^"sec-fetch-dest: empty^" ^
  -H ^"sec-fetch-mode: cors^" ^
  -H ^"sec-fetch-site: same-origin^" ^
  -H ^"sec-gpc: 1^" ^
  -H ^"user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36^" ^
  --insecure

[
    {
        "biosSettings": {
            "bootSettings": {
                "bootMode": "Uefi",
                "setBootOrderFqdd1": "*.*.*",
                "setBootOrderFqdd2": "NIC.*.*",
                "setBootOrderFqdd3": "Optical.*.*",
                "setBootOrderFqdd4": "Floppy.*.*"
            },
            "processorSettings": {
                "logicalProc": "Enabled",
                "procVirtualization": "Enabled",
                "procAdjCacheLine": "Enabled",
                "procHwPrefetcher": "Enabled",
                "procSwPrefetcher": "Enabled",
                "dcuStreamerPrefetcher": "Enabled",
                "dcuIpPrefetcher": "Enabled",
                "subNumaCluster": "Disabled",
                "upiPrefetch": "",
                "dynamicCoreAllocation": "",
                "procX2Apic": "Enabled",
                "procCores": "All",
                "controlledTurbo": "",
                "directoryAtoS": "",
                "deadLineLlcAlloc": "",
                "xptPrefetch": "",
                "madtCoreEnumeration": "",
                "directoryMode": "",
                "avxIccpPreGrantLicense": "",
                "avxIccpPreGrantLevel": "",
                "llcPrefetch": "",
                "procAvxP1": "",
                "optimizerMode": "",
                "processorRaplPrioritization": ""
            },
            "memorySettings": {
                "memTest": "Disabled",
                "memOpMode": "OptimizerMode",
                "nodeInterleave": "Disabled",
                "corrEccSmi": "Enabled",
                "oppSrefEn": "Disabled",
                "memoryTraining": "",
                "dramRefreshDelay": "",
                "ceCriticalSEL": ""
            },
            "profileSettings": {
                "procPwrPerf": "",
                "memFrequency": "MaxPerf",
                "procTurboMode": "Enabled",
                "procC1E": "Enabled",
                "monitorMwait": "",
                "cpuInterconnectBusLinkPower": "Enabled",
                "pcieAspmL1": "Enabled",
                "acPwrRcvry": "",
                "enablePkgcCriteria": "",
                "osAcpiCx": "",
                "pkgCLatNeg": "",
                "processorGpssTimer": "",
                "processorC1AutoDemotion": "",
                "processorC1AutoUnDemotion": "",
                "workloadConfiguration": "",
                "dynamicL1": "",
                "packageCStates": "",
                "uncoreFrequency": "DynamicUFS",
                "energyPerformanceBias": "BalancedPerformance",
                "proc1TurboCoreNum": "",
                "proc2TurboCoreNum": "",
                "memRefreshRate": "1x",
                "memPatrolScrub": "Standard",
                "procCStates": "Enabled",
                "writeDataCrc": "Disabled",
                "workloadProfile": "",
                "sysProfile": "Custom"
            },
            "integratedDevices": {
                "sriovGlobalEnable": "Disabled",
                "slot1": "",
                "slot2": "",
                "slot3": "",
                "autoDiscovery": "",
                "memoryMappedIOH": "",
                "usbPorts": "",
                "internalUsb": "",
                "usbManagedPort": "",
                "ioatEngine": "",
                "embVideo": "",
                "snoopHldOff": "",
                "osWatchdogTimer": "",
                "pciRootDeviceUnhide": "",
                "mmioAbove4Gb": ""
            },
            "serialCommunication": {
                "serialPortAddress": "",
                "serialComm": "",
                "extSerialConnector": "Serial1",
                "failSafeBaud": "115200",
                "conTermType": "Vt100Vt220",
                "redirAfterBoot": "Enabled"
            },
            "miscellaneousSettings": {
                "numLock": "",
                "errPrompt": "",
                "forceInt10": "",
                "wyseP25BIOSAccess": "",
                "powerCycleRequest": ""
            },
            "networkSettings": {
                "pxeDev1EnDis": "",
                "pxeDev2EnDis": "",
                "pxeDev3EnDis": "",
                "pxeDev4EnDis": "",
                "pxeDev1Interface": "",
                "pxeDev2Interface": "",
                "pxeDev3Interface": "",
                "pxeDev4Interface": ""
            },
            "redundantOsControl": {
                "redundantOsLocation": ""
            },
            "systemSecuritySettings": {
                "pwrButton": "",
                "passwordStatus": "",
                "inBandManageabilityInterface": "",
                "uefiVariableAccess": "",
                "acPwrRcvryDelay": "",
                "memoryEncryption": "",
                "tpmSecurity": "",
                "sha256SetupPasswordSalt": "",
                "sha256SetupPassword": "",
                "sha256SystemPasswordSalt": "",
                "sha256SystemPassword": ""
            },
            "sataSettings": {
                "writeCache": "",
                "securityFreezeLock": "",
                "embSata": ""
            }
        },
        "idracSettings": {
            "services": {
                "snmp1DiscoveryPort": 161,
                "snmp1AgentEnable": "Enabled",
                "snmp1AgentCommunity": "public",
                "snmp1SNMPProtocol": "All",
                "time1Timezone": "CST6CDT"
            },
            "connectivity": {
                "nic1TopologyLldp": "Disabled",
                "ipmiLan1Enable": "Disabled",
                "nic1VLanEnable": "Disabled",
                "nic1VLanID": "1",
                "osBmcPassThroughState": "Disabled",
                "virtualConsolePluginType": "eHTML5",
                "serialRedirectEnable": "Enabled",
                "rfsIgnoreCertWarning": "Yes"
            },
            "dnsSettings": {
                "dnsDomainName": "",
                "dnsRacName": ""
            },
            "ntpSettings": {},
            "bmcUsers": {
                "bmcCreateUsers": [
                    {
                        "userName": "REPLACE_THIS2",
                        "password": "mw-hw-baseline-profile-gc-ukvqtefdrv9useltmg-secret",
                        "originalPassword": "mw-hw-baseline-profile-gc-ukvqtefdrv9useltmg-secret",
                        "roleId": "Operator",
                        "enabled": true
                    }
                ],
                "bmcUpdateUsers": [
                    {
                        "userName": "REPLACE_THIS3",
                        "password": "mw-hw-baseline-profile-gc-ukvqtefdrv9useltmw-secret",
                        "originalPassword": "mw-hw-baseline-profile-gc-ukvqtefdrv9useltmw-secret",
                        "roleId": "Administrator"
                    }
                ],
                "bmcDeleteUsers": [
                    {
                        "userName": "REPLACE_THIS1"
                    }
                ]
            }
        },
        "firmwareSettings": null,
        "raidSettings": {
            "raidConversion": {
                "convertTo": "None"
            }
        },
        "osSettings": null,
        "telemetrySettings": {},
        "bmcLogSettings": {},
        "failedServers": "",
        "scpProfile": {},
        "id": "3fa89d43-37d2-4f20-8347-d52bea54ff6a",
        "name": "baseline-profile",
        "site": "gc",
        "resourceVersion": "12109",
        "reinitializeDrives": true,
        "nicSettings": null,
        "selectors": {
            "baseProfile": "baseline-profile"
        }
    },
    {
        "biosSettings": null,
        "idracSettings": {
            "services": {
                "snmp1AgentEnable": "",
                "snmp1SNMPProtocol": "",
                "time1Timezone": ""
            },
            "connectivity": {
                "nic1TopologyLldp": "",
                "ipmiLan1Enable": "",
                "nic1VLanEnable": "",
                "osBmcPassThroughState": "",
                "virtualConsolePluginType": "",
                "serialRedirectEnable": "",
                "rfsIgnoreCertWarning": ""
            },
            "dnsSettings": {
                "dnsDomainName": "",
                "dnsRacName": "",
                "dnsFromDHCP": "Disabled",
                "dns_IP_1": "10.10.25.120",
                "dns_IP_2": "1.1.1.1"
            },
            "ntpSettings": {
                "ntpConfigGroup1": "Enabled",
                "NTPConfigGroup1NTP1": "time.google.com",
                "NTPConfigGroup1NTP2": "",
                "NTPConfigGroup1NTP3": ""
            },
            "bmcUsers": {}
        },
        "firmwareSettings": null,
        "raidSettings": {
            "raidConversion": {
                "convertTo": "None"
            }
        },
        "osSettings": {
            "operatingsystemname": "rocky9.5",
            "configtype": "preseed",
            "autoConfigureBoss": true,
            "bootMenuOption": "2",
            "minimumDiskSize": 500,
            "overwriteInstallation": true,
            "installVolumeTypeOrder": [
                {
                    "type": "BOSS"
                },
                {
                    "type": "NVME"
                },
                {
                    "type": "SDCARD"
                },
                {
                    "type": "RAID"
                },
                {
                    "type": "HBA"
                }
            ],
            "networkingDetails": {
                "ipAddressDetails": {},
                "ntpServer": [],
                "dnsServer": [],
                "dnsSearch": []
            }
        },
        "telemetrySettings": {},
        "bmcLogSettings": {},
        "failedServers": "",
        "scpProfile": {},
        "id": "ccb5db7d-3896-40b1-a6c9-b4ffc56962e9",
        "name": "rockybaseline",
        "site": "gc",
        "resourceVersion": "6573366",
        "powerState": "On",
        "nicSettings": null
    }
]