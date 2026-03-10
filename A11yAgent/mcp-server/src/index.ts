#!/usr/bin/env node

import { spawn } from "node:child_process";
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

/** Use A11Y_CHECK_PATH for a local build (e.g. .../A11yAgent/.build/debug/a11y-check), else "a11y-check" from PATH. */
const A11Y_CHECK_CMD = process.env.A11Y_CHECK_PATH ?? "a11y-check";

const server = new Server(
  {
    name: "a11y-check",
    version: "0.1.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "run_a11y_check",
      description:
        "Run the SwiftUI accessibility checker (a11y-check) on Swift source paths. Use when the user wants to check their iOS/SwiftUI code for accessibility issues. Paths are resolved relative to projectRoot (or A11Y_PROJECT_ROOT env or the process cwd). Set projectRoot to the workspace/repo root so relative paths like 'iOSswiftUIa11yTechniques' or 'Sources/' resolve correctly.",
      inputSchema: {
        type: "object" as const,
        properties: {
          paths: {
            type: "array",
            items: { type: "string" },
            description:
              "File or directory paths to analyze (e.g. ['Sources/'], ['iOSswiftUIa11yTechniques']). Resolved relative to projectRoot.",
          },
          projectRoot: {
            type: "string",
            description:
              "Project/workspace root directory. Paths are resolved relative to this. Use the repo root (e.g. absolute path to the project) so relative paths work. If omitted, uses A11Y_PROJECT_ROOT env or process cwd.",
          },
          only: {
            type: "string",
            enum: ["info", "warning", "error"],
            description:
              "Only show diagnostics at or above this severity (default: show all)",
          },
          disable: {
            type: "string",
            description:
              "Comma-separated rule IDs to disable (e.g. 'image-missing-label,fixed-font-size')",
          },
          maxDiagnostics: {
            type: "number",
            description:
              "Max number of diagnostics to include (default 25). Keeps output short for easy scrolling. Use 0 for full list.",
          },
        },
        required: ["paths"],
      },
    },
    {
      name: "list_a11y_rules",
      description:
        "List all available a11y-check rules (IDs, names, severities, WCAG criteria). Use when the user wants to see what rules exist or which rule IDs can be disabled. Requires a11y-check to be installed.",
      inputSchema: {
        type: "object" as const,
        properties: {},
      },
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  if (name === "list_a11y_rules") {
    const { stdout, stderr, code } = await runA11yCheck(["--list-rules"], {});
    if (code !== 0 && stderr) {
      const installHint = A11Y_CHECK_CMD === "a11y-check"
        ? "Install with: brew tap cvs-health/ios-swiftui-accessibility-techniques && brew install a11y-check — or set A11Y_CHECK_PATH to your local build."
        : `Binary: ${A11Y_CHECK_CMD}`;
      return {
        content: [
          {
            type: "text" as const,
            text: `a11y-check failed (exit ${code}). ${installHint}\n\nstderr: ${stderr}`,
          },
        ],
        isError: true,
      };
    }
    return {
      content: [{ type: "text" as const, text: stdout || "(no output)" }],
    };
  }

  if (name === "run_a11y_check") {
    const paths = (args?.paths as string[] | undefined) ?? ["."];
    const projectRoot = (args?.projectRoot as string | undefined) ?? process.env.A11Y_PROJECT_ROOT ?? process.cwd();
    const only = args?.only as string | undefined;
    const disable = args?.disable as string | undefined;
    const maxDiagnostics = (args?.maxDiagnostics as number | undefined) ?? 25;

    const cliArgs = [...paths, "--format", "json"];
    if (only) cliArgs.push("--only", only);
    if (disable) cliArgs.push("--disable", disable);

    const { stdout, stderr, code } = await runA11yCheck(cliArgs, { cwd: projectRoot });

    // Exit 0 = no errors; exit 1 = run succeeded but has error-level findings (a11y-check convention)
    const runFailed = code === null || (code !== 0 && code !== 1);
    if (runFailed) {
      const msg =
        stderr?.trim() || stdout?.trim() || `Exit code ${code}`;
      return {
        content: [
          {
            type: "text" as const,
            text: `a11y-check failed (exit ${code}). ${msg}\n\nIf a11y-check is not installed: brew install a11y-check (after tap) or set A11Y_CHECK_PATH to your A11yAgent/.build/debug/a11y-check path.`,
          },
        ],
        isError: true,
      };
    }

    let text = stdout?.trim() ?? "[]";
    try {
      const diagnostics = JSON.parse(text) as Array<{
        ruleID?: string;
        severity?: string;
        message?: string;
        filePath?: string;
        line?: number;
        column?: number;
        wcagCriteria?: string[];
      }>;
      const count = diagnostics.length;
      if (count === 0) {
        text = "No accessibility issues found.";
      } else {
        const summary = diagnostics.reduce(
          (acc, d) => {
            acc[d.severity ?? "info"] = (acc[d.severity ?? "info"] ?? 0) + 1;
            return acc;
          },
          {} as Record<string, number>
        );
        const limit = maxDiagnostics > 0 ? Math.min(maxDiagnostics, count) : count;
        const shown = diagnostics.slice(0, limit);
        const limitNote =
          limit < count
            ? `\n(Showing first ${limit} of ${count}. Pass maxDiagnostics: 0 for full list.)\n\n`
            : "\n\n";

        // Group by file; use compact list format (no tables) for easy reading in scroll view
        const byFile = new Map<string, typeof shown>();
        for (const d of shown) {
          const file = d.filePath ?? "(unknown)";
          if (!byFile.has(file)) byFile.set(file, []);
          byFile.get(file)!.push(d);
        }

        const lines: string[] = [];
        const err = summary.error ?? 0;
        const warn = summary.warning ?? 0;
        lines.push(`**A11y check:** ${count} issues (${err} errors, ${warn} warnings).${limit < count ? ` Showing first ${limit} of ${count}. Say "full list" for all.` : ""}`);
        lines.push("");

        for (const [filePath, list] of byFile) {
          const parts = filePath.split("/").filter(Boolean);
          const shortPath = parts.length >= 2 ? parts.slice(-2).join("/") : filePath;
          lines.push(`**${shortPath}**`);
          for (const d of list) {
            const ln = String(d.line ?? "?");
            const sev = d.severity ?? "info";
            const rule = d.ruleID ?? "";
            const msg = (d.message ?? "").replace(/\n/g, " ").trim();
            lines.push(`  • ${ln} · ${sev} · ${rule} — ${msg}`);
          }
          lines.push("");
        }

        lines.push("Run list_a11y_rules for all rules. Say \"run_a11y_check full list\" for all diagnostics.");
        text = lines.join("\n");
      }
    } catch {
      // Leave raw output if not JSON
    }

    return {
      content: [{ type: "text" as const, text }],
    };
  }

  return {
    content: [{ type: "text" as const, text: `Unknown tool: ${name}` }],
    isError: true,
  };
});

function runA11yCheck(
  args: string[],
  options: { cwd?: string } = {}
): Promise<{
  stdout: string;
  stderr: string;
  code: number | null;
}> {
  const cwd = options.cwd || process.cwd();
  return new Promise((resolve) => {
    const proc = spawn(A11Y_CHECK_CMD, args, {
      stdio: ["ignore", "pipe", "pipe"],
      cwd,
    });
    let stdout = "";
    let stderr = "";
    proc.stdout?.on("data", (chunk) => {
      stdout += chunk.toString();
    });
    proc.stderr?.on("data", (chunk) => {
      stderr += chunk.toString();
    });
    proc.on("close", (code) => {
      resolve({ stdout, stderr, code: code ?? null });
    });
    proc.on("error", (err) => {
      resolve({
        stdout: "",
        stderr: err.message,
        code: null,
      });
    });
  });
}

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
