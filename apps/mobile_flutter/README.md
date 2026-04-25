# OpenFileTransfer Flutter Client

Mobile 클라이언트 앱 뼈대입니다.

현재 1단계에서는 PC 서버/클라이언트를 먼저 실행 가능하게 만들고, Flutter 쪽은 같은 proto submodule을 기준으로 gRPC 클라이언트를 생성할 수 있게 준비했습니다.

## 준비

```bash
flutter pub get
../../scripts/generate-dart-proto.sh
```

## 다음 구현 대상

- SSDP 탐색 화면
- 서버 디바이스 목록
- `Handshake` 후 파일 선택 및 전송
- 수신 파일 목록 조회
- 페어링 신뢰 UX

