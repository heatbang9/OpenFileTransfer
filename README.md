# OpenFileTransfer

OpenFileTransfer는 같은 로컬 네트워크의 디바이스를 UPnP/SSDP로 찾고, gRPC로 파일을 주고받는 통신 앱입니다.

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
- gRPC `Handshake`, `Ping`, `SendFile`, `ReceiveFile`, `ListFiles`
- X25519 + HKDF-SHA256 세션 키 생성
- 파일 chunk AES-256-GCM 암호화
- Flutter 클라이언트 앱 뼈대와 proto 생성 경로

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
