const AIAttackTimeline=(function(){

const API_BASE="http://localhost:8080"

let container
let events=[]
let maxEvents=50
let running=false

const stages=[
"Reconnaissance",
"Exploitation",
"Credential Access",
"Lateral Movement",
"Command & Control",
"Defense Response"
]

function init(containerId){

container=document.getElementById(containerId)

container.style.background="#05070c"
container.style.border="1px solid #1f2937"
container.style.borderRadius="10px"
container.style.padding="15px"
container.style.height="360px"
container.style.overflow="auto"
container.style.fontFamily="monospace"
container.style.color="#e5e7eb"

renderHeader()

}

function renderHeader(){

const h=document.createElement("div")

h.style.fontSize="14px"
h.style.marginBottom="10px"
h.style.color="#38bdf8"

h.innerText="AI ATTACK TIMELINE — CAMPAIGN PROPAGATION"

container.appendChild(h)

}

function timestamp(){

const d=new Date()
return d.toISOString().replace("T"," ").split(".")[0]

}

function stageColor(stage){

if(stage==="Reconnaissance")return "#4ade80"
if(stage==="Exploitation")return "#f59e0b"
if(stage==="Credential Access")return "#f97316"
if(stage==="Lateral Movement")return "#fb7185"
if(stage==="Command & Control")return "#ef4444"
if(stage==="Defense Response")return "#38bdf8"

return "#94a3b8"

}

function createEvent(stage,message){

const event={
time:timestamp(),
stage:stage,
message:message
}

events.unshift(event)

if(events.length>maxEvents){
events.pop()
}

render()

}

function render(){

container.innerHTML=""

renderHeader()

events.forEach(e=>{

const row=document.createElement("div")

row.style.borderBottom="1px solid #1f2937"
row.style.padding="8px 0"

const stage=document.createElement("span")
stage.style.color=stageColor(e.stage)
stage.style.fontWeight="bold"
stage.innerText=e.stage

const time=document.createElement("span")
time.style.marginLeft="10px"
time.style.color="#64748b"
time.innerText=e.time

const msg=document.createElement("div")
msg.style.marginTop="3px"
msg.style.fontSize="12px"
msg.innerText=e.message

row.appendChild(stage)
row.appendChild(time)
row.appendChild(msg)

container.appendChild(row)

})

}

async function fetchAlerts(){

try{

const res=await fetch(API_BASE+"/api/alerts")
const alerts=await res.json()

alerts.slice(0,3).forEach(a=>{

createEvent(
"Exploitation",
"Alert detected → "+a.message
)

})

}catch(e){

createEvent(
"Reconnaissance",
"Threat sensors scanning anomaly signals"
)

}

}

async function fetchIncidents(){

try{

const res=await fetch(API_BASE+"/api/incidents")
const incidents=await res.json()

incidents.slice(0,2).forEach(i=>{

createEvent(
"Lateral Movement",
"Incident "+i.status+" → "+i.title
)

})

}catch(e){}

}

async function fetchMetrics(){

try{

const res=await fetch(API_BASE+"/api/metrics")
const m=await res.json()

if(m.global_risk>0.7){

createEvent(
"Command & Control",
"AI threat engine escalating global risk index "+m.global_risk.toFixed(2)
)

}

if(m.cyber_war_mode){

createEvent(
"Defense Response",
"Cyber War Mode activated — defense protocols engaged"
)

}

}catch(e){}

}

function simulateAI(){

const msgs=[
"ThreatReasoningEngine correlating cross-region attacks",
"AttackPropagationModel predicting attack spread",
"ThreatActorAttributionEngine scoring adversary confidence",
"Campaign predictor identifying coordinated attack patterns",
"Defense AI evaluating mitigation strategies"
]

const msg=msgs[Math.floor(Math.random()*msgs.length)]

createEvent(
stages[Math.floor(Math.random()*stages.length)],
"AI ANALYSIS → "+msg
)

}

async function collectData(){

await fetchAlerts()
await fetchIncidents()
await fetchMetrics()

simulateAI()

}

function start(){

if(running)return

running=true

setInterval(collectData,4000)

createEvent(
"Reconnaissance",
"Threat intelligence engines initialized"
)

}

return{
init:init,
start:start
}

})()

window.AIAttackTimeline=AIAttackTimeline