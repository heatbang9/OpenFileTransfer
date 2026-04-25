# 브랜드 디자인

![OpenFileTransfer icon](../assets/brand/openfiletransfer-icon-512.png)

## 콘셉트

OpenFileTransfer의 기본 아이콘은 로컬 네트워크에서 파일을 주고받는 흐름을 표현합니다.

- 둥근 사각형: 앱 아이콘과 안정적인 연결
- 태극형 원형 흐름: 양방향 전송과 상호 신뢰
- 위/아래 화살표: 업로드와 다운로드
- 중앙 링: 암호화된 세션과 연결 허브

## 색상

| Token | Hex | 용도 |
| --- | --- | --- |
| Mint 50 | `#E9FFF6` | 앱 배경, 밝은 강조 영역 |
| Mint 100 | `#D8F8E8` | 보조 배경 |
| Mint 300 | `#BFEFD9` | 테두리, 비활성 표면 |
| Mint 500 | `#5ED6A3` | 밝은 흐름 그래픽 |
| Mint 600 | `#2BBF8A` | 주요 브랜드 포인트 |
| Teal 700 | `#147D67` | 주요 버튼, 선택 상태 |
| Teal 900 | `#0A5C4D` | 아이콘 선, 강한 텍스트 |
| Ink | `#15372F` | 본문 텍스트 |
| Surface | `#F7FFFB` | 화면 배경 |

## UI 방향

- 버튼과 패널은 8px radius를 기본으로 둡니다.
- 주요 액션은 진한 민트/틸 배경, 보조 액션은 흰색 표면과 민트 테두리를 씁니다.
- 아이콘은 전송, 탐색, 파일, 수신함처럼 기능을 직접 나타내는 형태를 우선합니다.
- PC와 모바일 모두 같은 로고 마크와 색상 토큰을 공유합니다.

## 저장소별 적용

- PC 앱: Electron renderer에서 같은 로고 SVG와 민트/틸 버튼 스타일을 사용합니다.
- 모바일 앱: Flutter `CustomPainter`로 같은 로고 마크를 그리고, `ThemeData` 색상 토큰을 맞춥니다.
- 앱 아이콘: `assets/brand/openfiletransfer-icon-1024.png`를 launcher/window icon의 원본으로 사용합니다.
