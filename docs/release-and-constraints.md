# 릴리즈와 OS 제약 정리

이 문서는 OpenFileTransfer 전체 프로젝트의 남은 배포/계정/OS 제약을 한눈에 보기 위한 상위 문서입니다.

## 저장소별 상세 문서

- PC 빌드/배포: <https://github.com/heatbang9/OpenFileTransferPC/blob/main/docs/build-and-release.md>
- PC 피쳐 상태: <https://github.com/heatbang9/OpenFileTransferPC/blob/main/docs/feature-status.md>
- 모바일 빌드/배포: <https://github.com/heatbang9/OpenFileTransferMobile/blob/main/docs/build-and-release.md>
- 모바일 피쳐 상태: <https://github.com/heatbang9/OpenFileTransferMobile/blob/main/docs/feature-status.md>
- 모바일-to-모바일 피쳐: <https://github.com/heatbang9/OpenFileTransferMobile/blob/main/docs/mobile-to-mobile-features.md>
- 웹 MVP/제약: <https://github.com/heatbang9/OpenFileTransferWeb/blob/main/docs/web-mvp.md>
- 웹 Vercel 배포: <https://github.com/heatbang9/OpenFileTransferWeb/blob/main/docs/vercel-deploy.md>

## 현재 구현 상태

- PC: Electron 앱, 서버/클라이언트 롤, 트레이, 알림, 승인/화이트리스트, 1:N 전송, 패키징 스크립트까지 구현했습니다.
- Mobile: Flutter 앱, SSDP/gRPC 클라이언트, 모바일 임시 서버, 승인/화이트리스트, Android foreground service 진행률/수신 대기 알림, 1:N 전송까지 구현했습니다.
- Web: Vercel 정적 배포용 WebRTC 브라우저 앱, QR/공유 링크, 여러 파일 큐, 선택 AES-GCM 암호화까지 구현했습니다.
- Proto: 별도 저장소를 submodule로 두는 구조입니다.
- 통신: 1단계는 gRPC plaintext HTTP/2 + 앱 레벨 AES-256-GCM 파일 payload 암호화입니다.

## 남은 배포/운영 작업

### Android

필요한 계정/자산:

- Google Play Console 개발자 계정
- Android release signing key 또는 Play App Signing 업로드 키
- 개인정보 처리방침 URL
- 앱 권한 설명과 스토어 이미지

진행 방향:

1. 패키지 이름을 확정합니다.
2. Play App Signing을 설정합니다.
3. GitHub Actions release workflow에 keystore secret을 연결합니다.
4. `flutter build appbundle --release`로 AAB를 만들고 내부 테스트 트랙에 배포합니다.
5. Android 15 `dataSync` foreground service 제한을 실제 기기에서 확인합니다.

### iOS

필요한 계정/자산:

- Apple Developer Program 계정
- Bundle ID와 App Store Connect 앱 레코드
- Distribution certificate와 provisioning profile
- 로컬 네트워크 사용 설명, 개인정보 처리방침, TestFlight 테스터

진행 방향:

1. Bundle ID를 확정합니다.
2. Xcode signing을 설정합니다.
3. `flutter build ipa --release`를 생성합니다.
4. TestFlight에 올려 로컬 네트워크 권한과 백그라운드 제약을 검증합니다.
5. 장시간 전송은 `URLSession` background transfer 기반 HTTP/HTTPS fallback을 별도 설계합니다.

### macOS

필요한 계정/자산:

- Apple Developer Program 계정
- Developer ID Application 인증서
- notarization 인증 정보

진행 방향:

1. `npm run dist:mac`으로 DMG/ZIP 산출물을 생성합니다.
2. Developer ID signing을 적용합니다.
3. Apple notarization을 자동화합니다.
4. Gatekeeper가 통과하는지 실제 macOS에서 확인합니다.

### Windows

필요한 계정/자산:

- Microsoft Trusted Signing 또는 Authenticode code signing 인증서
- GitHub Actions Windows runner
- timestamp/signing 설정

진행 방향:

1. `npm run dist:win`을 Windows runner에서 실행합니다.
2. 설치 파일과 exe에 code signing을 적용합니다.
3. Windows Defender SmartScreen 경고 수준을 확인합니다.
4. GitHub Releases 또는 별도 다운로드 채널에 게시합니다.

### Web/Vercel

필요한 계정/자산:

- Vercel 계정
- GitHub `OpenFileTransferWeb` 저장소 import 권한
- 커스텀 도메인을 쓸 경우 DNS 관리 권한

진행 방향:

1. Vercel에서 `OpenFileTransferWeb` 저장소를 import합니다.
2. Framework Preset은 `Other`로 두고 Build Command와 Output Directory는 비워둡니다.
3. 배포 후 HTTPS origin에서 WebRTC, Clipboard, Web Share 동작을 확인합니다.
4. TURN 서버가 필요한 네트워크를 별도 테스트합니다.

## OS 제약에 따른 설계 판단

- Android는 foreground service 알림을 통해 사용자가 인지하는 전송/수신 대기를 지원합니다. 다만 Android 15부터 `dataSync` foreground service에는 시간 제한이 있어 무한 대기 서버처럼 설계하지 않습니다.
- iOS는 임의 gRPC 서버를 장시간 백그라운드에서 유지하기 어렵습니다. 모바일-to-모바일 수신은 앱 전면/단기 백그라운드 중심으로 두고, 대용량 안정 전송은 HTTP/HTTPS background transfer fallback을 둡니다.
- macOS와 Windows는 데스크톱 앱이 백그라운드 서버 역할을 안정적으로 수행할 수 있지만, 사용자 배포에는 코드 서명과 OS 신뢰 체계가 중요합니다.
- HTTPS/gRPC TLS는 2단계로 두되, 현재도 파일 payload는 앱 레벨 암호화를 유지합니다.
- Web은 브라우저 보안 모델상 UPnP/SSDP 자동 탐색을 하지 않습니다. 초대/응답 코드로 WebRTC 연결을 만들고, 파일 데이터는 Vercel 서버를 거치지 않습니다.

## 아직 남은 제품 피쳐

- Android 백그라운드 승인 notification action
- 모바일 1:N 큐 재시도/취소/대상별 고정 진행률
- 모바일 신뢰 목록 삭제/이름 변경/마지막 전송 시간
- iOS HTTP/HTTPS background transfer fallback
- GitHub Releases 기반 PC auto update
- Web TURN 서버 옵션과 외부 realtime signaling 기반 자동 방 매칭

## 공식 참고

- Flutter Android 배포: <https://docs.flutter.dev/deployment/android>
- Flutter iOS 배포: <https://docs.flutter.dev/deployment/ios>
- Android 15 foreground service 제한: <https://developer.android.com/about/versions/15/behavior-changes-15>
- Apple background download: <https://developer.apple.com/documentation/foundation/downloading-files-in-the-background>
- Apple notarization: <https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution>
- Electron code signing: <https://www.electronjs.org/docs/latest/tutorial/code-signing>
- Microsoft Windows code signing: <https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/code-signing-options>
