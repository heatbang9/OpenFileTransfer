# 아키텍처

## 역할

OpenFileTransfer 앱은 디바이스마다 서버 롤과 클라이언트 롤을 가질 수 있습니다.

- 서버 롤: 로컬 네트워크에 자신을 광고하고, gRPC 파일 전송 API를 제공합니다.
- 클라이언트 롤: SSDP로 서버 디바이스를 찾고, gRPC로 연결해 파일을 주고받습니다.

## 탐색 흐름

1. 서버는 SSDP multicast 주소 `239.255.255.250:1900`에서 `M-SEARCH` 요청을 기다립니다.
2. 클라이언트는 `urn:openfiletransfer:service:file-transfer:1` 대상으로 탐색 요청을 보냅니다.
3. 서버는 `LOCATION` 헤더에 HTTP descriptor URL을 담아 응답합니다.
4. 클라이언트는 descriptor JSON을 읽고 gRPC 주소를 얻습니다.
5. 이후 모든 파일 통신은 gRPC로 진행됩니다.

## 통신 흐름

1. 클라이언트가 `Handshake`로 임시 X25519 public key를 보냅니다.
2. 서버가 session id, 서버 public key, 선택된 cipher를 응답합니다.
3. 양쪽은 ECDH shared secret에서 AES-256-GCM 키를 파생합니다.
4. 클라이언트는 `SendFile` 스트림에 암호화된 chunk를 전송합니다.
5. 서버는 복호화 후 수신함에 저장하고 SHA-256 해시를 반환합니다.

## 서버 이벤트 흐름

서버가 클라이언트 UI에 먼저 알림을 보내려면 클라이언트가 서버 연결 후 `SubscribeEvents` server-streaming RPC를 열어둡니다.

1. 클라이언트가 `Handshake`로 세션을 만듭니다.
2. 클라이언트가 같은 세션 id로 `SubscribeEvents`를 호출하고 스트림을 유지합니다.
3. 서버는 파일 수신, 클라이언트 연결/해제, 서버 메시지를 `ServerEvent`로 스트림에 씁니다.
4. 서버 UI는 `ListClients` 또는 로컬 서버 상태로 현재 연결된 클라이언트와 이벤트 스트림 여부를 확인합니다.

서버가 네트워크상 아무 연결도 없는 모바일 앱에 임의로 먼저 접속하는 방식은 사용하지 않습니다. 모바일/PC 클라이언트가 스트림을 유지해야 서버 주도 알림처럼 동작합니다.

## proto 분리

`proto/`는 별도 public 저장소인 `OpenFileTransferProto`를 submodule로 연결합니다. 앱 저장소는 플랫폼별 구현과 UX에 집중하고, wire contract는 독립적으로 버전 관리합니다.
