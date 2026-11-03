// Adds <meta name="robots" content="noindex, nofollow"> to every HTML page under the given dirs. Idempotent.
// Usage: node scripts/add-noindex.js [--write] dir [dir...]
const fs=require('fs'),path=require('path');
const write=process.argv.includes('--write');
const dirs=process.argv.slice(2).filter(a=>!a.startsWith('--'));
let n=0,had=0,nohead=[];
function w(d){for(const e of fs.readdirSync(d,{withFileTypes:true})){const p=path.join(d,e.name);
 if(e.isDirectory())w(p);else if(e.name.endsWith('.html')){
  let h=fs.readFileSync(p,'utf8');
  if(/name=["']robots["']/i.test(h)){had++;continue;}
  if(!/<head[^>]*>/i.test(h)){nohead.push(p);continue;}
  n++; if(write)fs.writeFileSync(p,h.replace(/<head[^>]*>/i,m=>m+'\n  <meta name="robots" content="noindex, nofollow" />'));
 }}}
dirs.forEach(w);
console.log(write?'WROTE':'DRY RUN','added:',n,'already had robots meta:',had,'no <head>:',nohead.length);nohead.forEach(x=>console.log(x));
