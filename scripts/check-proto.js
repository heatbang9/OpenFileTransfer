import fs from "node:fs";
import path from "node:path";

const protoPath = path.resolve("proto/proto/openfiletransfer/v1/transfer.proto");

if (!fs.existsSync(protoPath)) {
  console.error(`proto 파일을 찾을 수 없습니다: ${protoPath}`);
  process.exit(1);
}

const source = fs.readFileSync(protoPath, "utf8");
for (const token of ["service TransferService", "rpc Handshake", "rpc SendFile", "rpc ReceiveFile"]) {
  if (!source.includes(token)) {
    console.error(`proto 계약에서 필수 항목을 찾을 수 없습니다: ${token}`);
    process.exit(1);
  }
}

console.log("proto 계약 기본 검사를 통과했습니다.");

