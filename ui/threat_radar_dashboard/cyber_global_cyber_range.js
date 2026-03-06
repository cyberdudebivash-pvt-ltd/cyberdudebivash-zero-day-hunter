const CyberGlobalCyberRange=(function(){

let runtime
let running=false

let rangeId=0

const activeScenarios=[]
const participatingNodes=[]

const rangeState={
scenarios:[],
results:[],
activeExercises:0
}

const scenarioTemplates=[

{
name:"APT Intrusion Campaign",
stages:[
"Reconnaissance",
"Initial Exploit",
"Credential Harvesting",
"Lateral Movement",
"Command and Control",
"Data Exfiltration"
]
},

{
name:"Global Ransomware Outbreak",
stages:[
"Initial Access",
"Privilege Escalation",
"Network Propagation",
"Encryption Deployment",
"Command and Control"
]
},

{
name:"Supply Chain Compromise",
stages:[
"Dependency Injection",
"Malicious Update Distribution",
"Endpoint Infection",
"Data Collection"
]
},

{
name:"Mass Phishing Campaign",
stages:[
"Email Distribution",
"Credential Harvesting",
"Account Takeover",
"Fraud Operations"
]
}

]

function init(runtimeInstance){

runtime=runtimeInstance

registerRuntimeEvents()

log("Global Cyber Range initialized")

}

function log(msg){

console.log("[CYBER-RANGE]",msg)

}

function registerRuntimeEvents(){

runtime.subscribe("simulation_started",handleSimulation)

runtime.subscribe("defense_recommendation",recordDefense)

runtime.subscribe("ai_incident_generated",recordIncident)

}

function registerNode(node){

participatingNodes.push(node)

log("Node joined cyber range: "+node.id)

}

function createScenario(){

rangeId++

const template=randomItem(scenarioTemplates)

const scenario={
id:rangeId,
name:template.name,
stages:template.stages,
status:"running",
started:new Date().toISOString(),
stageIndex:0
}

activeScenarios.push(scenario)

rangeState.activeExercises++

log("Scenario started: "+scenario.name)

runtime.publish("cyber_range_scenario_started",scenario)

runScenarioStages(scenario)

}

function randomItem(arr){

return arr[Math.floor(Math.random()*arr.length)]

}

function runScenarioStages(scenario){

function runStage(){

if(scenario.stageIndex>=scenario.stages.length){

completeScenario(scenario)
return
}

const stage=scenario.stages[scenario.stageIndex]

runtime.publish("cyber_range_stage",{
scenario:scenario,
stage:stage
})

log("Scenario stage: "+stage)

scenario.stageIndex++

setTimeout(runStage,2000)

}

runStage()

}

function completeScenario(scenario){

scenario.status="completed"
scenario.completed=new Date().toISOString()

rangeState.scenarios.push(scenario)

rangeState.activeExercises--

log("Scenario completed")

evaluateRangePerformance(scenario)

runtime.publish("cyber_range_completed",scenario)

}

function evaluateRangePerformance(scenario){

const defenseScore=Math.random()

const result={
scenario:scenario,
defenseScore:defenseScore,
evaluation:new Date().toISOString()
}

rangeState.results.push(result)

runtime.publish("cyber_range_evaluation",result)

if(defenseScore<0.5){

runtime.publish("cyber_range_defense_failure",scenario)

}else{

runtime.publish("cyber_range_defense_success",scenario)

}

}

function handleSimulation(sim){

log("Simulation observed in cyber range")

}

function recordDefense(strategy){

log("Defense action recorded")

}

function recordIncident(incident){

log("Incident recorded in cyber range")

}

function startExerciseBatch(count){

for(let i=0;i<count;i++){

setTimeout(()=>{

createScenario()

},i*3000)

}

}

function getRangeState(){

return rangeState

}

function start(){

if(running)return

running=true

log("Cyber Range active")

}

function stop(){

running=false

log("Cyber Range stopped")

}

return{

init:init,
start:start,
stop:stop,

createScenario:createScenario,
startExerciseBatch:startExerciseBatch,
registerNode:registerNode,

getRangeState:getRangeState

}

})()

window.CyberGlobalCyberRange=CyberGlobalCyberRange