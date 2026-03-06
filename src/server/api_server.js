const express = require("express");

const app = express();
const PORT = 8080;

app.use(express.json());

app.get("/api/health", (req, res) => {
    res.json({
        status: "CYBERDUDEBIVASH PLATFORM ACTIVE"
    });
});

app.get("/api/threats", (req, res) => {

    res.json({
        threats: [
            {
                id: "T1001",
                type: "Malware Beacon",
                risk: 9.4,
                source: "SensorGrid"
            },
            {
                id: "T1002",
                type: "Suspicious Lateral Movement",
                risk: 8.1,
                source: "ThreatGraph"
            }
        ]
    });

});

app.listen(PORT, () => {
    console.log("CyberDudeBivash API running on port", PORT);
});