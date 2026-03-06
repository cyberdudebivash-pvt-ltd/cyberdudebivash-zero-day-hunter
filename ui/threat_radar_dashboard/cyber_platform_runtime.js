const CyberPlatformRuntime=(function(){

const API_BASE="http://localhost:8080"

let running=false
let eventBus={}
let modules={}
let telemetryState={
metrics:null,
alerts:[],
incidents:[],
timestamp:null
}

let listeners={}

function registerModule(name,module){

modules[name]=module

}

function subscribe(event,handler){

if(!listeners[event]){
listeners[event]=[]
}

listeners[event].push(handler)

}

function publish(event,data){

if(!listeners[event])return

listeners[event].forEach(h=>{

try{
h(data)
}catch(e){
console.error("Runtime handler error",e)
}

})

}

async function fetchMetrics(){

try{

const res=await fetch(API_BASE+"/api/metrics")
const data=await res.json()

telemetryState.metrics=data

publish("metrics_update",data)

}catch(e){

}

}

async function fetchAlerts(){

try{

const res=await fetch(API_BASE+"/api/alerts")
const data=await res.json()

telemetryState.alerts=data

publish("alerts_update",data)

}catch(e){

}

}

async function fetchIncidents(){

try{

const res=await fetch(API_BASE+"/api/incidents")
const data=await res.json()

telemetryState.incidents=data

publish("incidents_update",data)

}catch(e){

}

}

function updateTimestamp(){

telemetryState.timestamp=new Date().toISOString()

publish("tick",telemetryState.timestamp)

}

async function telemetryCycle(){

await fetchMetrics()
await fetchAlerts()
await fetchIncidents()

updateTimestamp()

}

function getState(){

return telemetryState

}

function start(){

if(running)return

running=true

setInterval(telemetryCycle,3000)

}

function stop(){

running=false

}

function sendCommand(cmd,data){

publish("command",{cmd,data})

}

function registerDefaultEvents(){

subscribe("alerts_update",(alerts)=>{

if(alerts.length>5){

publish("campaign_detected",alerts)

}

})

subscribe("metrics_update",(metrics)=>{

if(metrics.global_risk>0.8){

publish("risk_critical",metrics)

}

})

}

function initialize(){

registerDefaultEvents()

}

return{

init:initialize,
start:start,
stop:stop,

registerModule:registerModule,

subscribe:subscribe,
publish:publish,

getState:getState,
sendCommand:sendCommand

}

})()

window.CyberPlatformRuntime=CyberPlatformRuntime