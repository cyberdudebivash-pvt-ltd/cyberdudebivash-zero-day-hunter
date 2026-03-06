const CyberPlatformShell=(function(){

let container
let workspace
let sidebar
let header

const modules={
command_center:{
name:"Command Center",
loader:()=>loadModule("CyberCommandCenter")
},

attack_stream:{
name:"Realtime Attack Stream",
loader:()=>loadModule("RealtimeAttackStream")
},

threat_hunting:{
name:"Threat Hunting Console",
loader:()=>loadModule("AIThreatHuntingConsole")
},

ai_copilot:{
name:"AI Co-Pilot",
loader:()=>loadModule("CyberAICoPilot")
},

campaign_analyzer:{
name:"Campaign Analyzer",
loader:()=>loadModule("AICampaignAnalyzer")
},

risk_matrix:{
name:"Global Risk Matrix",
loader:()=>loadModule("GlobalRiskMatrix")
}

}

function init(containerId){

container=document.getElementById(containerId)

container.style.display="flex"
container.style.height="100vh"
container.style.background="#020617"
container.style.color="#e5e7eb"
container.style.fontFamily="Orbitron, sans-serif"

renderSidebar()
renderWorkspace()
renderHeader()

loadDefaultModule()

}

function renderHeader(){

header=document.createElement("div")

header.style.position="fixed"
header.style.top="0"
header.style.left="200px"
header.style.right="0"
header.style.height="40px"
header.style.background="#05070c"
header.style.borderBottom="1px solid #1f2937"
header.style.display="flex"
header.style.alignItems="center"
header.style.paddingLeft="10px"

header.innerHTML="CYBERDUDEBIVASH ZERO-DAY HUNTER™ PLATFORM"

container.appendChild(header)

}

function renderSidebar(){

sidebar=document.createElement("div")

sidebar.style.width="200px"
sidebar.style.background="#05070c"
sidebar.style.borderRight="1px solid #1f2937"
sidebar.style.paddingTop="10px"

Object.keys(modules).forEach(key=>{

const m=modules[key]

const btn=document.createElement("div")

btn.innerText=m.name
btn.style.padding="10px"
btn.style.cursor="pointer"
btn.style.borderBottom="1px solid #1f2937"

btn.onclick=()=>m.loader()

sidebar.appendChild(btn)

})

container.appendChild(sidebar)

}

function renderWorkspace(){

workspace=document.createElement("div")

workspace.style.flex="1"
workspace.style.marginLeft="200px"
workspace.style.marginTop="40px"
workspace.style.padding="10px"

container.appendChild(workspace)

}

function clearWorkspace(){

workspace.innerHTML=""

}

function loadModule(moduleName){

clearWorkspace()

const moduleContainer=document.createElement("div")

moduleContainer.id="platform_module"

workspace.appendChild(moduleContainer)

if(window[moduleName]){

window[moduleName].init("platform_module")

if(window[moduleName].start){

window[moduleName].start()

}

}else{

moduleContainer.innerHTML="Module not loaded"

}

}

function loadDefaultModule(){

loadModule("CyberCommandCenter")

}

return{
init:init
}

})()

window.CyberPlatformShell=CyberPlatformShell