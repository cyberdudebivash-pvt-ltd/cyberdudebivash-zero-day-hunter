const AIThreatActorProfiler=(function(){

const API_BASE="http://localhost:8080"

let container
let actors={}
let running=false

const actorNames=[
"APT29",
"Lazarus Group",
"APT41",
"Sandworm",
"Unknown Cluster"
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
h.innerText="AI THREAT ACTOR PROFILER"
h.style.color="#38bdf8"
h.style.marginBottom="10px"

container.appendChild(h)

}

function timestamp(){

const d=new Date()
return d.toISOString().replace("T"," ").split(".")[0]

}

function randomActor(){

return actorNames[Math.floor(Math.random()*actorNames.length)]

}

function createActor(name){

if(actors[name])return

actors[name]={
name:name,
campaigns:[],
ttps:[],
incidents:[],
confidence:(Math.random()*0.4+0.5).toFixed(2),
risk:(Math.random()*0.4+0.4).toFixed(2),
lastSeen:timestamp()
}

}

function addCampaign(actor){

const campaigns=[
"Exploit Campaign",
"Credential Harvesting",
"Supply Chain Intrusion",
"Phishing Wave",
"Malware Deployment"
]

actors[actor].campaigns.push(
campaigns[Math.floor(Math.random()*campaigns.length)]
)

}

function addTTP(actor){

const ttps=[
"T1190 Exploit Public-Facing App",
"T1059 Command Execution",
"T1046 Network Discovery",
"T1021 Remote Services",
"T1566 Phishing"
]

actors[actor].ttps.push(
ttps[Math.floor(Math.random()*ttps.length)]
)

}

function addIncident(actor,title){

actors[actor].incidents.push(title)

actors[actor].lastSeen=timestamp()

}

function render(){

container.innerHTML=""

renderHeader()

Object.values(actors).forEach(a=>{

const card=document.createElement("div")

card.style.border="1px solid #1f2937"
card.style.borderRadius="6px"
card.style.padding="10px"
card.style.marginBottom="10px"
card.style.background="#020617"

const name=document.createElement("div")
name.innerText=a.name
name.style.color="#f87171"
name.style.fontWeight="bold"

const meta=document.createElement("div")
meta.style.fontSize="12px"
meta.style.color="#94a3b8"
meta.innerText="Risk: "+a.risk+" | Attribution Confidence: "+a.confidence

const lastSeen=document.createElement("div")
lastSeen.style.fontSize="11px"
lastSeen.style.color="#64748b"
lastSeen.innerText="Last Activity: "+a.lastSeen

const campaigns=document.createElement("div")
campaigns.style.fontSize="12px"
campaigns.style.marginTop="6px"
campaigns.innerText="Campaigns: "+a.campaigns.slice(-3).join(", ")

const ttps=document.createElement("div")
ttps.style.fontSize="12px"
ttps.innerText="TTPs: "+a.ttps.slice(-3).join(", ")

card.appendChild(name)
card.appendChild(meta)
card.appendChild(lastSeen)
card.appendChild(campaigns)
card.appendChild(ttps)

container.appendChild(card)

})

}

async function fetchAlerts(){

try{

const alerts=await fetch(API_BASE+"/api/alerts").then(r=>r.json())

alerts.slice(0,3).forEach(a=>{

const actor=randomActor()

createActor(actor)

addCampaign(actor)

addTTP(actor)

})

}catch(e){}

}

async function fetchIncidents(){

try{

const incidents=await fetch(API_BASE+"/api/incidents").then(r=>r.json())

incidents.slice(0,2).forEach(i=>{

const actor=randomActor()

createActor(actor)

addIncident(actor,i.title)

})

}catch(e){}

}

async function updateProfiles(){

await fetchAlerts()
await fetchIncidents()

render()

}

function start(){

if(running)return

running=true

setInterval(updateProfiles,5000)

}

return{
init:init,
start:start
}

})()

window.AIThreatActorProfiler=AIThreatActorProfiler