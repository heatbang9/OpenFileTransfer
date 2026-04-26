# OpenFileTransfer

![OpenFileTransfer icon](assets/brand/openfiletransfer-icon-512.png)

OpenFileTransfer는 같은 로컬 네트워크의 디바이스를 UPnP/SSDP로 찾고, gRPC로 파일을 주고받는 통신 앱입니다.

## 관련 저장소

- [OpenFileTransferProto](https://github.com/heatbang9/OpenFileTransferProto): 공통 gRPC proto 계약
- [OpenFileTransferPC](https://github.com/heatbang9/OpenFileTransferPC): macOS/Windows PC 앱
- [OpenFileTransferMobile](https://github.com/heatbang9/OpenFileTransferMobile): Android/iOS Flutter 앱

## 목표 구조

- Mobile: Flutter Client
- PC: Server + Client
- Proto: 별도 public GitHub 저장소를 git submodule로 연결
- Transport: 1단계는 gRPC plaintext HTTP/2
- 중요 데이터: 파일 payload는 앱 레벨 AES-256-GCM 암호화

## 1단계 구현 내용

- PC Node CLI 서버/클라이언트
- SSDP `M-SEARCH` 기반 서버 디바이스 탐색
- HTTP descriptor endpoint로 gRPC 접속 정보 노출
- gRPC `Handshake`, `Ping`, `SubscribeEvents`, `ListClients`, `SendFile`, `ReceiveFile`, `ListFiles`
- X25519 + HKDF-SHA256 세션 키 생성
- 파일 chunk AES-256-GCM 암호화
- Flutter 클라이언트 앱 뼈대와 proto 생성 경로

## PC → Mobile 동작 상태

현재 실제로 검증된 동작은 PC Node/PC Electron 계열입니다. 모바일 저장소는 Flutter UI/빌드 뼈대이며, 실제 Dart gRPC 코드 생성과 모바일 연결 로직은 다음 단계입니다.

- PC 서버가 켜져 있으면 클라이언트가 SSDP로 찾고 `Handshake` 후 파일을 보낼 수 있습니다.
- 서버가 클라이언트 UI에 먼저 알림을 보내려면 클라이언트가 `SubscribeEvents` 스트림을 열어둬야 합니다.
- 아무 연결도 없는 모바일 앱에 서버가 임의로 먼저 접속해 push하는 구조는 아닙니다.
- PC 서버 UI는 `ListClients`/로컬 서버 상태를 통해 현재 세션과 이벤트 스트림 열린 클라이언트를 확인할 수 있습니다.
- PC smoke test는 파일 송수신뿐 아니라 `file_received` 서버 이벤트 수신과 연결 클라이언트 조회까지 검증합니다.

## 저장소 구조

```text
.
├── apps/
│   ├── mobile_flutter/      # Flutter 클라이언트 1단계 뼈대
│   └── pc-node/             # 실행 가능한 PC 서버/클라이언트
├── docs/                    # 설계 문서
├── proto/                   # OpenFileTransferProto git submodule
└── scripts/
```

## PC 앱 실행

```bash
npm install
npm --workspace apps/pc-node run oftpc -- server start
```

다른 터미널에서 탐색합니다.

```bash
npm --workspace apps/pc-node run oftpc -- client discover
```

파일 전송 예시입니다.

```bash
npm --workspace apps/pc-node run oftpc -- client send --address 127.0.0.1:39091 --file ./README.md
```

## Flutter 앱

현재 환경에는 Flutter SDK와 `protoc`가 없어 빌드 검증은 PC 앱 위주로 진행했습니다. SDK 설치 후 아래 명령으로 생성 코드를 만들 수 있습니다.

```bash
dart pub global activate protoc_plugin
protoc \
  --dart_out=grpc:apps/mobile_flutter/lib/generated \
  -Iproto/proto \
  proto/proto/openfiletransfer/v1/transfer.proto
```

## HTTPS 검토

자세한 내용은 [docs/security-and-transport.md](docs/security-and-transport.md)를 참고하세요.

## 플랫폼 검토

PC/macOS/Windows, 모바일 네이티브, 웹앱/PWA 선택지는 [docs/platform-options.md](docs/platform-options.md)에 정리했습니다.

## 디자인 콘셉트

앱 아이콘과 UI 색상 체계는 [docs/brand-design.md](docs/brand-design.md)에 정리했습니다. 기본 컨셉은 이미지 생성 모델로 만든 민트색 파일 전송 아이콘이며, 상단 우측에서 좌측으로 흐르는 화살표, 하단 좌측에서 우측으로 흐르는 화살표, 중앙 파일 문서 마크를 사용합니다.
