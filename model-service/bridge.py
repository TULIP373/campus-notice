"""Loopback-only HTTP bridge; each request owns a disposable SDK worker."""
from __future__ import annotations

import argparse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import threading

sys.path.insert(0, str(Path(__file__).resolve().parent))
from sdk_adapter import BridgeError, ask, check_safety, clean_environment

LIMIT = 32 * 1024
TIMEOUT = 180
BUSY = threading.Lock()
SCRIPT = Path(__file__).resolve()


def terminate_worker(process: subprocess.Popen) -> None:
    if process.poll() is not None:
        return
    if sys.platform == "win32":
        subprocess.run(["taskkill", "/PID", str(process.pid), "/T", "/F"],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
    else:
        os.killpg(process.pid, signal.SIGKILL)
    process.wait(timeout=10)


def run_worker(payload: dict) -> tuple[int, dict]:
    environment = clean_environment(dict(os.environ))
    if os.environ.get("MODEL_PROVIDER", "codex") == "openai" and not payload.get("check_safety"):
        for name in ("OPENAI_API_KEY", "OPENAI_BASE_URL", "OPENAI_MODEL"):
            if name in os.environ:
                environment[name] = os.environ[name]
    process = subprocess.Popen(
        [sys.executable, "-I", "-X", "utf8", str(SCRIPT), "--worker"],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        text=True, encoding="utf-8", errors="replace", cwd=str(SCRIPT.parent),
        env=environment,
        creationflags=subprocess.CREATE_NO_WINDOW if sys.platform == "win32" else 0,
        start_new_session=sys.platform != "win32",
    )
    try:
        stdout, stderr = process.communicate(json.dumps(payload, ensure_ascii=False), timeout=TIMEOUT)
    except subprocess.TimeoutExpired:
        terminate_worker(process)
        return 504, {"message": "模型请求超过 180 秒，已终止本次工作进程。"}
    # The worker emits only event type names to stderr, never backend exception text.
    if stderr:
        try:
            event = json.loads(stderr)
            if set(event) == {"event_types"} and isinstance(event["event_types"], list):
                print(json.dumps(event), flush=True)
        except ValueError:
            pass
    try:
        output = json.loads(stdout)
    except ValueError:
        return 502, {"message": "模型工作进程异常结束，未返回有效回答。"}
    if process.returncode != 0 or "message" in output:
        return 502, {"message": output.get("message", "模型服务暂时不可用。")}
    return 200, output


class Handler(BaseHTTPRequestHandler):
    server_version = "CampusModelBridge"

    def setup(self):
        super().setup()
        self.connection.settimeout(15)

    def log_message(self, format, *args):
        pass  # Do not log paths, requests, headers, or model content.

    def reply(self, status: int, body: dict):
        encoded = json.dumps(body, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(encoded)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(encoded)

    def do_GET(self):
        if self.path == "/health":
            self.reply(200, {"status": "UP", "model": "not_checked"})
        else:
            self.reply(404, {"message": "接口不存在。"})

    def do_POST(self):
        if self.path != "/ask":
            self.reply(404, {"message": "接口不存在。"})
            return
        if self.headers.get("Origin") or self.headers.get("Transfer-Encoding"):
            self.reply(403, {"message": "本地模型接口仅供后端直接调用。"})
            return
        if self.headers.get_content_type() != "application/json":
            self.reply(415, {"message": "请发送 application/json。"})
            return
        try:
            length = int(self.headers.get("Content-Length", "0"))
            if length < 1 or length > LIMIT:
                self.reply(413, {"message": "请求必须为 1 至 32768 字节。"})
                return
            raw = self.rfile.read(length)
            if len(raw) != length:
                raise ValueError
            payload = json.loads(raw)
            if (not isinstance(payload, dict) or set(payload) != {"system", "user"}
                    or any(not isinstance(payload[k], str) or not payload[k].strip() for k in payload)):
                raise ValueError
        except (ValueError, UnicodeError, OSError):
            self.reply(400, {"message": "请求必须包含非空字符串 system 和 user。"})
            return
        if not BUSY.acquire(blocking=False):
            self.reply(503, {"message": "模型正在处理另一条请求，请稍后重试。"})
            return
        try:
            status, result = run_worker(payload)
            self.reply(status, result)
        except (OSError, ValueError):
            self.reply(502, {"message": "模型服务暂时不可用，请检查本地 SDK 安装与登录。"})
        finally:
            BUSY.release()


def worker():
    try:
        payload = json.load(sys.stdin)
        if payload.get("check_safety") is True:
            result = check_safety()
        else:
            provider = os.environ.get("MODEL_PROVIDER", "codex")
            if provider == "codex":
                answer = ask(payload["user"], payload["system"])
            elif provider == "openai":
                from api_adapter import ask_api
                answer = ask_api(payload["user"], payload["system"])
            else:
                raise BridgeError("MODEL_PROVIDER 只支持 codex 或 openai。")
            result = {"answer": answer}
        print(json.dumps(result, ensure_ascii=False), flush=True)
    except BridgeError as error:
        print(json.dumps({"message": str(error)}, ensure_ascii=False), flush=True)
        sys.exit(1)
    except Exception:
        print(json.dumps({"message": "Codex SDK、登录或安全隔离不可用，未生成回答。"}, ensure_ascii=False), flush=True)
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--worker", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument("--check-safety", action="store_true", help="Verify login and fixed local sandbox probes without calling a model")
    args = parser.parse_args()
    if args.worker:
        worker()
    elif args.check_safety:
        status, result = run_worker({"check_safety": True})
        print(json.dumps(result, ensure_ascii=False))
        sys.exit(0 if status == 200 else 1)
    else:
        with ThreadingHTTPServer(("127.0.0.1", 8787), Handler) as server:
            print("Campus model bridge listening on 127.0.0.1:8787; model not checked.", flush=True)
            server.serve_forever()


if __name__ == "__main__":
    main()
