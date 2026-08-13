#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import { existsSync, mkdtempSync, readFileSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";

const USAGE = `Usage: collect_anneal_metrics.mjs [options] <paths...>

Collect read-only annealing metrics for a scoped code area.

Options:
  --allow-ephemeral-tools   Allow npx/uvx for missing jscpd/lizard tools.
  --include-doc-duplicates  Include Markdown in jscpd duplicate scan.
  --help                    Show this help.

Output: JSON to stdout. Tool stderr/stdout snippets are summarized in JSON.
`;

const args = process.argv.slice(2);
let allowEphemeralTools = false;
let includeDocDuplicates = false;
const scopeArgs = [];

for (const arg of args) {
  if (arg === "--help" || arg === "-h") {
    process.stdout.write(USAGE);
    process.exit(0);
  }
  if (arg === "--allow-ephemeral-tools") {
    allowEphemeralTools = true;
    continue;
  }
  if (arg === "--include-doc-duplicates") {
    includeDocDuplicates = true;
    continue;
  }
  if (arg === "--json") {
    continue;
  }
  scopeArgs.push(arg);
}

const cwd = process.cwd();
const scopes = scopeArgs.length > 0 ? scopeArgs : ["."];
const startedAt = new Date().toISOString();
const tempDir = mkdtempSync(path.join(tmpdir(), "anneal-metrics-"));

const output = {
  startedAt,
  cwd,
  scopes,
  options: { allowEphemeralTools, includeDocDuplicates },
  tools: {},
  metrics: {},
  notes: [],
};

function run(command, args, options = {}) {
  const result = spawnSync(command, args, {
    cwd,
    encoding: "utf8",
    maxBuffer: 50 * 1024 * 1024,
    ...options,
  });
  return {
    command: [command, ...args].join(" "),
    status: result.status,
    signal: result.signal,
    stdout: result.stdout || "",
    stderr: result.stderr || "",
    error: result.error ? String(result.error.message || result.error) : null,
  };
}

function commandExists(command) {
  const result = spawnSync("sh", ["-lc", `command -v ${shellQuote(command)}`], {
    cwd,
    encoding: "utf8",
  });
  return result.status === 0 ? result.stdout.trim() : null;
}

