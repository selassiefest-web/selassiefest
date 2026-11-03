// Adds missing <meta name="description"> and <link rel="canonical"> to public pages. Idempotent.
// Usage: node scripts/add-seo-meta.js [--write]   (dry run by default)
const fs=require('fs'),path=require('path');
const write=process.argv.includes('--write');
const SECTIONS=['about','contact','careers','custom','invest','lessons','media','festival','healing-grove','heritage-village','higher-learning-roots','ital-marketplace','main-stage','marketplace','reasoning-circle','schedule','sound-system-yard','sponsors','tickets','vendors','empress-empowerment-village'];
const esc=s=>s.replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/</g,'&lt;');
const txt=s=>s.replace(/<[^>]+>/g,' ').replace(/&amp;/g,'&').replace(/&nbsp;/g,' ').replace(/&#?\w+;/g,' ').replace(/\s+/g,' ').trim();
const files=[];
(function w(d){for(const e of fs.readdirSync(d,{withFileTypes:true})){const p=path.join(d,e.name);
 if(e.isDirectory())w(p);else if(e.name.endsWith('.html'))files.push(p);}})('.') ;
let nd=0,nc=0,skipped=[];
for(const f of files){
 const rel=f.split(path.sep).join('/').replace(/^\.\//,'');
 const parts=rel.split('/'); const isRoot=parts.length===1;
 if(!(isRoot&&['index.html'].includes(rel)===false&&false) && !SECTIONS.includes(parts[0])) continue;
 let h=fs.readFileSync(f,'utf8');
 if(/name=["']robots["'][^>]*noindex|http-equiv=["']refresh/i.test(h)||!/<\/title>/i.test(h))continue;
 let add='';
 if(!/name=["']description["']/i.test(h)){
  const body=h.replace(/<(script|style|nav|header|footer)[\s\S]*?<\/\1>/gi,'');
  let d='';
  for(const m of body.matchAll(/<p[^>]*>([\s\S]*?)<\/p>/gi)){const t=txt(m[1]);if(t.length>=60){d=t;break;}}
  if(!d){skipped.push(rel);} else {
   if(d.length>155){d=d.slice(0,155);d=d.slice(0,d.lastIndexOf(' '))+'…';}
   add+='\n  <meta name="description" content="'+esc(d)+'" />';nd++;}
 }
 if(!/rel=["']canonical["']/i.test(h)){
  const url='https://selassiefest.com/'+rel.replace(/index\.html$/,'');
  add+='\n  <link rel="canonical" href="'+url+'" />';nc++;}
 if(add&&write){h=h.replace(/<\/title>/i,m=>m+add);fs.writeFileSync(f,h);}
}
console.log((write?'WROTE':'DRY RUN'),'descriptions:',nd,'canonicals:',nc,'\nno usable paragraph (description skipped):',skipped.length);
console.log(skipped.join('\n'));
