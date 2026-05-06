# OpenFileTransfer 전체 피쳐 상태

## PC 구현 완료

- Electron 기반 macOS/Windows 앱
- 서버/클라이언트 롤, SSDP 탐색, gRPC 파일 송수신
- 이벤트 구독, 연결 클라이언트 UI, 신뢰 디바이스 UI
- 화이트리스트 승인/해제와 미승인 전송 확인 팝업
- 시스템 트레이 숨김/복귀/종료 메뉴
- 송신/수신 진행률 UI와 시스템 알림
- 여러 서버 선택 후 1:N 전송
- `electron-builder` 기반 macOS/Windows 패키징 스크립트

## 모바일 구현 완료

- Flutter Android/iOS 앱
- SSDP 탐색, gRPC 파일 송신, 수신함 조회/다운로드, 이벤트 구독
- Android foreground service 기반 송신/수신 진행률 알림
- 모바일 임시 서버 롤과 모바일-to-모바일 송수신
- UUID 기반 신뢰 목록과 승인 팝업
- 모바일 1:N 순차 전송 큐와 대상별 결과 UI
- 모바일 수신 모드 foreground service 수신 대기 알림

## Web 구현 완료

- Vercel 정적 배포용 WebRTC P2P 파일 전송 앱
- Runtime Cache 기반 Nearby 방 디바이스 목록과 연결 요청
- QR 스캔/공유 링크, TURN 설정/relay 테스트, PWA 앱 shell 캐시
- File System Access/OPFS 저장, 실패 큐 재시도, 청크 단위 이어받기
- 선택 AES-GCM 청크 암호화와 로컬 전송 이력

## 남은 후보

- Android 백그라운드 승인 notification action
- 모바일 1:N 큐 재시도/취소/대상별 고정 진행률
- 모바일 신뢰 목록 삭제/이름 변경/마지막 전송 시간
- iOS 장시간 백그라운드 전송용 HTTP/HTTPS fallback
- macOS notarization, Windows code signing, GitHub Releases auto update
- Web 파일 해시 검증과 이어받기 상태 정리 UI
