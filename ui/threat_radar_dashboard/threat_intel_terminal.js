const ThreatIntelTerminal=(function(){

const API_BASE="http://localhost:8080"

let terminal
let logQueue=[]
let running=false
let maxLines=200

function init(containerId){

terminal=document.getElementById(containerId)

terminal.style.background="#05070c"
terminal.style.color="#00ff9c"
terminal.style.fontFamily="monospace"
terminal.style.fontSize="12px"
terminal.style.padding="15px"
terminal.style.height="350px"
terminal.style.overflow="auto"
terminal.style.border="1px solid #1f2937"
terminal.style.borderRadius="10px"

printBanner()

}

function printBanner(){

printLine("CYBERDUDEBIVASH ZERO-DAY HUNTER™ SOC TERMINAL")
printLine("Initializing Threat Intelligence Console...")
printLine("Connecting to Cyber Defense Engines...")
printLine("--------------------------------------------")

}

function timestamp(){

const d=new Date()

return d.toISOString().replace("T"," ").split(".")[0]

}

function printLine(text,type="info"){

const line=document.createElement("div")

let color="#00ff9c"

if(type==="critical")color="#ff4c4c"
if(type==="warning")color="#ffaa00"
if(type==="ai")color="#4adeff"

line.style.color=color

line.textContent="["+timestamp()+"] "+text

terminal.appendChild(line)

terminal.scrollTop=terminal.scrollHeight

while(terminal.children.length>maxLines){
terminal.removeChild(terminal.children[0])
}

}

async function fetchAlerts(){

try{

const res=await fetch(API_BASE+"/api/alerts")
const alerts=await res.json()

alerts.slice(0,5).forEach(a=>{

let type="info"

if(a.severity==="CRITICAL")type="critical"
if(a.severity==="HIGH")type="warning"

logQueue.push({
msg:"ALERT "+a.severity+" → "+a.message,
type:type
})

})

}catch(e){

logQueue.push({
msg:"API connection warning",
type:"warning"
})

}

}

async function fetchIncidents(){

try{

const res=await fetch(API_BASE+"/api/incidents")
const incidents=await res.json()

incidents.slice(0,3).forEach(i=>{

logQueue.push({
msg:"INCIDENT "+i.status+" → "+i.title,
type:"warning"
})

})

}catch(e){}

}

async function fetchMetrics(){

try{

const res=await fetch(API_BASE+"/api/metrics")
const m=await res.json()

logQueue.push({
msg:"GLOBAL RISK INDEX "+m.global_risk.toFixed(2),
type:"ai"
})

if(m.cyber_war_mode){

logQueue.push({
msg:"CYBER WAR MODE ACTIVATED",
type:"critical"
})

}

}catch(e){}

}

function simulateAIReasoning(){

const events=[
"AI analyzing attack propagation patterns",
"Threat correlation engine linking events",
"Defense AI evaluating mitigation strategies",
"Threat attribution engine scoring adversary confidence",
"Anomaly engine recalibrating baseline behavior"
]

const msg=events[Math.floor(Math.random()*events.length)]

logQueue.push({
msg:"AI ENGINE → "+msg,
type:"ai"
})

}

function simulateDefenseAction(){

const actions=[
"Blocking malicious IP cluster",
"Deploying WAF protection rules",
"Isolating compromised host",
"Activating DDoS protection",
"Updating threat intelligence feeds"
]

const msg=actions[Math.floor(Math.random()*actions.length)]

logQueue.push({
msg:"DEFENSE ACTION → "+msg,
type:"warning"
})

}

function processQueue(){

if(logQueue.length===0)return

const item=logQueue.shift()

printLine(item.msg,item.type)

}

async function collectData(){

await fetchAlerts()
await fetchIncidents()
await fetchMetrics()

simulateAIReasoning()
simulateDefenseAction()

}

function start(){

if(running)return

running=true

setInterval(processQueue,600)

setInterval(collectData,4000)

printLine("Threat Intelligence Terminal Online","ai")

}

return{
init:init,
start:start
}

})()

window.ThreatIntelTerminal=ThreatIntelTerminal