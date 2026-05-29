const http = require("node:http");
const { URL } = require("node:url");

const upstreamRaw = process.env.OLLAMA_BASE_URL;
const port = Number(process.env.OLLAMA_PROXY_PORT || 11434);

if (!upstreamRaw) {
  console.error("[ollama-proxy] OLLAMA_BASE_URL nao definida");
  process.exit(1);
}

const upstream = upstreamRaw.replace(/\/+$/, "");

function log(message) {
  console.log(`[ollama-proxy] ${message}`);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    req.on("data", chunk => chunks.push(chunk));
    req.on("end", () => resolve(Buffer.concat(chunks)));
    req.on("error", reject);
  });
}

function proxyHeaders(req) {
  const headers = { ...req.headers };
  delete headers.host;
  delete headers.connection;
  delete headers["content-length"];
  return headers;
}

async function forward(req, path, body) {
  const url = new URL(path, `${upstream}/`);
  const response = await fetch(url, {
    method: req.method,
    headers: proxyHeaders(req),
    body: req.method === "GET" || req.method === "HEAD" ? undefined : body,
  });

  if (!response.ok) {
    const text = await response.text().catch(() => "");
    const error = new Error(`HTTP ${response.status} em ${path}: ${text.slice(0, 300)}`);
    error.status = response.status;
    throw error;
  }

  return response;
}

function messagesToPrompt(messages = []) {
  return messages
    .map(message => {
      const role = message.role || "user";
      const content = Array.isArray(message.content)
        ? message.content.map(part => part.text || part.content || "").join("\n")
        : String(message.content || "");
      return `${role}: ${content}`;
    })
    .filter(Boolean)
    .join("\n\n");
}

async function sendFetchResponse(res, response) {
  res.writeHead(response.status, Object.fromEntries(response.headers.entries()));
  if (!response.body) {
    res.end();
    return;
  }
  const reader = response.body.getReader();
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    res.write(Buffer.from(value));
  }
  res.end();
}

function transformGenerateChunk(line) {
  if (!line.trim()) return "";
  const item = JSON.parse(line);
  return JSON.stringify({
    model: item.model,
    created_at: item.created_at,
    message: {
      role: "assistant",
      content: item.response || "",
    },
    done: Boolean(item.done),
    done_reason: item.done_reason,
    total_duration: item.total_duration,
    load_duration: item.load_duration,
    prompt_eval_count: item.prompt_eval_count,
    prompt_eval_duration: item.prompt_eval_duration,
    eval_count: item.eval_count,
    eval_duration: item.eval_duration,
  }) + "\n";
}

async function sendGenerateFallback(res, requestJson) {
  const generateBody = {
    model: requestJson.model,
    prompt: messagesToPrompt(requestJson.messages),
    stream: requestJson.stream !== false,
    options: requestJson.options,
    keep_alive: requestJson.keep_alive,
  };

  log(`fallback acionado: /api/chat falhou, tentando /api/generate com modelo ${generateBody.model}`);

  const response = await fetch(`${upstream}/api/generate`, {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(generateBody),
  });

  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`HTTP ${response.status} em /api/generate: ${text.slice(0, 300)}`);
  }

  if (generateBody.stream === false) {
    const item = await response.json();
    res.writeHead(200, { "content-type": "application/json" });
    res.end(JSON.stringify({
      model: item.model,
      created_at: item.created_at,
      message: {
        role: "assistant",
        content: item.response || "",
      },
      done: true,
      done_reason: item.done_reason,
      total_duration: item.total_duration,
      load_duration: item.load_duration,
      prompt_eval_count: item.prompt_eval_count,
      prompt_eval_duration: item.prompt_eval_duration,
      eval_count: item.eval_count,
      eval_duration: item.eval_duration,
    }));
    return;
  }

  res.writeHead(200, { "content-type": "application/x-ndjson" });
  const reader = response.body.getReader();
  let buffer = "";
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    buffer += Buffer.from(value).toString("utf8");
    const lines = buffer.split("\n");
    buffer = lines.pop() || "";
    for (const line of lines) {
      if (line.trim()) res.write(transformGenerateChunk(line));
    }
  }
  if (buffer.trim()) res.write(transformGenerateChunk(buffer));
  res.end();
}

const server = http.createServer(async (req, res) => {
  const path = new URL(req.url, "http://127.0.0.1").pathname;

  try {
    const body = await readBody(req);

    if (path === "/api/chat" && req.method === "POST") {
      const requestJson = JSON.parse(body.toString("utf8") || "{}");
      log(`usando Ollama local: modelo ${requestJson.model || "nao informado"} via /api/chat`);
      try {
        const response = await forward(req, "/api/chat", body);
        await sendFetchResponse(res, response);
      } catch (error) {
        log(`erro de conexao com Ollama em /api/chat: ${error.message}`);
        await sendGenerateFallback(res, requestJson);
      }
      return;
    }

    const response = await forward(req, req.url, body);
    await sendFetchResponse(res, response);
  } catch (error) {
    log(`erro de conexao com Ollama: ${error.message}`);
    res.writeHead(502, { "content-type": "application/json" });
    res.end(JSON.stringify({ error: error.message }));
  }
});

server.listen(port, "127.0.0.1", () => {
  log(`ativo em http://127.0.0.1:${port}, upstream configurado`);
});
