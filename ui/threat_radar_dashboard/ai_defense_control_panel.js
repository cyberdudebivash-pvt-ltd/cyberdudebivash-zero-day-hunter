const AIDefenseControlPanel=(function(){

const API_BASE="http://localhost:8080"

let container
let logArea

const actions=[
{
name:"BLOCK IP CLUSTER",
endpoint:"/api/defense/block-ip",
desc:"Block malicious IP clusters detected by threat correlation engine"
},
{
name:"ENABLE WAF PROTECTION",
endpoint:"/api/defense/waf-enable",
desc:"Deploy web application firewall mitigation rules"
},
{
name:"ISOLATE COMPROMISED HOST",
endpoint:"/api/defense/isolate-host",
desc:"Trigger network containment for compromised systems"
},
{
name:"DEPLOY HONEYPOT SENSOR",
endpoint:"/api/defense/deploy-honeypot",
desc:"Deploy deception infrastructure for attacker monitoring"
},
{
name:"ESCALATE CYBER WAR MODE",
endpoint:"/api/defense/escalate-war-mode",
desc:"Trigger maximum defense posture across defense engines"
}
]

function init(containerId){

container=document.getElementById(containerId)

container.style.background="#05070c"
container.style.border="1px solid #1f2937"
container.style.borderRadius="10px"
container.style.padding="20px"
container.style.fontFamily="Orbitron, sans-serif"

const title=document.createElement("div")
title.innerText="AI DEFENSE CONTROL PANEL"
title.style.color="#38bdf8"
title.style.marginBottom="10px"

container.appendChild(title)

const grid=document.createElement("div")
grid.style.display="grid"
grid.style.gridTemplateColumns="1fr"
grid.style.rowGap="10px"

container.appendChild(grid)

actions.forEach(a=>{

const card=document.createElement("div")

card.style.border="1px solid #1f2937"
card.style.borderRadius="6px"
card.style.padding="10px"
card.style.background="#020617"

const name=document.createElement("div")
name.innerText=a.name
name.style.color="#e5e7eb"
name.style.fontWeight="bold"

const desc=document.createElement("div")
desc.innerText=a.desc
desc.style.fontSize="12px"
desc.style.color="#94a3b8"

const btn=document.createElement("button")
btn.innerText="EXECUTE"
btn.style.marginTop="6px"
btn.style.background="#0ea5e9"
btn.style.color="white"
btn.style.border="none"
btn.style.padding="6px 10px"
btn.style.cursor="pointer"

btn.onclick=()=>executeAction(a)

card.appendChild(name)
card.appendChild(desc)
card.appendChild(btn)

grid.appendChild(card)

})

logArea=document.createElement("div")

logArea.style.marginTop="15px"
logArea.style.height="120px"
logArea.style.overflow="auto"
logArea.style.background="#020617"
logArea.style.border="1px solid #1f2937"
logArea.style.fontFamily="monospace"
logArea.style.fontSize="12px"
logArea.style.padding="8px"

container.appendChild(logArea)

log("Defense control panel initialized")

}

function timestamp(){

const d=new Date()
return d.toISOString().replace("T"," ").split(".")[0]

}

function log(msg){

const line=document.createElement("div")

line.style.color="#34d399"
line.innerText="["+timestamp()+"] "+msg

logArea.appendChild(line)

logArea.scrollTop=logArea.scrollHeight

}

async function executeAction(action){

log("Executing: "+action.name)

try{

const res=await fetch(API_BASE+action.endpoint,{
method:"POST"
})

if(res.ok){

log("SUCCESS: "+action.name+" executed")

}else{

log("WARNING: defense engine returned non-success response")

}

}catch(e){

log("ERROR: API request failed — simulation mode triggered")

simulateDefense(action)

}

}

function simulateDefense(action){

setTimeout(()=>{

log("Simulated defense action completed: "+action.name)

},1000)

}

return{
init:init
}

})()

window.AIDefenseControlPanel=AIDefenseControlPanel