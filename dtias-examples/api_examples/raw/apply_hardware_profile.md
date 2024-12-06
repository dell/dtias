## Curl

curl ^"https://bmo.lan/gui/api/orchestration/hardwareprofile/applyHardwareProfile/default_tenant^" ^
  -H ^"accept: application/json, text/plain, */*^" ^
  -H ^"accept-language: en-US,en;q=0.6^" ^
  -H ^"authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJHd3RfSEdIUVNJZ1FZUElPNnZSS25qMTE5Rjd1V0pzVGtNME5tZUZ5cm1NIn0.eyJleHAiOjE3MzM1MDQ4MTIsImlhdCI6MTczMzUwNDUxMiwiYXV0aF90aW1lIjoxNzMzNDk5NzkwLCJqdGkiOiI0NjgzY2NhYy00MzI1LTRkODUtOTEyOS0xZGI2OGM4ZDI1NGEiLCJpc3MiOiJodHRwczovL2Jtby5sYW4va2V5Y2xvYWsvcmVhbG1zL0Z1bGNydW0iLCJhdWQiOiJjY3BhcGkiLCJzdWIiOiI2ODRlNWE1My1jNGY5LTQyMDEtYmJmMC1jM2QzZTVjMjc5ZTgiLCJ0eXAiOiJJRCIsImF6cCI6ImNjcGFwaSIsInNlc3Npb25fc3RhdGUiOiI3YTE3ZTNjYy1jZWYyLTQ3ZjYtYjk4My0zZDU5ZDI1MGEyMjgiLCJhdF9oYXNoIjoiNHlRRGdQOTBicDZvM3pUTzB0b2piQSIsImFjciI6IjAiLCJzaWQiOiI3YTE3ZTNjYy1jZWYyLTQ3ZjYtYjk4My0zZDU5ZDI1MGEyMjgiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsIm5hbWUiOiJncmFudCIsImdyb3VwcyI6WyJzeXN0ZW0tYWRtaW4iXSwicHJlZmVycmVkX3VzZXJuYW1lIjoiZ3JhbnQiLCJnaXZlbl9uYW1lIjoiZ3JhbnQifQ.I-iBLJJDved9NI2ygNGaODBtS0t4Uz2CnQztwe8Bbf09RH2H2kX8gdM5vSvX5ov6E3w2P35d-D9RzqWnjONw8-M2OqWLrvAb3-hv6Oud76wvtddVCLq1nUqhODNXlkEOpLl4W1FARRhMBFgoks_V3r_nD2gLxPpE_rASHjhHGD2jxPExza08sCiObw9Nli6luh6NKZBXNBI0wUICYx1fhPsiBZqnPr2wHxyZ5g_YKBy6skv8lGgjUqAmFYrKbQj87cArsnnDXHGJc-MWpxXX6E5Goxhg-6CPa_Tf7Z57zLMGtzBAajmwe6t3YGUtH5V3JMjM_naL2uKU87QujtPsYQ^" ^
  -H ^"content-type: application/json^" ^
  -H ^"origin: https://bmo.lan^" ^
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
  --data-raw ^"^{^\^"servers^\^":^[^{^\^"serviceTag^\^":^\^"5c5jpr3^\^",^\^"state^\^":^\^"failed^\^",^\^"powerState^\^":^\^"On^\^",^\^"name^\^":^\^"milan^\^",^\^"tenant^\^":^\^"metalweaver^\^",^\^"tags^\^":^\^"^\^",^\^"site^\^":^\^"gc-site^\^",^\^"profile^\^":^\^"rockybaseline^\^",^\^"location^\^":^\^";;;;0^\^",^\^"deviceId^\^":^\^"^\^",^\^"labels^\^":^[^{^\^"Key^\^":^\^"monitoring^\^",^\^"Value^\^":^\^"FALSE^\^"^},^{^\^"Key^\^":^\^"ccp_resource_type^\^",^\^"Value^\^":^\^"Compute^\^"^},^{^\^"Key^\^":^\^"ccp_deployment_type^\^",^\^"Value^\^":^\^"Resource^\^"^},^{^\^"Key^\^":^\^"ccp_resourcepool_id^\^",^\^"Value^\^":^\^"rp_dp^\^"^},^{^\^"Key^\^":^\^"RID^\^",^\^"Value^\^":^\^"milan^\^"^},^{^\^"Key^\^":^\^"allocated^\^",^\^"Value^\^":^\^"FALSE^\^"^}^]^}^],^\^"profileName^\^":^\^"rockybaseline^\^"^}^" ^
  --insecure

## Response

"HardwareProfile marked for Update"

## Payload

{"servers":[{"serviceTag":"5c5jpr3","state":"failed","powerState":"On","name":"milan","tenant":"metalweaver","tags":"","site":"gc-site","profile":"rockybaseline","location":";;;;0","deviceId":"","labels":[{"Key":"monitoring","Value":"FALSE"},{"Key":"ccp_resource_type","Value":"Compute"},{"Key":"ccp_deployment_type","Value":"Resource"},{"Key":"ccp_resourcepool_id","Value":"rp_dp"},{"Key":"RID","Value":"milan"},{"Key":"allocated","Value":"FALSE"}]}],"profileName":"rockybaseline"}