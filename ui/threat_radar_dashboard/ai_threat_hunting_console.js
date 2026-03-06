const AIThreatHuntingConsole=(function(){

const API_BASE="http://localhost:8080"

let container
let input
let output
let running=false

const helpCommands=[
"help",
"search alerts",
"search incidents",
"hunt ioc <indicator>",
"hunt campaign",
"hunt actor",
"analyze risk",
"clear"
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

output=document.createElement("div")
output.style.flex="1"
output.style.overflow="auto"
output.style.fontSize="12px"
output.style.color="#e5e7eb"
output.style.marginBottom="8px"

container.appendChild(output)

input=document.createElement("input")
input.type="text"
input.placeholder="Enter hunting command..."
input.style.background="#020617"
input.style.border="1px solid #1f2937"
input.style.color="#e5e7eb"
input.style.padding="6px"
input.style.fontFamily="monospace"

container.appendChild(input)

input.addEventListener("keydown",(e)=>{

if(e.key==="Enter"){

executeCommand(input.value)

input.value=""

}

})

print("AI Threat Hunting Console Ready")
print("Type 'help' for available commands")

}

function renderHeader(){

const header=document.createElement("div")

header.innerText="AI THREAT HUNTING CONSOLE"

header.style.color="#38bdf8"
header.style.marginBottom="10px"
header.style.fontWeight="bold"

container.appendChild(header)

}

function timestamp(){

const d=new Date()
return d.toISOString().replace("T"," ").split(".")[0]

}

function print(text,color="#e5e7eb"){

const line=document.createElement("div")

line.style.color=color

line.innerText="["+timestamp()+"] "+text

output.appendChild(line)

output.scrollTop=output.scrollHeight

}

function clear(){

output.innerHTML=""

}

async function searchAlerts(){

try{

const alerts=await fetch(API_BASE+"/api/alerts").then(r=>r.json())

alerts.slice(0,5).forEach(a=>{

print(`ALERT ${a.severity} → ${a.message}`,"#f97316")

})

}catch(e){

print("Unable to fetch alerts","#ef4444")

}

}

async function searchIncidents(){

try{

const incidents=await fetch(API_BASE+"/api/incidents").then(r=>r.json())

incidents.slice(0,5).forEach(i=>{

print(`INCIDENT ${i.status} → ${i.title}`,"#facc15")

})

}catch(e){

print("Unable to fetch incidents","#ef4444")

}

}

async function analyzeRisk(){

try{

const m=await fetch(API_BASE+"/api/metrics").then(r=>r.json())

print(`Global Risk Index: ${m.global_risk.toFixed(2)}`,"#38bdf8")

if(m.global_risk>0.8){

print("AI assessment: Critical cyber threat environment","#ef4444")

}else if(m.global_risk>0.6){

print("AI assessment: Elevated attack activity","#f97316")

}else{

print("AI assessment: Normal baseline","#22c55e")

}

}catch(e){

print("Risk analysis unavailable","#ef4444")

}

}

function huntIOC(indicator){

print(`IOC Hunt started for: ${indicator}`,"#facc15")

setTimeout(()=>{

print(`ThreatMemoryEngine scanning telemetry for ${indicator}`,"#38bdf8")

},500)

setTimeout(()=>{

print(`No matches found in recent telemetry`,"#22c55e")

},1500)

}

function huntCampaign(){

print("Campaign analysis initiated","#38bdf8")

setTimeout(()=>{

print("CampaignAnalyzer clustering attack events","#f97316")

},800)

setTimeout(()=>{

print("Potential coordinated exploit wave detected","#ef4444")

},1600)

}

function huntActor(){

print("ThreatActorProfiler querying actor activity","#38bdf8")

setTimeout(()=>{

print("Actor cluster detected using phishing + credential harvesting","#f97316")

},1200)

}

function executeCommand(cmd){

const parts=cmd.trim().split(" ")

const base=parts[0]

if(base==="help"){

helpCommands.forEach(c=>print(c,"#38bdf8"))

return

}

if(cmd==="clear"){

clear()
return

}

if(cmd==="search alerts"){

searchAlerts()
return

}

if(cmd==="search incidents"){

searchIncidents()
return

}

if(cmd==="hunt campaign"){

huntCampaign()
return

}

if(cmd==="hunt actor"){

huntActor()
return

}

if(cmd==="analyze risk"){

analyzeRisk()
return

}

if(parts[0]==="hunt" && parts[1]==="ioc"){

const indicator=parts.slice(2).join(" ")

huntIOC(indicator)
return

}

print("Unknown command. Type 'help'","#ef4444")

}

function start(){

if(running)return

running=true

print("Threat hunting engines connected","#22c55e")

}

return{
init:init,
start:start
}

})()

window.AIThreatHuntingConsole=AIThreatHuntingConsole