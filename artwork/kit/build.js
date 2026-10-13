const { chromium } = require('playwright');const fs=require('fs');
const css=fs.readFileSync('palettes.css','utf8'), scene=fs.readFileSync('lareon-scene.js','utf8');
(async()=>{const b=await chromium.launch();
for(const p of ['night','dawn','day','dusk']){
 const pg=await b.newPage({viewport:{width:1920,height:1080},deviceScaleFactor:2});
 await pg.setContent('<!doctype html><html><head><style>'+css+'html,body{margin:0;height:100%}body{background:var(--bg)}</style></head><body class="p-'+p+'"></body></html>');
 await pg.addScriptTag({content:scene});
 await pg.evaluate("window.mountScene();document.querySelectorAll('.sc-star,.d1,.d2,.d3').forEach(e=>e.style.animation='none');document.querySelectorAll('.sc-star').forEach(e=>e.style.opacity=e.getAttribute('opacity'))");
 await pg.waitForTimeout(400);await pg.screenshot({path:'lareon-wallpaper-'+p+'.png'});console.log(p);await pg.close();}
await b.close();})();
