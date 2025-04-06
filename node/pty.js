import pty from "node-pty";
import stripAnsi from "strip-ansi";

process.title = "claude-code-pty-wrapper";

const colsArg = Number.parseInt(
  process.argv[process.argv.indexOf("--cols") + 1],
);

const cmdArg = process.argv[process.argv.indexOf("--cmd") + 1];

const shell = pty.spawn(cmdArg, [], {
  name: "xterm-color",
  cols: colsArg,
  rows: 50,
  cwd: import.meta.dir,
  env: process.env,
});

function stripInputBox(text) {
  let lines = text.split("\r\n");
  let strippedLines = lines.map((line) => stripAnsi(line));

  let inputLineIdx = -1;
  let bottomInputLineIdx = -1;

  for (let i = 0; i < strippedLines.length; i++) {
    if (strippedLines[i].startsWith("│ >")) {
      inputLineIdx = i;
      continue;
    }
    if (inputLineIdx === -1) continue;

    if (strippedLines[i].startsWith("╰")) {
      bottomInputLineIdx = i;
      break;
    }
  }

  if (bottomInputLineIdx === -1 || inputLineIdx === -1) return text;

  for (let i = inputLineIdx - 1; i <= bottomInputLineIdx + 1; i++) {
    delete lines[i];
  }

  return lines.join("\r\n");
}

shell.on("data", function (data) {
  process.stdout.write(stripInputBox(data));
});

if (process.stdin.isTTY) {
  process.stdin.setRawMode(true);
}

process.stdin.resume(); // Needed to start reading from stdin
process.stdin.on("data", function (data) {
  shell.write(data);
});

process.on("SIGINT", function () {
  shell.kill();
  process.exit();
});

shell.on("exit", function (code) {
  console.log("Claude exited with code:", code);
  process.exit(code);
});
