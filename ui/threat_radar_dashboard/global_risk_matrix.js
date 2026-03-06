const GlobalRiskMatrix=(function(){

const API_BASE="http://localhost:8080"

let container
let matrix={}
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

const services=[
"Web Infrastructure",
"Cloud Services",
"Identity Systems",
"Endpoint Fleet",
"Network Edge"
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

initializeMatrix()

render()

}

function initializeMatrix(){

regions.forEach(r=>{
matrix[r]={}

services.forEach(s=>{
matrix[r][s]=Math.random()*0.5
})

})

}

function riskColor(v){

if(v>0.85)return "#ef4444"
if(v>0.7)return "#f97316"
if(v>0.55)return "#facc15"
if(v>0.4)return "#38bdf8"

return "#22c55e"

}

function render(){

container.innerHTML=""

const title=document.createElement("div")
title.innerText="GLOBAL CYBER RISK MATRIX"
title.style.color="#38bdf8"
title.style.marginBottom="10px"

container.appendChild(title)

const table=document.createElement("table")
table.style.width="100%"
table.style.borderCollapse="collapse"
table.style.fontSize="12px"

const header=document.createElement("tr")

const empty=document.createElement("th")
empty.innerText="Region / Surface"
empty.style.color="#94a3b8"
header.appendChild(empty)

services.forEach(s=>{
const th=document.createElement("th")
th.innerText=s
th.style.color="#94a3b8"
th.style.padding="6px"
header.appendChild(th)
})

table.appendChild(header)

regions.forEach(r=>{

const row=document.createElement("tr")

const regionCell=document.createElement("td")
regionCell.innerText=r
regionCell.style.color="#e5e7eb"
regionCell.style.padding="6px"

row.appendChild(regionCell)

services.forEach(s=>{

const risk=matrix[r][s]

const cell=document.createElement("td")
cell.style.padding="6px"
cell.style.textAlign="center"

const box=document.createElement("div")
box.style.background=riskColor(risk)
box.style.borderRadius="4px"
box.style.height="20px"
box.style.color="black"
box.style.fontSize="10px"
box.innerText=risk.toFixed(2)

cell.appendChild(box)

row.appendChild(cell)

})

table.appendChild(row)

})

container.appendChild(table)

}

async function fetchAlerts(){

try{

const alerts=await fetch(API_BASE+"/api/alerts").then(r=>r.json())

alerts.forEach(a=>{

const r=regions[Math.floor(Math.random()*regions.length)]
const s=services[Math.floor(Math.random()*services.length)]

matrix[r][s]=Math.min(1,matrix[r][s]+0.05)

})

}catch(e){}

}

async function fetchIncidents(){

try{

const incidents=await fetch(API_BASE+"/api/incidents").then(r=>r.json())

incidents.forEach(i=>{

const r=regions[Math.floor(Math.random()*regions.length)]
const s=services[Math.floor(Math.random()*services.length)]

matrix[r][s]=Math.min(1,matrix[r][s]+0.08)

})

}catch(e){}

}

async function fetchMetrics(){

try{

const m=await fetch(API_BASE+"/api/metrics").then(r=>r.json())

if(m.global_risk>0.7){

regions.forEach(r=>{
services.forEach(s=>{
matrix[r][s]+=0.02
})
})

}

}catch(e){}

}

function normalize(){

regions.forEach(r=>{
services.forEach(s=>{
matrix[r][s]=Math.max(0,Math.min(1,matrix[r][s]))
})
})

}

async function updateMatrix(){

await fetchAlerts()
await fetchIncidents()
await fetchMetrics()

normalize()

render()

}

function start(){

if(running)return

running=true

setInterval(updateMatrix,5000)

}

return{
init:init,
start:start
}

})()

window.GlobalRiskMatrix=GlobalRiskMatrix