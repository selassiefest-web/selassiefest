// Adds a Print button to the breadcrumb bar of each BBPAC meeting page (hidden on paper). Idempotent.
const fs=require('fs'),path=require('path');
const css='  .print-btn{float:right; margin:-4px 0 -4px 12px; background:var(--navy); color:#fff; border:0; border-radius:4px; padding:5px 14px; font:inherit; font-weight:700; letter-spacing:0.06em; cursor:pointer;}\n  .print-btn:hover{background:var(--culture);}\n';
let n=0;
for(const d of fs.readdirSync('bbpac/meetings',{withFileTypes:true})){ if(!d.isDirectory())continue;
 const f=path.join('bbpac/meetings',d.name,'index.html'); if(!fs.existsSync(f))continue;
 let h=fs.readFileSync(f,'utf8'); if(h.includes('print-btn'))continue;
 h=h.replace('  .breadcrumb a{',css+'  .breadcrumb a{');
 h=h.replace(/(<div class="breadcrumb">)/,'$1<button type="button" class="print-btn" onclick="window.print()">Print agenda</button>');
 h=h.replace('.breadcrumb, footer{display:none;}','.breadcrumb, .print-btn, footer{display:none;}');
 fs.writeFileSync(f,h);n++;}
console.log('updated',n);
