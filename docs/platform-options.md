# 플랫폼 선택 검토

## PC 앱

### 1순위: Electron + Node.js

현재 1단계 PC 코어가 Node.js로 작성되어 있어 gRPC, UDP SSDP, 파일 시스템 접근을 그대로 사용할 수 있습니다. UI는 Chromium 기반으로 빠르게 만들고, macOS/Windows 패키징은 Electron 배포 도구를 붙이는 방식이 가장 빠릅니다.

장점:

- 기존 Node gRPC/SSDP 코어 재사용
- macOS/Windows UI 동시 개발이 쉬움
- 파일 시스템과 네트워크 권한 처리 단순
- 시스템 트레이, 창 숨김, 백그라운드 서버 유지 UX 구현이 단순
- GitHub Releases 기반 업데이트 경로가 명확함

단점:

- 앱 용량과 메모리 사용량이 큼
- macOS notarization, Windows code signing은 별도 필요

### 2순위: Flutter Desktop

모바일과 UI 코드를 공유하고 싶을 때 좋습니다. 다만 현재 코어를 Dart로 다시 구현하거나 네이티브 플러그인을 붙여야 해서 1단계 속도는 느려집니다.

### 3순위: Tauri

앱 크기가 작고 네이티브 느낌이 좋습니다. 다만 Rust 쪽에서 gRPC/SSDP/파일 전송 코어를 다시 묶어야 하므로 초기 개발 비용이 큽니다.

## 모바일 앱

### 1순위: Flutter Native

Android/iOS 앱으로 배포하고, 파일 선택, 로컬 네트워크 권한, 백그라운드 동작, gRPC 클라이언트를 직접 제어하는 방식입니다.

장점:

- 모바일 앱 배포 형식에 가장 적합
- 파일 선택과 OS 권한 처리가 명확함
- Dart gRPC 생성 코드를 proto submodule에서 바로 만들 수 있음

단점:

- iOS 로컬 네트워크 권한과 Bonjour/UDP 정책 검토 필요
- SSDP 탐색은 플랫폼 채널 또는 검증된 플러그인 선정 필요
- iOS는 Android foreground service처럼 장시간 임의 네트워크 작업을 계속 유지하기 어렵기 때문에 큰 파일 전송에는 HTTP/HTTPS background transfer fallback 검토 필요

### Android 백그라운드 전송

Android는 파일 전송/수신을 사용자가 인지할 수 있는 foreground service로 올리고, 알림 영역에 진행률을 갱신하는 방향을 사용합니다. Android 14 이상에서는 foreground service type이 필요하므로 `dataSync`를 선언합니다. Android 15부터 `dataSync` foreground service에는 시간 제한이 있으므로, 매우 긴 전송은 chunk 재개와 실패 복구가 필요합니다.

참고: [Android foreground service type: dataSync](https://developer.android.com/about/versions/14/changes/fgs-types-required#data-sync), [flutter_foreground_task](https://pub.dev/packages/flutter_foreground_task)

### iOS 백그라운드 전송

iOS는 앱이 백그라운드로 내려간 뒤 임의 gRPC 스트림을 계속 유지하는 방식이 안정적이지 않습니다. 짧은 작업은 제한적으로 이어갈 수 있지만, 안정적인 대용량 파일 전송은 `URLSession` background transfer를 쓰는 HTTP/HTTPS 전송 경로를 별도로 두는 설계가 적합합니다.

참고: [Apple BackgroundTasks](https://developer.apple.com/documentation/BackgroundTasks)

### 보조안: Flutter Web 또는 PWA

UI 배포는 쉽지만, 브라우저는 UDP SSDP 탐색을 직접 수행할 수 없고 표준 gRPC HTTP/2 클라이언트도 직접 구현할 수 없습니다. gRPC-Web proxy 또는 REST gateway가 필요합니다.

적합한 사용처:

- 같은 네트워크의 PC 앱이 제공하는 관리 화면
- 서버 주소를 수동 입력하는 제한적 파일 업로드
- 관리자/설정용 보조 UI

부적합한 사용처:

- 자동 디바이스 탐색
- 표준 gRPC 직접 연결
- 모바일 파일 전송 앱의 1차 UX

## 권장 로드맵

1. PC: Electron 앱으로 macOS/Windows UI를 먼저 완성합니다.
2. Mobile: Flutter Native Android를 먼저 완성하고 iOS 권한 정책을 이어서 검증합니다.
3. Web/PWA: 필요하면 PC 앱이 제공하는 gateway를 통해 보조 UI로 추가합니다.
4. TLS: 앱 레벨 암호화 유지 후, 인증서 핀닝 기반 gRPC TLS를 2단계에 추가합니다.
