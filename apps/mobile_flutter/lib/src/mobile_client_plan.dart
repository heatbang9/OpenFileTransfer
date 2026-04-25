class MobileClientPlan {
  const MobileClientPlan();

  List<String> get nextSteps => const [
        'SSDP 탐색 플러그인 또는 플랫폼 채널 결정',
        'proto 생성 코드 연결',
        'Handshake 세션 키 생성',
        '파일 선택 후 SendFile 스트리밍 전송',
        '서버 수신함 ListFiles 조회',
      ];
}

