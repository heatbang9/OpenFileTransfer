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
- PC Electron 시스템 트레이 숨김/복귀/종료 메뉴
- PC Electron 송신/수신 진행률 UI와 macOS/Windows 시스템 알림
- PC Electron 화이트리스트 승인/해제와 미승인 디바이스 전송 확인 팝업
- PC Electron 여러 서버 선택 후 1:N 파일 전송
- Android foreground service 기반 모바일 송신/수신 진행률 알림 레이어
- Flutter 모바일 `SendFile`, `ListFiles`, `ReceiveFile`, `SubscribeEvents` 직접 gRPC 클라이언트

## PC → Mobile 동작 상태

현재 PC Node/PC Electron 계열은 로컬 smoke test로 검증하고, 모바일 저장소는 GitHub Actions에서 Flutter analyze/test/APK debug build로 검증합니다. 로컬 머신에는 Flutter SDK가 없어 모바일 실기기 전송은 아직 CI/실기기에서 추가 확인이 필요합니다.

- PC 서버가 켜져 있으면 클라이언트가 SSDP로 찾고 `Handshake` 후 파일을 보낼 수 있습니다.
- 서버가 클라이언트 UI에 먼저 알림을 보내려면 클라이언트가 `SubscribeEvents` 스트림을 열어둬야 합니다.
- 아무 연결도 없는 모바일 앱에 서버가 임의로 먼저 접속해 push하는 구조는 아닙니다.
- PC 서버 UI는 `ListClients`/로컬 서버 상태를 통해 현재 세션과 이벤트 스트림 열린 클라이언트를 확인할 수 있습니다.
- PC smoke test는 파일 송수신뿐 아니라 `file_received` 서버 이벤트 수신과 연결 클라이언트 조회까지 검증합니다.
- PC 앱의 `전송 진행률` 패널은 PC 클라이언트 송신, PC 서버 수신, 원격 클라이언트 다운로드로 인한 PC 서버 송신 진행률을 표시합니다.
- PC 앱은 파일 전송 완료와 파일 수신 완료를 Electron 시스템 알림으로 표시합니다.
- PC 앱은 미승인 UUID 디바이스의 업로드/다운로드 요청을 확인/취소 팝업으로 막고, 화이트리스트 승인된 디바이스는 바로 통과시킵니다.
- PC 앱은 발견된 여러 서버를 선택해 같은 파일을 1:N으로 보낼 수 있습니다.
- 모바일 앱은 서버 수신함을 조회하고 파일을 내려받을 때 Android foreground service 알림과 앱 UI 진행률을 함께 갱신합니다.

## 모바일-to-모바일 방향

모바일-to-모바일 전송은 모바일 앱도 서버 롤을 가져야 합니다. Android는 foreground service 위에서 gRPC 서버와 SSDP responder를 유지하는 방식으로 구현하고, iOS는 장시간 백그라운드 서버 대기 제약 때문에 앱 활성 상태 중심 수신부터 시작합니다. 모바일 저장소에는 이 설계와 남은 구현 항목을 문서화했습니다.

## 데스크톱/모바일 백그라운드 UX

- PC 앱은 창 닫기 버튼을 눌러도 바로 종료하지 않고 시스템 트레이로 숨깁니다.
- macOS 메뉴 막대 또는 Windows 작업 표시줄 트레이 메뉴에서 앱 열기, 숨기기, 서버 시작, 서버 중지, 종료를 수행합니다.
- 창을 숨겨도 서버 롤과 이벤트 스트림은 계속 유지됩니다.
- 모바일 Android는 foreground service를 통해 전송/수신 중 상단 알림 영역에 진행률을 표시하는 구조로 구현합니다.
- iOS는 장시간 임의 gRPC 전송을 백그라운드에서 계속 유지하기 어렵기 때문에, 긴 파일 전송은 다음 단계에서 `URLSession` background transfer 또는 HTTP/HTTPS fallback을 별도로 검토합니다.

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

현재 모바일 앱은 generated Dart proto 없이 필요한 protobuf wire codec을 직접 정의해 `Handshake`, `SendFile`, `ListFiles`, `ReceiveFile`, `SubscribeEvents`를 호출합니다. SDK 설치 후 생성 코드로 전환하려면 아래 명령을 사용할 수 있습니다.

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
