const AICampaignAnalyzer=(function(){

const API_BASE="http://localhost:8080"

let container
let campaigns={}
let running=false
let maxCampaigns=10

const campaignTypes=[
"Exploit Wave",
"Credential Harvesting",
"Malware Distribution",
"Phishing Campaign",
"Lateral Movement Cluster"
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
h.innerText="AI CAMPAIGN ANALYZER"
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

function createCampaign(name){

if(campaigns[name])return

campaigns[name]={
name:name,
type:campaignTypes[Math.floor(Math.random()*campaignTypes.length)],
regions:new Set(),
events:0,
risk:(Math.random()*0.4+0.5).toFixed(2),
startTime:timestamp(),
lastActivity:timestamp()
}

}

function updateCampaign(name){

const c=campaigns[name]

c.events++

c.regions.add(randomRegion())

c.lastActivity=timestamp()

}

function render(){

container.innerHTML=""

renderHeader()

Object.values(campaigns)
.slice(0,maxCampaigns)
.forEach(c=>{

const card=document.createElement("div")

card.style.border="1px solid #1f2937"
card.style.borderRadius="6px"
card.style.padding="10px"
card.style.marginBottom="10px"
card.style.background="#020617"

const title=document.createElement("div")
title.innerText=c.name
title.style.color="#fb923c"
title.style.fontWeight="bold"

const type=document.createElement("div")
type.style.fontSize="12px"
type.style.color="#94a3b8"
type.innerText="Type: "+c.type

const risk=document.createElement("div")
risk.style.fontSize="12px"
risk.style.color="#facc15"
risk.innerText="Campaign Risk Score: "+c.risk

const region=document.createElement("div")
region.style.fontSize="12px"
region.innerText="Regions: "+Array.from(c.regions).join(", ")

const events=document.createElement("div")
events.style.fontSize="12px"
events.innerText="Observed Events: "+c.events

const time=document.createElement("div")
time.style.fontSize="11px"
time.style.color="#64748b"
time.innerText="Start: "+c.startTime+" | Last Activity: "+c.lastActivity

card.appendChild(title)
card.appendChild(type)
card.appendChild(risk)
card.appendChild(region)
card.appendChild(events)
card.appendChild(time)

container.appendChild(card)

})

}

async function fetchAlerts(){

try{

const alerts=await fetch(API_BASE+"/api/alerts").then(r=>r.json())

alerts.slice(0,5).forEach((a,i)=>{

const name="Campaign-"+(i+1)

createCampaign(name)

updateCampaign(name)

})

}catch(e){}

}

async function fetchIncidents(){

try{

const incidents=await fetch(API_BASE+"/api/incidents").then(r=>r.json())

incidents.slice(0,3).forEach((i,index)=>{

const name="Campaign-"+(index+1)

createCampaign(name)

updateCampaign(name)

})

}catch(e){}

}

async function analyzeCampaigns(){

await fetchAlerts()
await fetchIncidents()

render()

}

function start(){

if(running)return

running=true

setInterval(analyzeCampaigns,5000)

}

return{
init:init,
start:start
}

})()

window.AICampaignAnalyzer=AICampaignAnalyzer