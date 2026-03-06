const ThreatRadarMap = (function(){

const API_BASE="http://localhost:8080"

let scene,camera,renderer
let globe
let attackLines=[]
let points=[]

const RADIUS=200

const regions={
US_EAST:{lat:37.0902,lon:-95.7129},
US_WEST:{lat:34.0522,lon:-118.2437},
EU_WEST:{lat:48.8566,lon:2.3522},
EU_CENTRAL:{lat:52.5200,lon:13.4050},
APAC_SG:{lat:1.3521,lon:103.8198},
APAC_JP:{lat:35.6895,lon:139.6917},
LATAM:{lat:-23.5505,lon:-46.6333},
MEA:{lat:25.2048,lon:55.2708}
}

function latLonToVector3(lat,lon,r){

const phi=(90-lat)*(Math.PI/180)
const theta=(lon+180)*(Math.PI/180)

return new THREE.Vector3(
-(r*Math.sin(phi)*Math.cos(theta)),
r*Math.cos(phi),
r*Math.sin(phi)*Math.sin(theta)
)

}

function init(containerId){

const container=document.getElementById(containerId)

scene=new THREE.Scene()

camera=new THREE.PerspectiveCamera(
60,
container.clientWidth/container.clientHeight,
1,
2000
)

camera.position.z=500

renderer=new THREE.WebGLRenderer({antialias:true})
renderer.setSize(container.clientWidth,container.clientHeight)

container.appendChild(renderer.domElement)

const geometry=new THREE.SphereGeometry(RADIUS,64,64)

const material=new THREE.MeshBasicMaterial({
color:0x0f172a,
wireframe:true
})

globe=new THREE.Mesh(geometry,material)

scene.add(globe)

animate()

}

function animate(){

requestAnimationFrame(animate)

globe.rotation.y+=0.0015

attackLines.forEach(l=>{
l.material.opacity-=0.01
})

attackLines=attackLines.filter(l=>l.material.opacity>0)

renderer.render(scene,camera)

}

function createAttackLine(from,to){

const start=latLonToVector3(from.lat,from.lon,RADIUS)
const end=latLonToVector3(to.lat,to.lon,RADIUS)

const geometry=new THREE.BufferGeometry().setFromPoints([start,end])

const material=new THREE.LineBasicMaterial({
color:0xff3b3b,
transparent:true,
opacity:1
})

const line=new THREE.Line(geometry,material)

scene.add(line)

attackLines.push(line)

}

function randomAttack(){

const keys=Object.keys(regions)

const src=regions[keys[Math.floor(Math.random()*keys.length)]]
const dst=regions[keys[Math.floor(Math.random()*keys.length)]]

createAttackLine(src,dst)

}

async function loadThreatRadar(){

try{

const res=await fetch(API_BASE+"/api/alerts")
const alerts=await res.json()

alerts.forEach(()=>randomAttack())

}catch(e){

for(let i=0;i<3;i++)randomAttack()

}

}

function startRadar(){

setInterval(loadThreatRadar,2000)

}

return{
init:init,
start:startRadar
}

})()

window.ThreatRadarMap=ThreatRadarMap