const CyberGlobalThreatExchange=(function(){

let runtime
let running=false

const peers=[]

const exchangeState={
sharedIndicators:[],
sharedCampaigns:[],
connectedPeers:[]
}

const exchangeConfig={
maxIndicators:500,
syncInterval:5000
}

function init(runtimeInstance){

runtime=runtimeInstance

registerRuntimeEvents()

log("Global Threat Exchange initialized")

}

function log(msg){

console.log("[THREAT-EXCHANGE]",msg)

}

function registerRuntimeEvents(){

runtime.subscribe("ioc_detected",shareIndicator)

runtime.subscribe("campaign_registered",shareCampaign)

runtime.subscribe("actor_detected",shareActor)

runtime.subscribe("simulation_started",shareSimulation)

}

function addPeer(peer){

peers.push(peer)

exchangeState.connectedPeers.push(peer.id)

log("Peer connected: "+peer.id)

}

function shareIndicator(ioc){

if(exchangeState.sharedIndicators.length>exchangeConfig.maxIndicators){

exchangeState.sharedIndicators.shift()

}

exchangeState.sharedIndicators.push(ioc)

broadcast("indicator_shared",ioc)

}

function shareCampaign(campaign){

exchangeState.sharedCampaigns.push(campaign)

broadcast("campaign_shared",campaign)

}

function shareActor(actor){

broadcast("actor_shared",actor)

}

function shareSimulation(sim){

broadcast("simulation_shared",sim)

}

function broadcast(event,data){

peers.forEach(p=>{

try{

sendToPeer(p,event,data)

}catch(e){

log("Peer communication error")

}

})

}

function sendToPeer(peer,event,data){

log("Sending "+event+" to peer "+peer.id)

if(peer.onMessage){

peer.onMessage({
event:event,
data:data
})

}

}

function receiveFromPeer(message){

const {event,data}=message

log("Received "+event+" from peer")

runtime.publish("global_"+event,data)

processIncoming(event,data)

}

function processIncoming(event,data){

switch(event){

case "indicator_shared":

runtime.publish("ioc_detected",data)
break

case "campaign_shared":

runtime.publish("campaign_registered",data)
break

case "actor_shared":

runtime.publish("actor_detected",data)
break

case "simulation_shared":

runtime.publish("simulation_started",data)
break

}

}

function syncState(){

broadcast("state_sync",exchangeState)

}

function getExchangeState(){

return exchangeState

}

function start(){

if(running)return

running=true

log("Global Threat Exchange running")

setInterval(syncState,exchangeConfig.syncInterval)

}

function stop(){

running=false

log("Threat Exchange stopped")

}

return{

init:init,
start:start,
stop:stop,

addPeer:addPeer,
receiveFromPeer:receiveFromPeer,

getExchangeState:getExchangeState

}

})()

window.CyberGlobalThreatExchange=CyberGlobalThreatExchange