import pty from "node-pty";
process.title = "claude-code-pty-wrapper";

const shell = pty.spawn("claude", [], {
  name: "xterm-color",
  cols: 80,
  rows: 30,
  cwd: import.meta.dir,
  env: process.env,
});

shell.on("data", function (data) {
  let lines = data.toString().split("\n");

  let foundCursorLine = -1;

  for (let i = 0; i < lines.length; i++) {
    if (!lines[i].includes(">") && !lines[i].includes("#")) continue;

    const beforeLine = lines.at(i - 1);
    const afterLine = lines.at(i + 1);
    if (!beforeLine || !afterLine) continue;
    if (!beforeLine.includes("╭")) continue;
    if (!afterLine.includes("╰")) continue;

    foundCursorLine = i;
    break;
  }

  if (foundCursorLine !== -1) {
    delete lines[foundCursorLine - 1];
    delete lines[foundCursorLine];
    delete lines[foundCursorLine + 1];
    delete lines[foundCursorLine + 2];
  }

  process.stdout.write(lines.join("\n"));

  // process.stdout.write(data);
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
