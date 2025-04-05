process.title = "claude-code-wrapper";

process.stdin.on("data", (data) => {
  let lines = data.toString().split("\n");

  let foundCursorLine = -1;

  for (let i = 0; i < lines.length; i++) {
    if (!lines[i].includes(">") && !lines[i].includes("#")) continue;

    const beforeLine = lines.at(i - 1);
    const afterLine = lines.at(i + 1);
    if (!beforeLine || !afterLine) continue;
    if (!beforeLine.startsWith("╭")) continue;
    if (!afterLine.startsWith("╰")) continue;

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
});
