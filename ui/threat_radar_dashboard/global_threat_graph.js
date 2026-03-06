const GlobalThreatGraph=(function(){

const API_BASE="http://localhost:8080"

let container
let nodes=[]
let links=[]
let simulation
let svg

let width=900
let height=420

let running=false

function init(containerId){

container=document.getElementById(containerId)

width=container.clientWidth
height=container.clientHeight

svg=d3.select(container)
.append("svg")
.attr("width",width)
.attr("height",height)
.style("background","#05070c")

simulation=d3.forceSimulation(nodes)
.force("link",d3.forceLink(links).distance(120))
.force("charge",d3.forceManyBody().strength(-250))
.force("center",d3.forceCenter(width/2,height/2))

render()

}

function nodeColor(type){

if(type==="actor")return "#f87171"
if(type==="campaign")return "#fb923c"
if(type==="technique")return "#60a5fa"
if(type==="incident")return "#facc15"
if(type==="defense")return "#34d399"

return "#94a3b8"

}

function addNode(id,type,label){

if(nodes.find(n=>n.id===id))return

nodes.push({
id:id,
type:type,
label:label
})

}

function addLink(src,dst){

links.push({
source:src,
target:dst
})

}

function render(){

svg.selectAll("*").remove()

const link=svg.append("g")
.selectAll("line")
.data(links)
.enter()
.append("line")
.attr("stroke","#334155")
.attr("stroke-width",1.5)

const node=svg.append("g")
.selectAll("circle")
.data(nodes)
.enter()
.append("circle")
.attr("r",8)
.attr("fill",d=>nodeColor(d.type))
.call(d3.drag()
.on("start",dragstarted)
.on("drag",dragged)
.on("end",dragended))

const label=svg.append("g")
.selectAll("text")
.data(nodes)
.enter()
.append("text")
.text(d=>d.label)
.attr("font-size","10px")
.attr("fill","#cbd5f5")

simulation
.nodes(nodes)
.on("tick",()=>{

link
.attr("x1",d=>d.source.x)
.attr("y1",d=>d.source.y)
.attr("x2",d=>d.target.x)
.attr("y2",d=>d.target.y)

node
.attr("cx",d=>d.x)
.attr("cy",d=>d.y)

label
.attr("x",d=>d.x+10)
.attr("y",d=>d.y+4)

})

simulation.force("link")
.links(links)

}

function dragstarted(event,d){

if(!event.active)simulation.alphaTarget(0.3).restart()

d.fx=d.x
d.fy=d.y

}

function dragged(event,d){

d.fx=event.x
d.fy=event.y

}

function dragended(event,d){

if(!event.active)simulation.alphaTarget(0)

d.fx=null
d.fy=null

}

async function loadAlerts(){

try{

const res=await fetch(API_BASE+"/api/alerts")
const alerts=await res.json()

alerts.slice(0,5).forEach((a,i)=>{

const actor="actor_"+i
const campaign="campaign_"+i
const technique="ttp_"+i

addNode(actor,"actor","Actor-"+i)
addNode(campaign,"campaign","Campaign-"+i)
addNode(technique,"technique","TTP-"+i)

addLink(actor,campaign)
addLink(campaign,technique)

})

}catch(e){}

}

async function loadIncidents(){

try{

const res=await fetch(API_BASE+"/api/incidents")
const incidents=await res.json()

incidents.slice(0,3).forEach((i,index)=>{

const inc="incident_"+index
const defense="defense_"+index

addNode(inc,"incident",i.title)
addNode(defense,"defense","Defense Action")

addLink(inc,defense)

})

}catch(e){}

}

async function buildGraph(){

await loadAlerts()
await loadIncidents()

render()

}

function start(){

if(running)return

running=true

setInterval(buildGraph,5000)

}

return{
init:init,
start:start
}

})()

window.GlobalThreatGraph=GlobalThreatGraph