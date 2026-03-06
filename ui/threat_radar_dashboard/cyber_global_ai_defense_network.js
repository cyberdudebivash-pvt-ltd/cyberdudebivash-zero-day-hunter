const CyberGlobalAIDefenseNetwork=(function(){

let runtime
let running=false

const nodes=[]
const networkState={
nodeId:null,
connectedNodes:[],
sharedDefenses:[],
globalIncidents:[]
}

const networkConfig={
syncInterval:4000,
maxSharedStrategies:200
}

function init(runtimeInstance,nodeId){

runtime=runtimeInstance

networkState.nodeId=nodeId || generateNodeId()

registerRuntimeEvents()

log("Global AI Defense Network initialized")

}

function generateNodeId(){

return "NODE-"+Math.random().toString(36).substring(2,10)

}

function log(msg){

console.log("[AI-DEFENSE-NET]",msg)

}

function registerRuntimeEvents(){

runtime.subscribe("ai_incident_generated",shareIncident)

runtime.subscribe("defense_recommendation",shareDefenseStrategy)

runtime.subscribe("campaign_detected",shareCampaignSignal)

runtime.subscribe("risk_critical",shareRiskSignal)

}

function connectNode(peer){

nodes.push(peer)

networkState.connectedNodes.push(peer.id)

log("Connected node: "+peer.id)

}

function shareIncident(incident){

networkState.globalIncidents.push(incident)

broadcast("incident_shared",incident)

}

function shareDefenseStrategy(strategy){

if(networkState.sharedDefenses.length>networkConfig.maxSharedStrategies){

networkState.sharedDefenses.shift()

}

networkState.sharedDefenses.push(strategy)

broadcast("defense_strategy_shared",strategy)

}

function shareCampaignSignal(data){

broadcast("campaign_signal",data)

}

function shareRiskSignal(data){

broadcast("global_risk_signal",data)

}

function broadcast(event,data){

nodes.forEach(node=>{

try{

sendToNode(node,event,data)

}catch(e){

log("Node communication error")

}

})

}

function sendToNode(node,event,data){

log("Sending "+event+" to "+node.id)

if(node.onMessage){

node.onMessage({
event:event,
data:data
})

}

}

function receiveFromNode(message){

const {event,data}=message

log("Received "+event+" from network")

processNetworkEvent(event,data)

}

function processNetworkEvent(event,data){

switch(event){

case "incident_shared":

runtime.publish("global_incident",data)
break

case "defense_strategy_shared":

runtime.publish("global_defense_strategy",data)
break

case "campaign_signal":

runtime.publish("global_campaign_signal",data)
break

case "global_risk_signal":

runtime.publish("global_risk_signal",data)
break

}

}

function synchronizeNetwork(){

broadcast("network_sync",networkState)

}

function getNetworkState(){

return networkState

}

function start(){

if(running)return

running=true

log("Global AI Defense Network running")

setInterval(synchronizeNetwork,networkConfig.syncInterval)

}

function stop(){

running=false

log("Global AI Defense Network stopped")

}

return{

init:init,
start:start,
stop:stop,

connectNode:connectNode,
receiveFromNode:receiveFromNode,

getNetworkState:getNetworkState

}

})()

window.CyberGlobalAIDefenseNetwork=CyberGlobalAIDefenseNetwork