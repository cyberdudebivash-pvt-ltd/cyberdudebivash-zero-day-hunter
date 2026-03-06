const CyberCommandCenter=(function(){

const API_BASE="http://localhost:8080"

let container
let running=false

const modules={
radar:null,
terminal:null,
timeline:null,
graph:null,
warMode:null,
defense:null,
actorProfiler:null,
campaignAnalyzer:null,
riskMatrix:null,
prediction:null
}

function init(containerId){

container=document.getElementById(containerId)

container.style.background="#020617"
container.style.color="#e5e7eb"
container.style.fontFamily="Orbitron, sans-serif"
container.style.padding="10px"

renderLayout()

initializeModules()

}

function renderLayout(){

container.innerHTML=""

const grid=document.createElement("div")

grid.style.display="grid"
grid.style.gridTemplateColumns="2fr 1fr"
grid.style.gridTemplateRows="360px 360px 360px"
grid.style.gap="10px"

grid.innerHTML=`

<div id="cc_radar"></div>
<div id="cc_terminal"></div>

<div id="cc_timeline"></div>
<div id="cc_graph"></div>

<div id="cc_campaigns"></div>
<div id="cc_prediction"></div>

<div id="cc_actor_profiler"></div>
<div id="cc_risk_matrix"></div>

<div id="cc_war_mode"></div>
<div id="cc_defense_panel"></div>

`

container.appendChild(grid)

}

function initializeModules(){

if(window.ThreatRadarMap){
modules.radar=ThreatRadarMap
modules.radar.init("cc_radar")
modules.radar.start()
}

if(window.ThreatIntelTerminal){
modules.terminal=ThreatIntelTerminal
modules.terminal.init("cc_terminal")
modules.terminal.start()
}

if(window.AIAttackTimeline){
modules.timeline=AIAttackTimeline
modules.timeline.init("cc_timeline")
modules.timeline.start()
}

if(window.GlobalThreatGraph){
modules.graph=GlobalThreatGraph
modules.graph.init("cc_graph")
modules.graph.start()
}

if(window.AICampaignAnalyzer){
modules.campaignAnalyzer=AICampaignAnalyzer
modules.campaignAnalyzer.init("cc_campaigns")
modules.campaignAnalyzer.start()
}

if(window.AIThreatPredictionPanel){
modules.prediction=AIThreatPredictionPanel
modules.prediction.init("cc_prediction")
modules.prediction.start()
}

if(window.AIThreatActorProfiler){
modules.actorProfiler=AIThreatActorProfiler
modules.actorProfiler.init("cc_actor_profiler")
modules.actorProfiler.start()
}

if(window.GlobalRiskMatrix){
modules.riskMatrix=GlobalRiskMatrix
modules.riskMatrix.init("cc_risk_matrix")
modules.riskMatrix.start()
}

if(window.CyberWarModeVisualizer){
modules.warMode=CyberWarModeVisualizer
modules.warMode.init("cc_war_mode")
modules.warMode.start()
}

if(window.AIDefenseControlPanel){
modules.defense=AIDefenseControlPanel
modules.defense.init("cc_defense_panel")
}

}

async function fetchPlatformStatus(){

try{

const res=await fetch(API_BASE+"/api/metrics")
const m=await res.json()

updateHeader(m)

}catch(e){}

}

function updateHeader(metrics){

let header=document.getElementById("cc_header")

if(!header){

header=document.createElement("div")
header.id="cc_header"

header.style.marginBottom="10px"
header.style.padding="10px"
header.style.background="#05070c"
header.style.border="1px solid #1f2937"
header.style.borderRadius="6px"

container.prepend(header)

}

header.innerHTML=`

<b>CYBERDUDEBIVASH ZERO-DAY HUNTER™</b><br>
Global Risk Index: ${metrics.global_risk?.toFixed(2) || "0.00"} |
Active Incidents: ${metrics.active_incidents || 0} |
Critical Alerts: ${metrics.critical_alerts || 0}

`

}

function start(){

if(running)return

running=true

setInterval(fetchPlatformStatus,4000)

}

return{
init:init,
start:start
}

})()

window.CyberCommandCenter=CyberCommandCenter