const CyberThreatIntelligenceFusionEngine=(function(){

let runtime
let running=false

const intelState={
indicators:[],
actors:[],
campaigns:[],
knowledgeGraph:{
nodes:[],
edges:[]
}
}

const feeds=[
"internal_alerts",
"incident_reports",
"campaign_analyzer",
"actor_profiler",
"prediction_engine"
]

function init(runtimeInstance){

runtime=runtimeInstance

registerRuntimeEvents()

log("Threat Intelligence Fusion Engine initialized")

}

function log(msg){

console.log("[INTEL-FUSION]",msg)

}

function registerRuntimeEvents(){

runtime.subscribe("alerts_update",processAlerts)

runtime.subscribe("incidents_update",processIncidents)

runtime.subscribe("ai_incident_generated",processAIIncident)

runtime.subscribe("simulation_stage",processSimulation)

}

function processAlerts(alerts){

alerts.forEach(a=>{

extractIndicators(a)

})

buildKnowledgeGraph()

}

function processIncidents(incidents){

incidents.forEach(i=>{

registerCampaign({
name:i.title,
source:"incident",
severity:i.severity
})

})

}

function processAIIncident(incident){

registerCampaign({
name:incident.title,
source:"ai",
severity:incident.severity
})

}

function processSimulation(event){

registerCampaign({
name:event.stage,
source:"simulation",
severity:"SIMULATED"
})

}

function extractIndicators(alert){

const ioc={
id:Date.now()+Math.random(),
type:"alert_indicator",
value:alert.message || "unknown",
source:"alert"
}

intelState.indicators.push(ioc)

runtime.publish("ioc_detected",ioc)

}

function registerCampaign(data){

const campaign={
id:Date.now()+Math.random(),
name:data.name,
source:data.source,
severity:data.severity,
created:new Date().toISOString()
}

intelState.campaigns.push(campaign)

runtime.publish("campaign_registered",campaign)

}

function registerActor(name){

const actor={
id:Date.now()+Math.random(),
name:name,
confidence:Math.random()
}

intelState.actors.push(actor)

runtime.publish("actor_detected",actor)

}

function buildKnowledgeGraph(){

intelState.knowledgeGraph.nodes=[]
intelState.knowledgeGraph.edges=[]

intelState.indicators.forEach(i=>{

intelState.knowledgeGraph.nodes.push({
id:i.id,
type:"indicator",
value:i.value
})

})

intelState.campaigns.forEach(c=>{

intelState.knowledgeGraph.nodes.push({
id:c.id,
type:"campaign",
value:c.name
})

})

intelState.indicators.forEach(i=>{

intelState.campaigns.forEach(c=>{

intelState.knowledgeGraph.edges.push({
from:i.id,
to:c.id,
relation:"related"
})

})

})

runtime.publish("knowledge_graph_updated",intelState.knowledgeGraph)

}

function enrichIndicators(){

intelState.indicators.forEach(i=>{

i.reputation=Math.random()
i.riskScore=Math.random()

})

runtime.publish("indicator_enriched",intelState.indicators)

}

function correlateCampaigns(){

const clusters=[]

intelState.campaigns.forEach(c=>{

if(Math.random()>0.6){

clusters.push({
campaign:c,
cluster:"coordinated_attack"
})

}

})

runtime.publish("campaign_clusters",clusters)

}

function runFusionCycle(){

enrichIndicators()

correlateCampaigns()

buildKnowledgeGraph()

}

function getState(){

return intelState

}

function start(){

if(running)return

running=true

log("Threat Intelligence Fusion Engine running")

setInterval(runFusionCycle,4000)

}

function stop(){

running=false

log("Fusion engine stopped")

}

return{

init:init,
start:start,
stop:stop,

getState:getState

}

})()

window.CyberThreatIntelligenceFusionEngine=CyberThreatIntelligenceFusionEngine