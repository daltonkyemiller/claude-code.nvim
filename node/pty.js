import pty from "node-pty";
import { stripAnsi } from "./strip-ansi.js";
import { connectToLoggingServer, log } from "./logging.js";

process.title = "claude-code-pty-wrapper";

const colsArg = Number.parseInt(
  process.argv[process.argv.indexOf("--cols") + 1],
);

const rowsArg = Number.parseInt(
  process.argv[process.argv.indexOf("--rows") + 1],
);

const cmdArg = process.argv[process.argv.indexOf("--cmd") + 1];

const shell = pty.spawn(cmdArg, [], {
  name: "xterm-color",
  cols: colsArg,
  rows: rowsArg,
  cwd: import.meta.dir,
  env: process.env,
});

if (process.argv.includes("--debug")) {
  connectToLoggingServer();
  log("Debug mode enabled");
}

function stripInputBox(text) {
  let lines = text.split("\n");

  // Store arrays of input box ranges [start, end]
  let inputBoxes = [];
  let currentStart = -1;

  for (let i = 0; i < lines.length; i++) {
    const stripped = stripAnsi(lines[i]);

    // Found start of an input box
    if (stripped.includes("│ >")) {
      currentStart = i;
      continue;
    }

    // If we're looking for the end of a box
    if (currentStart !== -1 && stripped.startsWith("╰")) {
      inputBoxes.push([currentStart, i]);
      currentStart = -1; // Reset for next box
    }
  }

  // If we found no input boxes, return original text
  if (inputBoxes.length === 0) return text;

  // Process each input box range
  // We process from end to start to avoid index shifting
  inputBoxes.reverse().forEach(([start, end]) => {
    // Replace the input box content with empty lines
    for (let i = start - 1; i <= end + 1; i++) {
      lines[i] = "";
    }
  });

  // Remove empty lines and join
  const final = lines.join("\n");

  return final;
}

let buffer = "";

shell.on("data", function (data) {
  buffer += data;
  debounceRender();
});

function debounceRender() {
  clearTimeout(debounceRender.timer);
  debounceRender.timer = setTimeout(() => {
    const filtered = stripInputBox(buffer);

    process.stdout.write(filtered);

    buffer = ""; // reset buffer
  }, 50);
}

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
