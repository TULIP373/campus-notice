"""Optional explicit API provider; never a fallback for the subscription SDK."""
import json
import os
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from urllib.request import Request, build_opener, HTTPRedirectHandler

from sdk_adapter import BridgeError, GUARD


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None  # Never forward authorization to a redirected endpoint.


def ask_api(question: str, system: str) -> str:
    key = os.environ.get("OPENAI_API_KEY", "")
    model = os.environ.get("OPENAI_MODEL", "")
    base = os.environ.get("OPENAI_BASE_URL", "https://api.openai.com/v1").rstrip("/")
    location = urlsplit(base)
    if not key or not model:
        raise BridgeError("API 模式需要自行配置 OPENAI_API_KEY 和 OPENAI_MODEL，订阅不替代 API 计费。")
    if location.scheme != "https" or not location.netloc or location.username or location.password or location.query or location.fragment:
        raise BridgeError("OPENAI_BASE_URL 必须是无凭据的 HTTPS 地址。")
    body = json.dumps({"model": model, "messages": [
        {"role": "system", "content": GUARD + "\n" + system},
        {"role": "user", "content": question},
    ]}, ensure_ascii=False).encode("utf-8")
    request = Request(base + "/chat/completions", data=body, method="POST", headers={
        "Authorization": "Bearer " + key, "Content-Type": "application/json",
    })
    try:
        with build_opener(NoRedirect()).open(request, timeout=165) as response:
            data = response.read(1024 * 1024 + 1)
            if len(data) > 1024 * 1024:
                raise BridgeError("API 回答超出大小限制。")
        choice = json.loads(data)["choices"][0]
        answer = choice["message"].get("content")
        if choice["message"].get("tool_calls") or choice.get("finish_reason") != "stop" or not isinstance(answer, str) or not answer.strip():
            raise BridgeError("API 未完成有效文字回答。")
        return answer
    except (HTTPError, URLError, TimeoutError, OSError, ValueError, KeyError, IndexError, TypeError):
        raise BridgeError("API 服务调用失败，请检查配置、额度或网络；没有返回模拟答案。") from None
