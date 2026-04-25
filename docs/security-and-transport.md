# 보안 및 전송 계층

## 1단계 결정

1단계는 gRPC plaintext HTTP/2를 사용합니다. 대신 파일 payload는 앱 레벨에서 암호화합니다.

- 키 합의: X25519 ECDH
- 키 파생: HKDF-SHA256
- 파일 chunk 암호화: AES-256-GCM
- nonce: chunk마다 새로 생성하는 96-bit random nonce
- 무결성: GCM auth tag와 전체 파일 SHA-256

## 왜 HTTPS를 바로 강제하지 않는가

로컬 네트워크의 자동 디바이스 연결에서 TLS 자체보다 인증서 신뢰 배포가 더 어렵습니다.

- 자체 서명 인증서는 구현이 쉽지만, 모바일에서 신뢰 설정이나 인증서 핀닝 UX가 필요합니다.
- 공인 인증서는 사설 IP/로컬 호스트명과 잘 맞지 않습니다.
- 로컬 CA 또는 mDNS 기반 인증은 2단계 이후에 다루는 편이 좋습니다.

## HTTPS/gRPC TLS 전환 가능성

전환은 가능합니다. Node PC 구현은 `grpc.ServerCredentials.createSsl`과 `grpc.credentials.createSsl`로 바꿀 수 있습니다.

권장 2단계는 다음과 같습니다.

1. 최초 페어링 때 서버 인증서 fingerprint를 저장합니다.
2. 이후 연결부터 인증서 핀닝으로 MITM을 감지합니다.
3. 앱 레벨 암호화는 유지해 방어층을 하나 더 둡니다.

