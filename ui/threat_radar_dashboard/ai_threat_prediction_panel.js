const AIThreatPredictionPanel=(function(){

const API_BASE="http://localhost:8080"

let container
let predictions=[]
let running=false

const regions=[
"US-EAST",
"US-WEST",
"EU-WEST",
"EU-CENTRAL",
"APAC",
"LATAM",
"MEA"
]

const attackTypes=[
"Exploit Campaign",
"Credential Harvesting",
"Malware Propagation",
"Phishing Wave",
"DDoS Burst",
"Supply Chain Intrusion"
]

function init(containerId){

container=document.getElementById(containerId)

container.style.background="#05070c"
container.style.border="1px solid #1f2937"
container.style.borderRadius="10px"
container.style.padding="20px"
container.style.fontFamily="Orbitron, sans-serif"
container.style.height="420px"
container.style.overflow="auto"

renderHeader()

}

function renderHeader(){

const h=document.createElement("div")
h.innerText="AI THREAT PREDICTION ENGINE"
h.style.color="#38bdf8"
h.style.marginBottom="10px"

container.appendChild(h)

}

function timestamp(){

const d=new Date()
return d.toISOString().replace("T"," ").split(".")[0]

}

function randomRegion(){

return regions[Math.floor(Math.random()*regions.length)]

}

function randomAttack(){

return attackTypes[Math.floor(Math.random()*attackTypes.length)]

}

function forecastWindow(){

const windows=[
"Next 5 minutes",
"Next 15 minutes",
"Next 1 hour",
"Next 6 hours"
]

return windows[Math.floor(Math.random()*windows.length)]

}

function createPrediction(){

const p={
region:randomRegion(),
type:randomAttack(),
probability:(Math.random()*0.4+0.5).toFixed(2),
window:forecastWindow(),
created:timestamp()
}

predictions.unshift(p)

if(predictions.length>10){
predictions.pop()
}

}

function probabilityColor(v){

v=parseFloat(v)

if(v>0.85)return "#ef4444"
if(v>0.7)return "#f97316"
if(v>0.6)return "#facc15"

return "#22c55e"

}

function render(){

container.innerHTML=""

renderHeader()

predictions.forEach(p=>{

const card=document.createElement("div")

card.style.border="1px solid #1f2937"
card.style.borderRadius="6px"
card.style.padding="10px"
card.style.marginBottom="10px"
card.style.background="#020617"

const title=document.createElement("div")
title.innerText=p.type
title.style.color="#f97316"
title.style.fontWeight="bold"

const region=document.createElement("div")
region.style.fontSize="12px"
region.innerText="Target Region: "+p.region

const window=document.createElement("div")
window.style.fontSize="12px"
window.innerText="Prediction Window: "+p.window

const prob=document.createElement("div")
prob.style.fontSize="12px"
prob.style.color=probabilityColor(p.probability)
prob.innerText="Attack Probability: "+p.probability

const time=document.createElement("div")
time.style.fontSize="11px"
time.style.color="#64748b"
time.innerText="Generated: "+p.created

card.appendChild(title)
card.appendChild(region)
card.appendChild(window)
card.appendChild(prob)
card.appendChild(time)

container.appendChild(card)

})

}

async function fetchMetrics(){

try{

const m=await fetch(API_BASE+"/api/metrics").then(r=>r.json())

if(m.global_risk>0.6){

createPrediction()

}

}catch(e){}

}

async function fetchAlerts(){

try{

const alerts=await fetch(API_BASE+"/api/alerts").then(r=>r.json())

alerts.slice(0,2).forEach(()=>{
createPrediction()
})

}catch(e){}

}

async function fetchIncidents(){

try{

const incidents=await fetch(API_BASE+"/api/incidents").then(r=>r.json())

if(incidents.length>0){

createPrediction()

}

}catch(e){}

}

async function runPrediction(){

await fetchMetrics()
await fetchAlerts()
await fetchIncidents()

render()

}

function start(){

if(running)return

running=true

setInterval(runPrediction,5000)

}

return{
init:init,
start:start
}

})()

window.AIThreatPredictionPanel=AIThreatPredictionPanel