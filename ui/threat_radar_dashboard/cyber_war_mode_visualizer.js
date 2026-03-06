const CyberWarModeVisualizer=(function(){

const API_BASE="http://localhost:8080"

let container
let levelIndicator
let descriptionBox
let pulseRing

let currentLevel=5
let running=false

const levels={
1:{name:"GLOBAL CYBER WAR",color:"#ef4444"},
2:{name:"CRITICAL THREAT",color:"#f97316"},
3:{name:"HIGH THREAT",color:"#facc15"},
4:{name:"ELEVATED",color:"#38bdf8"},
5:{name:"NORMAL",color:"#22c55e"}
}

function init(containerId){

container=document.getElementById(containerId)

container.style.background="#05070c"
container.style.border="1px solid #1f2937"
container.style.borderRadius="10px"
container.style.padding="20px"
container.style.textAlign="center"
container.style.fontFamily="Orbitron, sans-serif"

const title=document.createElement("div")
title.innerText="CYBER WAR READINESS LEVEL"
title.style.color="#94a3b8"
title.style.marginBottom="10px"

container.appendChild(title)

levelIndicator=document.createElement("div")
levelIndicator.style.fontSize="32px"
levelIndicator.style.fontWeight="bold"
levelIndicator.style.margin="10px 0"

container.appendChild(levelIndicator)

pulseRing=document.createElement("div")
pulseRing.style.width="120px"
pulseRing.style.height="120px"
pulseRing.style.margin="20px auto"
pulseRing.style.borderRadius="50%"
pulseRing.style.border="4px solid #22c55e"
pulseRing.style.boxShadow="0 0 20px #22c55e"

container.appendChild(pulseRing)

descriptionBox=document.createElement("div")
descriptionBox.style.fontSize="12px"
descriptionBox.style.color="#94a3b8"

container.appendChild(descriptionBox)

updateUI()

}

function computeLevel(metrics,alerts,incidents){

let level=5

if(metrics.global_risk>0.8)level=2
if(metrics.global_risk>0.9)level=1

if(metrics.cyber_war_mode)level=1

const criticalAlerts=alerts.filter(a=>a.severity==="CRITICAL").length

if(criticalAlerts>3)level=Math.min(level,2)

if(incidents.length>5)level=Math.min(level,3)

return level

}

function updateUI(){

const l=levels[currentLevel]

levelIndicator.innerText="LEVEL "+currentLevel+" — "+l.name

levelIndicator.style.color=l.color

pulseRing.style.borderColor=l.color
pulseRing.style.boxShadow="0 0 30px "+l.color

descriptionBox.innerText=getDescription(currentLevel)

}

function getDescription(level){

if(level===1)
return "Global coordinated cyber attacks detected. Maximum defense posture activated."

if(level===2)
return "Critical cyber threat environment. Multiple active campaigns detected."

if(level===3)
return "High threat level. Elevated attack activity observed."

if(level===4)
return "Moderate threat environment. Monitoring suspicious activity."

return "Normal cyber activity baseline."

}

async function fetchMetrics(){

try{

const m=await fetch(API_BASE+"/api/metrics").then(r=>r.json())
const alerts=await fetch(API_BASE+"/api/alerts").then(r=>r.json())
const incidents=await fetch(API_BASE+"/api/incidents").then(r=>r.json())

const newLevel=computeLevel(m,alerts,incidents)

if(newLevel!==currentLevel){

currentLevel=newLevel
updateUI()

}

}catch(e){

}

}

function animatePulse(){

pulseRing.animate(
[
{transform:"scale(1)",opacity:1},
{transform:"scale(1.2)",opacity:0.6},
{transform:"scale(1)",opacity:1}
],
{
duration:2000,
iterations:Infinity
})

}

function start(){

if(running)return

running=true

animatePulse()

setInterval(fetchMetrics,4000)

}

return{
init:init,
start:start
}

})()

window.CyberWarModeVisualizer=CyberWarModeVisualizer