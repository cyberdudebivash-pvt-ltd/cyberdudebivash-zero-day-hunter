const CyberAICoPilot=(function(){

const API_BASE="http://localhost:8080"

let container
let chatArea
let input
let running=false

const suggestions=[
"Explain current threat situation",
"Summarize active incidents",
"Recommend defense actions",
"Analyze attack campaign",
"Explain global risk"
]

function init(containerId){

container=document.getElementById(containerId)

container.style.background="#020617"
container.style.border="1px solid #1f2937"
container.style.borderRadius="10px"
container.style.padding="15px"
container.style.fontFamily="monospace"
container.style.display="flex"
container.style.flexDirection="column"
container.style.height="420px"

renderHeader()

chatArea=document.createElement("div")
chatArea.style.flex="1"
chatArea.style.overflow="auto"
chatArea.style.fontSize="12px"
chatArea.style.marginBottom="8px"

container.appendChild(chatArea)

renderSuggestions()

input=document.createElement("input")
input.type="text"
input.placeholder="Ask Cyber AI Co-Pilot..."
input.style.background="#020617"
input.style.border="1px solid #1f2937"
input.style.color="#e5e7eb"
input.style.padding="6px"

container.appendChild(input)

input.addEventListener("keydown",(e)=>{

if(e.key==="Enter"){

handleUserQuery(input.value)

input.value=""

}

})

print("Cyber AI Co-Pilot initialized","#22c55e")

}

function renderHeader(){

const header=document.createElement("div")

header.innerText="CYBER AI CO-PILOT"

header.style.color="#38bdf8"
header.style.fontWeight="bold"
header.style.marginBottom="10px"

container.appendChild(header)

}

function renderSuggestions(){

const box=document.createElement("div")

box.style.marginBottom="8px"

suggestions.forEach(s=>{

const btn=document.createElement("button")

btn.innerText=s
btn.style.marginRight="6px"
btn.style.marginBottom="4px"
btn.style.background="#020617"
btn.style.border="1px solid #1f2937"
btn.style.color="#e5e7eb"
btn.style.fontSize="11px"
btn.style.cursor="pointer"

btn.onclick=()=>handleUserQuery(s)

box.appendChild(btn)

})

container.appendChild(box)

}

function timestamp(){

const d=new Date()
return d.toISOString().replace("T"," ").split(".")[0]

}

function print(text,color="#e5e7eb"){

const line=document.createElement("div")

line.style.color=color
line.innerText="["+timestamp()+"] "+text

chatArea.appendChild(line)

chatArea.scrollTop=chatArea.scrollHeight

}

async function fetchMetrics(){

try{

return await fetch(API_BASE+"/api/metrics").then(r=>r.json())

}catch(e){

return null

}

}

async function fetchAlerts(){

try{

return await fetch(API_BASE+"/api/alerts").then(r=>r.json())

}catch(e){

return []

}

}

async function fetchIncidents(){

try{

return await fetch(API_BASE+"/api/incidents").then(r=>r.json())

}catch(e){

return []

}

}

async function explainThreat(){

const metrics=await fetchMetrics()

if(!metrics){

print("Unable to access intelligence feeds","#ef4444")
return

}

print(`Global Risk Index: ${metrics.global_risk.toFixed(2)}`,"#38bdf8")

if(metrics.global_risk>0.8){

print("AI assessment: critical cyber threat environment","#ef4444")

}else if(metrics.global_risk>0.6){

print("AI assessment: elevated threat activity","#f97316")

}else{

print("AI assessment: baseline activity","#22c55e")

}

}

async function summarizeIncidents(){

const incidents=await fetchIncidents()

if(incidents.length===0){

print("No active incidents detected","#22c55e")
return

}

incidents.slice(0,5).forEach(i=>{

print(`Incident: ${i.title} | Status: ${i.status}`,"#facc15")

})

}

async function recommendDefense(){

const alerts=await fetchAlerts()

if(alerts.length===0){

print("No immediate defensive actions recommended","#22c55e")
return

}

print("Recommended actions:","#38bdf8")

print("Deploy WAF rules","#f97316")
print("Increase monitoring for credential attacks","#f97316")
print("Activate anomaly detection sensors","#f97316")

}

async function analyzeCampaign(){

const alerts=await fetchAlerts()

if(alerts.length>3){

print("Potential coordinated campaign detected","#ef4444")

}else{

print("No coordinated campaign patterns detected","#22c55e")

}

}

async function explainRisk(){

const metrics=await fetchMetrics()

if(metrics){

print(`Current Global Risk: ${metrics.global_risk.toFixed(2)}`,"#38bdf8")

}

}

async function handleUserQuery(query){

const q=query.toLowerCase()

print("> "+query,"#38bdf8")

if(q.includes("threat") || q.includes("situation")){

explainThreat()
return

}

if(q.includes("incident")){

summarizeIncidents()
return

}

if(q.includes("defense")){

recommendDefense()
return

}

if(q.includes("campaign")){

analyzeCampaign()
return

}

if(q.includes("risk")){

explainRisk()
return

}

print("AI Co-Pilot: Unable to interpret request","#ef4444")

}

function start(){

if(running)return

running=true

print("AI Co-Pilot connected to SOC intelligence engines","#22c55e")

}

return{
init:init,
start:start
}

})()

window.CyberAICoPilot=CyberAICoPilot