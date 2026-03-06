const RealtimeAttackStream=(function(){

const API_BASE="http://localhost:8080"

let container
let streamArea
let running=false
let maxEvents=300
let queue=[]

const attackTypes=[
"Exploit Attempt",
"Credential Attack",
"Malware Delivery",
"Botnet Traffic Burst",
"Phishing Injection",
"Command & Control Beacon"
]

const regions=[
"US-EAST",
"US-WEST",
"EU-WEST",
"EU-CENTRAL",
"APAC",
"LATAM",
"MEA"
]

const targets=[
"Web Gateway",
"Cloud API",
"Identity Provider",
"Endpoint Fleet",
"Database Cluster",
"Edge Firewall"
]

function init(containerId){

container=document.getElementById(containerId)

container.style.background="#020617"
container.style.border="1px solid #1f2937"
container.style.borderRadius="10px"
container.style.padding="15px"
container.style.fontFamily="monospace"
container.style.height="420px"
container.style.display="flex"
container.style.flexDirection="column"

renderHeader()

streamArea=document.createElement("div")
streamArea.style.flex="1"
streamArea.style.overflow="auto"
streamArea.style.fontSize="12px"
streamArea.style.color="#e5e7eb"

container.appendChild(streamArea)

}

function renderHeader(){

const header=document.createElement("div")

header.innerText="REALTIME GLOBAL ATTACK STREAM"

header.style.color="#38bdf8"
header.style.marginBottom="10px"
header.style.fontWeight="bold"

container.appendChild(header)

}

function timestamp(){

const d=new Date()
return d.toISOString().replace("T"," ").split(".")[0]

}

function randomRegion(){

return regions[Math.floor(Math.random()*regions.length)]

}

function randomTarget(){

return targets[Math.floor(Math.random()*targets.length)]

}

function randomAttack(){

return attackTypes[Math.floor(Math.random()*attackTypes.length)]

}

function severityColor(type){

if(type==="critical")return "#ef4444"
if(type==="high")return "#f97316"
if(type==="medium")return "#facc15"

return "#22c55e"

}

function generateEvent(){

const severityLevels=["low","medium","high","critical"]

const severity=severityLevels[Math.floor(Math.random()*severityLevels.length)]

const event={
time:timestamp(),
attack:randomAttack(),
region:randomRegion(),
target:randomTarget(),
severity:severity
}

queue.push(event)

}

function renderEvent(e){

const line=document.createElement("div")

line.style.borderBottom="1px solid #1f2937"
line.style.padding="4px 0"

const sev=document.createElement("span")
sev.innerText=e.severity.toUpperCase()
sev.style.color=severityColor(e.severity)
sev.style.marginRight="6px"

const text=document.createElement("span")

text.innerText=
`[${e.time}] ${e.attack} detected in ${e.region} targeting ${e.target}`

line.appendChild(sev)
line.appendChild(text)

streamArea.appendChild(line)

streamArea.scrollTop=streamArea.scrollHeight

while(streamArea.children.length>maxEvents){

streamArea.removeChild(streamArea.children[0])

}

}

function processQueue(){

if(queue.length===0)return

const e=queue.shift()

renderEvent(e)

}

async function fetchAlerts(){

try{

const alerts=await fetch(API_BASE+"/api/alerts").then(r=>r.json())

alerts.slice(0,3).forEach(()=>generateEvent())

}catch(e){

generateEvent()

}

}

async function fetchIncidents(){

try{

const incidents=await fetch(API_BASE+"/api/incidents").then(r=>r.json())

incidents.slice(0,2).forEach(()=>generateEvent())

}catch(e){}

}

async function fetchMetrics(){

try{

const m=await fetch(API_BASE+"/api/metrics").then(r=>r.json())

if(m.global_risk>0.75){

generateEvent()
generateEvent()

}

}catch(e){}

}

async function collectTelemetry(){

await fetchAlerts()
await fetchIncidents()
await fetchMetrics()

}

function start(){

if(running)return

running=true

setInterval(processQueue,200)

setInterval(collectTelemetry,2000)

}

return{
init:init,
start:start
}

})()

window.RealtimeAttackStream=RealtimeAttackStream