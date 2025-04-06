import net from "node:net";
let loggingServer;

export function startLoggingServer() {
  loggingServer = net.createServer(function (socket) {
    socket.on("data", function (data) {
      console.log(JSON.stringify(data.toString()));
    });
  });
  loggingServer.listen(8000, () => {
    console.log("Logging server started on port 8000");
  });
  return loggingServer;
}

let socket;

export function connectToLoggingServer() {
  socket = net.connect(8000);
  return socket;
}

export function log(...args) {
  if (!socket) {
    console.log("Socket not connected");
    return;
  }
  socket.write(
    args
      .map((v) => {
        if (typeof v === "object") {
          return JSON.stringify(v, null, 2);
        }
        return String(v);
      })
      .join(" ") + "\n",
  );
}

if (process.argv.includes("--start")) {
  startLoggingServer();
}
