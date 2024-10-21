const express = require("express");
const app = express();
const port = 3000;

async function getKubernetesInfo() {
  const podInfo = {
    name: process.env.POD_NAME || "unknown",
    ip: process.env.POD_IP || "unknown",
  };

  const nodeInfo = {
    name: process.env.NODE_NAME || "unknown",
    ip: process.env.NODE_IP || "unknown",
  };

  const namespace = process.env.NAMESPACE || "unknown";

  return {
    namespace: namespace,
    pod: podInfo,
    node: nodeInfo,
  };
}

app.get("/", async (req, res) => {
  const kubernetesInfo = await getKubernetesInfo();
  res.setHeader("Content-Type", "application/json");
  res.send(JSON.stringify(kubernetesInfo, null, 2));
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});