function shellQuote(value) {
  return `'${String(value).replace(/'/g, `'\\''`)}'`;
}

function localBin(name) {
  const candidate = path.join(cwd, "node_modules", ".bin", name);
  return existsSync(candidate) ? candidate : null;
}

function firstLines(value, limit = 80) {
  return String(value || "").split(/\r?\n/).filter(Boolean).slice(0, limit);
}

function resolveTool(name, ephemeral) {
  if (name === "jscpd") {
    const local = localBin("jscpd");
    if (local) return { command: local, prefixArgs: [], source: "repo-local" };
    const global = commandExists("jscpd");
    if (global) return { command: global, prefixArgs: [], source: "PATH" };
    if (ephemeral && commandExists("npx")) return { command: "npx", prefixArgs: ["--yes", "jscpd"], source: "npx" };
  }
  if (name === "lizard") {
    const global = commandExists("lizard");
    if (global) return { command: global, prefixArgs: [], source: "PATH" };
    if (ephemeral && commandExists("uvx")) return { command: "uvx", prefixArgs: ["lizard"], source: "uvx" };
  }
  if (name === "codebase-memory-mcp") {
    const global = commandExists("codebase-memory-mcp");
    if (global) return { command: global, prefixArgs: [], source: "PATH" };
  }
  return null;
}

function parseCsvLine(line) {
  const cells = [];
  let current = "";
  let quoted = false;
  for (let i = 0; i < line.length; i += 1) {
    const ch = line[i];
    if (quoted) {
      if (ch === '"' && line[i + 1] === '"') {
        current += '"';
        i += 1;
      } else if (ch === '"') {
        quoted = false;
      } else {
        current += ch;
      }
    } else if (ch === ',') {
      cells.push(current);
      current = "";
    } else if (ch === '"') {
      quoted = true;
    } else {
      current += ch;
    }
  }
  cells.push(current);
  return cells;
}

function summarizeLizard(csvText) {
  const functions = [];
  for (const line of csvText.split(/\r?\n/)) {
    if (!line.trim()) continue;
    const cells = parseCsvLine(line);
    if (cells.length < 11) continue;
    const item = {
      nloc: Number(cells[0]),
      ccn: Number(cells[1]),
      tokens: Number(cells[2]),
      params: Number(cells[3]),
      length: Number(cells[4]),
      location: cells[5],
      file: cells[6],
      name: cells[7],
      startLine: Number(cells[9]),
      endLine: Number(cells[10]),
    };
    if (Number.isFinite(item.ccn)) functions.push(item);
  }
  const totalNloc = functions.reduce((sum, fn) => sum + (fn.nloc || 0), 0);
  const avgCcn = functions.length
    ? functions.reduce((sum, fn) => sum + (fn.ccn || 0), 0) / functions.length
    : 0;
  const warnings = functions.filter((fn) => fn.ccn > 15 || fn.length > 1000 || fn.params > 100);
  const topComplex = [...functions]
    .sort((a, b) => (b.ccn - a.ccn) || (b.nloc - a.nloc))
    .slice(0, 20);
  return {
    functionCount: functions.length,
    totalNloc,
    avgCcn: Number(avgCcn.toFixed(2)),
    warningCount: warnings.length,
    topComplex,
  };
}

function summarizeJscpd(report) {
  const total = report?.statistics?.total || {};
  const duplicates = Array.isArray(report?.duplicates) ? report.duplicates : [];
  return {
    clones: total.clones ?? duplicates.length,
    duplicatedLines: total.duplicatedLines ?? null,
    duplicatedTokens: total.duplicatedTokens ?? null,
    percentage: total.percentage ?? null,
    percentageTokens: total.percentageTokens ?? null,
    topDuplicates: duplicates
      .map((dup) => ({
        format: dup.format,
        lines: dup.lines,
        first: `${dup.firstFile?.name}:${dup.firstFile?.start}-${dup.firstFile?.end}`,
        second: `${dup.secondFile?.name}:${dup.secondFile?.start}-${dup.secondFile?.end}`,
      }))
      .sort((a, b) => (b.lines || 0) - (a.lines || 0))
      .slice(0, 20),
  };
}

function runCodebaseMemory() {
  const tool = resolveTool("codebase-memory-mcp", false);
  output.tools.codebaseMemoryMcp = tool ? { available: true, source: tool.source } : { available: false };
  if (!tool) return;
  const result = run(tool.command, [...tool.prefixArgs, "cli", "list_projects", "{}"]);
  output.metrics.codebaseMemoryMcp = {
    command: result.command,
    status: result.status,
    error: result.error,
    stderr: firstLines(result.stderr, 20),
  };
  try {
    const jsonStart = result.stdout.indexOf("{");
    output.metrics.codebaseMemoryMcp.projects = jsonStart >= 0 ? JSON.parse(result.stdout.slice(jsonStart)).projects : [];
  } catch (error) {
    output.metrics.codebaseMemoryMcp.parseError = String(error.message || error);
    output.metrics.codebaseMemoryMcp.stdout = firstLines(result.stdout, 20);
  }
}

function runJscpd() {
  const tool = resolveTool("jscpd", allowEphemeralTools);
  output.tools.jscpd = tool ? { available: true, source: tool.source } : { available: false };
  if (!tool) {
    output.metrics.jscpd = { skipped: true, reason: "jscpd not installed; rerun with --allow-ephemeral-tools to use npx" };
    return;
  }
  const reportDir = path.join(tempDir, "jscpd");
  const formats = includeDocDuplicates
    ? "typescript,tsx,javascript,jsx,markdown"
    : "typescript,tsx,javascript,jsx";
  const result = run(tool.command, [
    ...tool.prefixArgs,
    "--silent",
    "--noTips",
    "--max-lines",
    "10000",
    "--format",
    formats,
    "--reporters",
    "json",
    "--output",
    reportDir,
    ...scopes,
  ]);
  const metric = {
    command: result.command,
    status: result.status,
    error: result.error,
    stderr: firstLines(result.stderr, 30),
    stdout: firstLines(result.stdout, 30),
  };
  const reportPath = path.join(reportDir, "jscpd-report.json");
  if (existsSync(reportPath)) {
    try {
      metric.summary = summarizeJscpd(JSON.parse(readFileSync(reportPath, "utf8")));
    } catch (error) {
      metric.parseError = String(error.message || error);
    }
  } else {
    metric.skipped = result.status !== 0;
    metric.reason = "jscpd report was not produced";
  }
  output.metrics.jscpd = metric;
}

function runLizard() {
  const tool = resolveTool("lizard", allowEphemeralTools);
  output.tools.lizard = tool ? { available: true, source: tool.source } : { available: false };
  if (!tool) {
    output.metrics.lizard = { skipped: true, reason: "lizard not installed; rerun with --allow-ephemeral-tools to use uvx" };
    return;
  }
  const result = run(tool.command, [...tool.prefixArgs, "--csv", "-l", "typescript", "-l", "tsx", ...scopes]);
  output.metrics.lizard = {
    command: result.command,
    status: result.status,
    error: result.error,
    stderr: firstLines(result.stderr, 30),
    summary: summarizeLizard(result.stdout),
  };
}

try {
  for (const scope of scopes) {
    if (!/[?*\[\]]/.test(scope) && !existsSync(path.resolve(cwd, scope))) {
      output.notes.push(`Scope does not exist as a literal path: ${scope}`);
    }
  }
  runCodebaseMemory();
  runJscpd();
  runLizard();
} finally {
  try {
    rmSync(tempDir, { recursive: true, force: true });
  } catch {
    // best effort cleanup only
  }
}

output.finishedAt = new Date().toISOString();
process.stdout.write(`${JSON.stringify(output, null, 2)}\n`);
