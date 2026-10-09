// Rainbow DJ Lab live class app. See /dj-lab/live/README.md.
(function(){
"use strict";
var COLORS = {red:"--r1",orange:"--r2",yellow:"--r3",green:"--r4",blue:"--r5",indigo:"--r6",violet:"--r7"};
var ORDER = ["red","orange","yellow","green","blue","indigo","violet"];
var DARK_INK = {orange:1, yellow:1};
var ROLES = [
  {k:"DJ", short:"DJ", job:"Hands on the decks. You try the Mission.", c:"--r1"},
  {k:"Co-pilot", short:"CP", job:"Headphones on. Count the beat out loud. Ask the DJ: Did it work?", c:"--r5"},
  {k:"Hype", short:"HY", job:"Be the crowd. Practice one MC line on the beat.", c:"--r2"},
  {k:"Logger", short:"LG", job:"Write in the Mix Log: song pair, what happened, what to change.", c:"--r7"}
];
var ROT_SECS = 225; // 15-minute deck time / 4 kids = 3:45 each
var LISTEN_BACK = {s6:1, s10:1, s13:1, w6:1};

// ---- block definitions (what a block is) ----
var BD = {
  drop:{name:"Drop In", c:"--r1", think:"Get ready to focus",
    kid:function(s){return "Grab your Passport. Find the beat: clap on 1, stomp on 4.";},
    brain:"Where is the 1?",
    parent:"Kids arrive to music already playing and warm up their timing by clapping and stomping on the beat.",
    ride:"What was the first song you heard when you walked in?",
    coach:function(s){return {doo:"Play the "+s.color+" crate as kids arrive. Run the beat-count game. Hand out Passports and station cards. Don't preview today's skill yet.", say:"Find the 1! Clap it with me.", watch:"Anyone not clapping yet? Stand beside them and count together.", ask:"Where's the 1?"};}},
  mission:{name:"Mission Card", c:"--r2", think:"Predict",
    kid:function(s){return "Today's Mission: "+s.mission+" Will it be easy, medium or hard for you? Say why.";},
    brain:"What is my Mission?",
    parent:"Each kid hears today's one goal and predicts how hard it will be. Predicting first teaches kids to notice how they learn.",
    ride:"What was today's Mission, and did you guess the difficulty right?",
    coach:function(s){return {doo:"Read the Mission out loud: “"+s.mission+"” Kids tap easy, medium or hard on their screen and say why. One skill only.", say:"Predict first. There's no wrong answer.", watch:"Note who picks hard. Check on them first in Deck Time.", ask:"Why do you think it'll be that hard?"};}},
  watch:{name:"Watch Me Think", c:"--r3", think:"Model an expert brain",
    kid:function(s){return "Watch Coach. Listen to how they think out loud. Look for "+s.look;},
    brain:"What is Coach thinking right now?",
    parent:"The coach demonstrates while saying their thoughts out loud, so kids hear how an experienced DJ makes decisions.",
    ride:"What was the coach thinking about while they mixed?",
    coach:function(s){return {doo:s.demo, say:s.say, watch:"Narrate the decisions, not just the moves. Stop talking by the end of the block: hands on the gear next.", ask:"What did you notice me do when I got stuck?"};}},
  deck1:{name:"Deck Time 1", c:"--r4", think:"Try, then check", deck:true,
    kid:function(s){return "Mild level for everyone: "+s.mild;},
    brain:"Where am I in the song?",
    parent:"Hands-on time at the controllers in groups of four. Jobs rotate every 3 minutes 45 seconds, so nobody waits around.",
    ride:"What job were you on first: DJ, Co-pilot, Hype or Logger?",
    coach:function(s){return {doo:"Everyone starts at Mild: "+s.mild+" Jobs rotate on screen every 3:45.", say:"Predict, try, check. Co-pilots, ask: Did it?", watch:"When a mix crashes, the station shouts “Data!”, taps the Data button, and the DJ names one reason.", ask:"What's your next move?"};}},
  move:{name:"Move Break", c:"--r2", think:"Reset attention",
    kid:function(s){return s.move;},
    brain:"Can I feel the phrase change?",
    parent:"A movement break set to music. It's part of the lesson, not a reward: it resets attention for the next round.",
    ride:"What was the move break today? Show me.",
    coach:function(s){return {doo:s.move, say:"Bodies up! Count it with your feet.", watch:"Use the drop as the freeze cue. Back at stations when the block ends.", ask:"Who felt the change coming?"};}},
  deck2:{name:"Deck Time 2", c:"--r4", think:"Fix, then try again", deck:true, levels:true,
    kid:function(s){return "Pick your level. You can switch any time.";},
    brain:"What will I do if it goes wrong?",
    parent:"Another round. Kids choose their own challenge: mild, medium or spicy.",
    ride:"Did you go mild, medium or spicy? Why?",
    coach:function(s){return {doo:"Kids pick a level. Mild: "+s.mild+" Medium: "+s.medium+" Spicy: "+s.spicy, say:"Pick your level. Switching is allowed.", watch:"Ask before you touch. One brain-check question first.", ask:"What will you do if it goes wrong?"};}},
  word:{name:"Wordplay Lab", c:"--r6", think:"Plan creatively",
    kid:function(s){return s.lab+": "+s.labHow;},
    brain:"What do these songs say to each other?",
    parent:"The creative block: word games with song titles and themes, building toward the Theme Clash.",
    ride:"What was the best pun in the room today?",
    coach:function(s){return {doo:s.lab+". "+s.labHow, say:"Silly is good. Clean words only.", watch:"Every kid offers one idea. Loggers write; anyone can draw or say it instead.", ask:"What do these two songs say to each other?"};}},
  spot:{name:"Spotlight", c:"--r7", think:"Perform, get feedback",
    kid:function(s){return "Want 60 seconds on the big speaker? Raise your hand. Everyone else: give a glow and a grow.";},
    brain:"What's one glow I can give?",
    parent:"Volunteers play 60 seconds on the main speaker. Classmates give one glow (something that worked) and one grow (one idea).",
    ride:"Who played in the Spotlight? What glow did they get?",
    coach:function(s,uk){return {doo:(LISTEN_BACK[uk]?"Listen-back day: each kid records 2 minutes, then reviews it with a mentor (one glow, one grow, one goal). Then ":"")+"3 or 4 volunteers play 60 seconds each on the main speaker. Tap Spot on the board so their family sees it.", say:"Glow: one thing that worked. Grow: one idea.", watch:"Volunteers only. Never call on a kid who didn't sign up.", ask:"What made that moment work?"};}},
  out:{name:"Check Out", c:"--r5", think:"Reflect",
    kid:function(s){return "How did your Mission go? Tap a light. Then finish: Next time I'll…";},
    brain:"What will I do next time?",
    parent:"Kids rate their own progress, write what they'll try next time, and earn Passport stamps. Then gear goes away by station job.",
    ride:"What's your “Next time I'll…” sentence?",
    coach:function(s){return {doo:"Traffic-light self-rating, one “Next time I'll…” line, Passport stamps, gear away by job.", say:"Rate it honestly. Red is useful data.", watch:"Compare each kid's light with what you saw. If they differ, talk about it. That conversation is the lesson.", ask:"What will you try next time?"};}}
};
function mk(def,a,b,name,id){ var d=BD[def]; var o={}; for(var k in d) o[k]=d[k]; o.def=def; o.id=id||def; o.a=a; o.b=b; if(name) o.name=name; return o; }
var COURSE = [mk("drop",0,7), mk("mission",7,12), mk("watch",12,20), mk("deck1",20,35), mk("move",35,40), mk("deck2",40,55), mk("word",55,70), mk("spot",70,82), mk("out",82,90)];
var FAST = [mk("drop",0,7), mk("mission",7,12), mk("watch",12,20), mk("deck1",20,35), mk("move",35,40), mk("deck2",40,55), mk("word",55,70), mk("move",70,75,"Move Break 2","move2"), mk("deck2",75,90,"Deck Time 3","deck3"), mk("spot",90,110), mk("out",110,120)];

var S = window.DJLAB_SESSIONS.S;
var W = window.DJLAB_SESSIONS.W;

// ---------- state ----------
var live = {mode:"course", session:1, ws:1, running:false, base:0, markAt:0, msg:"", msgAt:0, feed:[], spot:null};
var roster = {kids:{}};
var checkins = {};
var canCoach = true, connected = false, kidCanWrite = true;
var view = "kid", previewT = null, overlayFor = null;
var CODE = null, COHORT = null, VERSION = 0, coachSess = null, coachClasses = [], regs = [], regsAt = 0, pollTimer = null;

function store(k,v){ try{ if(v===undefined) return localStorage.getItem(k); localStorage.setItem(k,v);}catch(e){ return null; } }
function esc(s){ return String(s==null?"":s).replace(/[&<>"']/g,function(c){return {"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"}[c];}); }
function cap(s){ s=String(s||""); return s.charAt(0).toUpperCase()+s.slice(1); }
function cssv(n){ return "var("+n+")"; }
function fmt(sec){ sec=Math.max(0,Math.round(sec)); return Math.floor(sec/60)+":"+String(sec%60).padStart(2,"0"); }
function fast(){ return live.mode==="fast"; }
function blocks(){ return fast() ? FAST : COURSE; }
function TOTAL(){ var b=blocks(); return b[b.length-1].b*60; }
function unit(){ return fast() ? (W[(live.ws||1)-1]||W[0]) : (S[(live.session||1)-1]||S[0]); }
function uk(){ return (fast()?"w":"s")+(fast()?live.ws:live.session); }
function unitLabel(){ return fast() ? "Workshop "+live.ws+" of 6" : "Session "+live.session+" of 14"; }
// Class time runs on the server's clock, not the device's: every poll
// returns the server time, and the round trip gives this device's offset
// (NTP-style; the fastest recent round trip wins, so one slow request
// can't skew it). Coaches stamp markAt in server time; every screen counts
// from the same instant regardless of how wrong its own clock is.
var CLOCK_OFFSET = 0, bestRtt = Infinity;
function sNow(){ return Date.now() + CLOCK_OFFSET; }
function syncClock(t0, t1, serverNow){
  if(!serverNow) return;
  var rtt = t1 - t0;
  bestRtt = Math.min(bestRtt * 1.02 + 1, Infinity);
  if(rtt <= bestRtt){ bestRtt = rtt; CLOCK_OFFSET = Number(serverNow) - (t0 + t1) / 2; }
}
function liveT(){ var t = live.base + (live.running ? (sNow()-live.markAt)/1000 : 0); return Math.min(TOTAL(), Math.max(0,t)); }
function shownT(){ return previewT!=null ? Math.min(previewT,TOTAL()) : liveT(); }
function blockAt(t){ var bs=blocks(), m=t/60; for(var i=0;i<bs.length;i++){ if(m < bs[i].b) return i; } return bs.length-1; }
function stateName(){ var t=liveT(); if(t>=TOTAL()) return "done"; if(live.running) return "live"; if(t>0) return "paused"; return "idle"; }
function wallAt(minute){
  var st=stateName(); if(st!=="live") return null;
  var d=new Date(sNow()-liveT()*1000+minute*60000);
  return d.toLocaleTimeString([], {hour:"numeric", minute:"2-digit"});
}
function roleFor(kid,t){
  var bs=blocks(), bi=blockAt(t), B=bs[bi];
  if(!B.deck) return null;
  var into=t-B.a*60, rot=Math.floor(into/ROT_SECS);
  return {role:ROLES[(Number(kid.seat||0)+rot)%4], rot:rot, nextIn:ROT_SECS-(into%ROT_SECS)};
}
function kidsSorted(){
  return Object.keys(roster.kids||{}).map(function(k){ var o=roster.kids[k]||{}; return {key:k,name:o.name,station:Number(o.station)||1,seat:Number(o.seat)||0,stamps:o.stamps||{},here:o.here||{},glow:o.glow||{}}; })
    .sort(function(a,b){ return (a.station-b.station)||(a.seat-b.seat)||String(a.name).localeCompare(b.name); });
}
function kidObj(k){ var o=roster.kids[k]; return o ? {key:k,name:o.name,station:Number(o.station)||1,seat:Number(o.seat)||0,stamps:o.stamps||{},here:o.here||{},glow:o.glow||{}} : null; }
function seatName(s){ return "ABCD"[Number(s)||0]; }
function ci(k){ return checkins[k+"_"+uk()]||{}; }
function toast(msg){ var t=document.getElementById("toast"); t.textContent=msg; t.classList.add("show"); clearTimeout(t._h); t._h=setTimeout(function(){ t.classList.remove("show"); },2600); }

// ---------- persistence ----------
function liveBody(){ return {mode:live.mode, session:live.session, ws:live.ws, running:live.running, base:live.base, markAt:live.markAt, msg:live.msg, msgAt:live.msgAt, feed:live.feed, spot:live.spot||null}; }
function rpc(name, args){
  return window.sfSupabaseReady.then(function(c){ return c.rpc(name, args); }).then(function(r){ if(r.error) throw r.error; return r.data; });
}
function coachArgs(extra){ var a={p_session:coachSess&&coachSess.token, p_cohort:COHORT&&COHORT.id}; for(var k in extra) a[k]=extra[k]; return a; }
function coachErr(e){
  var m=(e&&e.message)||"error";
  if(/session/i.test(m)){ setCoach(null); toast("Your coach sign-in ended. Sign in again."); }
  else note("Couldn't save: "+m);
}
function saveLive(patch){
  for(var k in patch) live[k]=patch[k];
  renderAll();
  if(connected && canCoach) rpc("djlab_coach_set_live", coachArgs({p_live:liveBody()})).then(function(v){ VERSION=Math.max(VERSION,Number(v)||0); }).catch(coachErr);
}
function patchKid(k, patch){
  var kid=roster.kids[k]; if(!kid) return;
  roster.kids=Object.assign({},roster.kids); roster.kids[k]=Object.assign({},kid,patch); renderData();
  if(connected && canCoach) rpc("djlab_coach_kid", coachArgs({p_kid:k, p:patch})).then(poll).catch(coachErr);
}
function addKid(name, station, seat, consent){
  if(connected){ return rpc("djlab_coach_kid", coachArgs({p_kid:null, p:Object.assign({name:name, station:station, seat:seat}, consent||{})})).then(function(){ poll(); loadSafety(true); }).catch(coachErr); }
  var key="k"+Date.now().toString(36)+Math.floor(Math.random()*1e4).toString(36);
  roster.kids=Object.assign({},roster.kids); roster.kids[key]={name:name, station:station, seat:seat, stamps:{}, here:{}, glow:{}}; renderData();
}
function delKid(key){
  roster.kids=Object.assign({},roster.kids); delete roster.kids[key]; if(live.spot===key) saveLive({spot:null}); renderData();
  if(connected && canCoach) rpc("djlab_coach_kid_delete", coachArgs({p_kid:key})).then(poll).catch(coachErr);
}
var writeQ = {};
// op: "merge" (predict/level/light/next), "inc_data", "append_mixlog"
function saveCheckin(kidKey, patchFn, op, payload){
  var id=kidKey+"_"+uk();
  var cur=Object.assign({kid:kidKey, unit:uk()}, checkins[id]||{});
  var next=Object.assign(cur, typeof patchFn==="function" ? patchFn(cur) : patchFn);
  if(connected && roster.kids[kidKey] && !roster.kids[kidKey].tracking){ toast("Your family hasn't turned on the class app for you yet. Tell Coach your answer!"); return Promise.resolve(false); }
  checkins[id]=next; renderData();
  if(!connected) return Promise.resolve(true);
  var args={p_code:CODE, p_kid:kidKey, p_unit:uk(), p_op:op||"merge", p:payload||(typeof patchFn==="function"?{}:patchFn)};
  var p=(writeQ[id]||Promise.resolve()).then(function(){ return rpc("djlab_checkin", args); })
    .then(function(){ poll(); return true; }, function(){ return false; });
  writeQ[id]=p; return p;
}
function note(msg){ document.getElementById("coachGate").textContent=msg; }

// ---------- coach actions ----------
function setT(t){ t=Math.max(0,Math.min(TOTAL(),t)); saveLive({base:t, markAt:sNow()}); }
function startPause(){
  var t=liveT(); if(t>=TOTAL()) return;
  saveLive({running:!live.running, base:t, markAt:sNow()});
}
function jumpBlock(dir){
  var bs=blocks(), t=liveT(), bi=blockAt(t), into=t-bs[bi].a*60, target;
  if(dir<0) target=(into>10||bi===0) ? bs[bi].a*60 : bs[bi-1].a*60;
  else target=bi<bs.length-1 ? bs[bi+1].a*60 : TOTAL();
  setT(target);
}

// ---------- header + wave ----------
var bars=[], waveFor="";
function buildWave(){
  var key=live.mode; if(key===waveFor) return; waveFor=key;
  var bs=blocks(), n=TOTAL()/60, w=document.getElementById("wave"), bl=document.getElementById("blocks");
  w.innerHTML=""; bars=[];
  for(var i=0;i<n;i++){
    var B=bs[blockAt(i*60+1)];
    var h=22+70*Math.abs(Math.sin(i*1.73)*Math.cos(i*0.41))+(B.deck?8:0);
    var b=document.createElement("button");
    b.className="bar"; b.style.setProperty("--c",cssv(B.c)); b.style.height=Math.min(100,h)+"%";
    b.setAttribute("aria-label","Minute "+i+": "+B.name);
    (function(min){ b.addEventListener("click",function(){ onBar(min); }); })(i);
    w.appendChild(b); bars.push(b);
  }
  var head=document.createElement("div"); head.className="head"; head.id="head"; w.appendChild(head);
  bl.innerHTML=bs.map(function(B,i){ return '<span id="bl'+i+'" style="--c:'+cssv(B.c)+';flex:'+(B.b-B.a)+'">'+esc(B.name)+'</span>'; }).join("");
  document.getElementById("waveLbl").innerHTML=(n)+"-minute "+(fast()?"workshop":"session")+" &middot; one bar per minute";
}
function onBar(min){
  if(view==="coach" && canCoach){ setT(min*60); return; }
  previewT=min*60; renderAll();
}
function renderHeader(){
  buildWave();
  var s=unit(), t=shownT(), st=stateName(), bs=blocks();
  var root=document.documentElement;
  root.style.setProperty("--sc",cssv(COLORS[s.color]));
  root.style.setProperty("--sc-ink",DARK_INK[s.color]?"#16182B":"#FFFFFF");
  document.getElementById("sessPill").innerHTML="<b>"+(fast()?"W":"")+s.n+"</b><span>"+esc(cap(s.color))+" &middot; "+esc(s.title)+"</span>";
  var labels={idle:"Not started",live:"Live",paused:"Paused",done:"Session over"};
  var stEl=document.getElementById("status"); stEl.className="status "+st;
  stEl.querySelector("span").textContent=(MODE==="demo"?"Demo · ":MODE?"":"Not joined · ")+labels[st];
  renderJoin();
  document.getElementById("clock").innerHTML=fmt(liveT())+" <small>/ "+fmt(TOTAL())+"</small>";
  var cur=Math.min(bars.length-1,Math.floor(t/60)), bi=blockAt(t);
  for(var i=0;i<bars.length;i++){ bars[i].classList.toggle("past",i<cur); bars[i].classList.toggle("cur",i===cur); }
  var head=document.getElementById("head"); if(head) head.style.left="calc("+(t/TOTAL()*100)+"% - 1px)";
  for(var j=0;j<bs.length;j++){ var e=document.getElementById("bl"+j); if(e) e.classList.toggle("cur",j===bi); }
  var pb=document.getElementById("previewBar"); pb.hidden=previewT==null;
  if(previewT!=null) document.getElementById("previewText").textContent="Previewing minute "+Math.floor(previewT/60)+": "+bs[bi].name+". Live is at "+fmt(liveT())+".";
  document.getElementById("waveHint").textContent=(view==="coach"&&canCoach)?"Tap any minute to move the live clock there":"Tap any minute to preview it";
  var c=document.getElementById("cast");
  if(live.msg){ c.hidden=false; document.getElementById("castText").textContent=live.msg; } else c.hidden=true;
  var sp=live.spot && roster.kids[live.spot] && bs[blockAt(liveT())].def==="spot" && st!=="idle";
  document.getElementById("spotBan").hidden=!sp;
  if(sp) document.getElementById("spotText").textContent=roster.kids[live.spot].name;
  document.getElementById("listenBan").hidden=!(LISTEN_BACK[uk()]);
  renderOverlay();
}
function renderOverlay(){
  var ov=document.getElementById("overlay"), bs=blocks(), t=liveT(), bi=blockAt(t), B=bs[bi];
  var key=uk()+"|"+B.id;
  var should = view==="kid" && previewT==null && live.running && B.def==="move";
  if(!should){ ov.hidden=true; if(B.def!=="move") overlayFor=null; return; }
  if(overlayFor===key+"|closed"){ ov.hidden=true; return; }
  overlayFor=key; ov.hidden=false;
  document.getElementById("ovText").textContent=unit().move;
  document.getElementById("ovTime").textContent=fmt(B.b*60-t)+" left";
}

// ---------- KID ----------
function screenSel(){ var v=document.getElementById("kidWho").value||""; if(v.indexOf("st:")===0) return {station:Number(v.slice(3))}; var k=kidObj(v); return k?{kid:k}:{}; }
function renderKid(){
  var s=unit(), t=shownT(), bs=blocks(), bi=blockAt(t), B=bs[bi], st=stateName();
  var left=B.b*60-t, len=(B.b-B.a)*60, frac=Math.max(0,Math.min(1,(t-B.a*60)/len));
  var R=88, C=2*Math.PI*R, waiting=previewT==null&&st==="idle", done=previewT==null&&st==="done";
  var el=document.getElementById("kidNow"); el.style.setProperty("--c",cssv(B.c));
  el.innerHTML=
    '<div class="ring" aria-hidden="true"><svg viewBox="0 0 200 200"><circle cx="100" cy="100" r="'+R+'" fill="none" stroke="var(--surface-2)" stroke-width="18"/>'+
    '<circle cx="100" cy="100" r="'+R+'" fill="none" stroke="'+cssv(B.c)+'" stroke-width="18" stroke-linecap="round" stroke-dasharray="'+C+'" stroke-dashoffset="'+(C*frac)+'"/></svg>'+
    '<div class="t"><div><b class="num">'+(done?"0:00":fmt(left))+'</b><span>'+(waiting?"starts soon":"left")+'</span></div></div></div>'+
    '<div><span class="lbl">'+(waiting?"Waiting for Coach to start":done?"Session over. Great work!":"Right now · block "+(bi+1)+" of "+bs.length)+'</span>'+
    '<h2>'+esc(B.name)+'</h2><p class="say">'+esc(B.kid(s))+'</p>'+
    '<div class="row"><span class="chip think" style="--c:'+cssv(B.c)+'">Thinking move: '+esc(B.think)+'</span></div></div>';
  var sel=screenSel(), jb=document.getElementById("kidJob");
  if(sel.station){
    var ks=kidsSorted().filter(function(k){ return k.station===sel.station; });
    document.getElementById("kidSpot").textContent="Shared station screen";
    var anyRole = ks.length ? roleFor(ks[0],t) : roleFor({seat:0},t);
    jb.innerHTML='<span class="lbl">Station '+sel.station+(anyRole?' &middot; jobs switch in <b class="num">'+fmt(anyRole.nextIn)+'</b>':' &middot; everyone together')+'</span>'+
      (ks.length?'<div class="board">'+ks.map(function(k){ var r=roleFor(k,t); var rc=r?r.role:null;
        return '<div><span class="badge" style="--c:'+cssv(rc?rc.c:"--line-strong")+'">'+(rc?rc.short:seatName(k.seat))+'</span><span><b>'+esc(k.name)+'</b><br><span class="faint">'+(rc?esc(rc.job):"Seat "+seatName(k.seat))+'</span></span><span class="faint">'+(ci(k.key).data?ci(k.key).data+" data":"")+'</span></div>'; }).join("")+'</div>'
        :'<p class="empty" style="margin:8px 0 0">No kids at this station yet. Coach adds them on the Coach tab.</p>')+
      (B.deck?'<button class="databtn" id="dataBtn">DATA! That crash taught us something</button><p class="faint" style="margin:6px 0 0">Counts for whoever is DJ right now.</p>':'');
  } else if(sel.kid){
    var me=sel.kid, r=roleFor(me,t), c=ci(me.key);
    document.getElementById("kidSpot").textContent="Station "+me.station+", Seat "+seatName(me.seat);
    if(r){
      jb.innerHTML='<span class="lbl">My job now &middot; Station '+me.station+'</span>'+
        '<div class="job" style="margin-top:8px"><div class="badge" style="--c:'+cssv(r.role.c)+'">'+r.role.short+'</div><div><h3>'+esc(r.role.k)+'</h3><div class="muted">'+esc(r.role.job)+'</div></div></div>'+
        '<div class="rot">'+ROLES.map(function(x){ return '<span class="'+(x===r.role?"on":"")+'">'+x.k+'</span>'; }).join("")+'</div>'+
        '<p class="faint" style="margin:8px 0 0">Jobs switch in <b class="num">'+fmt(r.nextIn)+'</b></p>'+
        (B.levels?'<div class="levels">'+[["mild","Mild","--r4",s.mild],["medium","Medium","--r3",s.medium],["spicy","Spicy","--r1",s.spicy]].map(function(L){
          return '<button class="lvl" data-level="'+L[0]+'" aria-pressed="'+(c.level===L[0])+'" style="--c:'+cssv(L[2])+'"><b><i></i>'+L[1]+'</b><span>'+esc(L[3])+'</span></button>'; }).join("")+'</div>':'')+
        '<button class="databtn" id="dataBtn">DATA! That crash taught me something</button>'+
        (c.data?'<p class="faint" style="margin:6px 0 0">You’ve turned <b>'+c.data+'</b> crash'+(c.data>1?"es":"")+' into data today.</p>':'');
    } else {
      jb.innerHTML='<span class="lbl">Station '+me.station+' &middot; Seat '+seatName(me.seat)+'</span><h3 style="font-size:1.3rem;margin-top:6px">Everyone together</h3><p class="muted" style="margin:4px 0 0">No station jobs in this block. Jobs start in Deck Time.</p>';
    }
  } else {
    document.getElementById("kidSpot").textContent="";
    jb.innerHTML='<span class="lbl">My job</span><p class="muted" style="margin:6px 0 0">Pick your name above, or pick a station for a shared station screen.</p>';
  }
  document.getElementById("kidBrain").innerHTML='<span class="lbl">Brain check</span><div class="brain" style="margin-top:8px"><span class="q">?</span><span>'+esc(B.brain)+'</span></div>'+
    '<p class="faint" style="margin:10px 0 0">Today’s Mission: '+esc(s.mission)+'</p>'+
    '<p class="faint" style="margin:6px 0 0">Stuck? Ask your Co-pilot one question before you ask Coach.</p>';
  var nb=bs[bi+1];
  document.getElementById("kidUp").innerHTML='<div class="row" style="justify-content:space-between; flex-wrap:nowrap"><div><span class="lbl">Up next</span><div style="font-weight:800;font-size:1.1rem">'+(nb?esc(nb.name):"Home time. See you next session!")+'</div></div>'+(nb?'<span class="dot" style="--c:'+cssv(nb.c)+';width:28px;height:28px"></span>':'')+'</div>';
  renderKidAct(); renderKidLog();
}
function renderKidAct(){
  var t=shownT(), B=blocks()[blockAt(t)], sel=screenSel(), card=document.getElementById("kidAct");
  var showPredict=B.def==="mission", showOut=B.def==="out";
  if(!(showPredict||showOut)){ card.hidden=true; return; }
  card.hidden=false;
  var inner=document.getElementById("kidActInner"), nw=document.getElementById("kidNextWrap");
  var P=[["easy","Easy","--r4"],["medium","Medium","--r3"],["hard","Hard","--r1"]], L=[["green","I got it","--r4"],["yellow","Getting there","--r3"],["red","Not yet","--r1"]];
  var opts=showPredict?P:L, field=showPredict?"predict":"light";
  var html;
  if(sel.station){
    var ks=kidsSorted().filter(function(k){ return k.station===sel.station; });
    html='<span class="lbl">'+(showPredict?"Predict: how hard will today’s Mission be?":"How did your Mission go?")+' Tap your row.</span>'+
      (ks.length?ks.map(function(k){ var c=ci(k.key); return '<div class="mini"><b>'+esc(k.name)+'</b><span class="opts">'+opts.map(function(o){ return '<button data-kid="'+esc(k.key)+'" data-f="'+field+'" data-v="'+o[0]+'" aria-pressed="'+(c[field]===o[0])+'" style="--c:'+cssv(o[2])+'"><i></i>'+o[1]+'</button>'; }).join("")+'</span></div>'; }).join("")
        :'<p class="empty">No kids at this station yet.</p>');
    nw.hidden=true;
  } else if(sel.kid){
    var c=ci(sel.kid.key);
    html='<span class="lbl">'+(showPredict?"Predict: how hard will today’s Mission be?":"How did your Mission go?")+'</span><div class="choices" style="margin-top:10px">'+
      opts.map(function(o){ return '<button class="choice" data-kid="'+esc(sel.kid.key)+'" data-f="'+field+'" data-v="'+o[0]+'" aria-pressed="'+(c[field]===o[0])+'"><span class="lt" style="--c:'+cssv(o[2])+'"></span>'+o[1]+'</button>'; }).join("")+'</div>'+
      (showOut&&c.predict?'<p class="faint" style="margin:10px 0 0">You predicted <b>'+esc(c.predict)+'</b>. Was that right?</p>':'');
    nw.hidden=!showOut;
    var inp=document.getElementById("kidNext");
    if(showOut && document.activeElement!==inp && c.next && !inp.value) inp.value=c.next;
  } else {
    html='<span class="lbl">'+(showPredict?"Predict":"Check out")+'</span><p class="muted" style="margin:6px 0 0">Pick your name or station above first.</p>'; nw.hidden=true;
  }
  if(!kidCanWrite || (connected && sel.kid && roster.kids[sel.kid.key] && !roster.kids[sel.kid.key].tracking)) html+='<p class="faint" style="margin:10px 0 0">This screen can’t save for you. Tell your coach your answer.</p>';
  if(inner._h!==html){ inner.innerHTML=html; inner._h=html; }
}
function logTarget(){
  var sel=screenSel(), t=shownT();
  if(sel.kid) return sel.kid;
  if(sel.station){ var ks=kidsSorted().filter(function(k){ return k.station===sel.station; }); for(var i=0;i<ks.length;i++){ var r=roleFor(ks[i],t); if(r&&r.role.k==="DJ") return ks[i]; } return ks[0]||null; }
  return null;
}
function renderKidLog(){
  var t=shownT(), B=blocks()[blockAt(t)], card=document.getElementById("kidLog");
  var show=(B.deck||B.def==="word") && (screenSel().kid||screenSel().station);
  card.hidden=!show; if(!show) return;
  var tgt=logTarget();
  document.getElementById("kidLogLbl").textContent=tgt ? "Mix Log · about "+tgt.name+"’s mix" : "Mix Log";
  var list=tgt?(ci(tgt.key).mixlog||[]):[];
  var html=list.slice(-3).reverse().map(function(m){ return '<li><b>'+esc(m.pair||"Mix")+'</b><br>'+esc(m.what||"")+(m.fix?'<br><span class="faint">Next: '+esc(m.fix)+'</span>':'')+'</li>'; }).join("");
  var ul=document.getElementById("logList"); if(ul._h!==html){ ul.innerHTML=html; ul._h=html; }
}

// ---------- COACH ----------
function renderCoach(){
  var s=unit(), t=shownT(), bs=blocks(), bi=blockAt(t), B=bs[bi], c=B.coach(s,uk()), left=B.b*60-t;
  var el=document.getElementById("coachNow"); el.style.setProperty("--c",cssv(B.c));
  el.innerHTML='<div class="coachhead"><div><span class="lbl">Block '+(bi+1)+' of '+bs.length+' &middot; '+B.a+':00–'+B.b+':00</span><h2 style="font-size:1.7rem;margin-top:4px">'+esc(B.name)+'</h2>'+
    '<div class="row" style="margin-top:6px"><span class="chip think" style="--c:'+cssv(B.c)+'">Thinking move: '+esc(B.think)+'</span></div></div>'+
    '<div style="text-align:right"><div class="bigtime">'+fmt(left)+'</div><span class="faint">left in block</span></div></div>'+
    '<dl><dt>Do</dt><dd>'+esc(c.doo)+'</dd><dt>Say</dt><dd class="say">'+esc(c.say)+'</dd><dt>Watch for</dt><dd>'+esc(c.watch)+'</dd><dt>Ask</dt><dd>'+esc(c.ask)+'</dd></dl>'+
    '<div class="rule"><span><b>Mentor rule</b>Ask, don’t fix. If a kid is stuck, ask one brain-check question before you touch the controller.</span></div>';
  var st=stateName(), btn=document.getElementById("cStart");
  btn.textContent=st==="live"?"Pause":st==="paused"?"Resume":st==="done"?"Done":"Start";
  btn.disabled=st==="done"||!canCoach;
  ["cBack","cNext","cAdd","cReset","cSession","cMode","castSend","castClear","castIn","rAdd","rName","rStation","rSeat","gKid","gText","gSave"].forEach(function(id){ document.getElementById(id).disabled=!canCoach; });
  document.getElementById("coachUp").innerHTML='<span class="lbl">Coming up</span>'+bs.slice(bi+1,bi+4).map(function(nb){
    var d=nb.coach(s,uk()).doo;
    return '<div style="display:grid;grid-template-columns:52px 12px minmax(0,1fr);gap:10px;align-items:center;padding:8px 0;border-bottom:1px solid var(--line)"><span class="faint num">'+nb.a+':00</span><span class="dot" style="--c:'+cssv(nb.c)+'"></span><span><b>'+esc(nb.name)+'</b><br><span class="faint">'+esc(d.slice(0,90))+(d.length>90?"…":"")+'</span></span></div>';
  }).join("")+(bi>=bs.length-1?'<p class="empty">Last block. Wrap up and stamp Passports.</p>':'');
  // room pulse
  var ks=kidsSorted(), here=0, data=0, lights={green:0,yellow:0,red:0}, pred={easy:0,medium:0,hard:0};
  ks.forEach(function(k){ if(k.here[uk()]) here++; var c2=ci(k.key); data+=c2.data||0; if(c2.light) lights[c2.light]++; if(c2.predict) pred[c2.predict]++; });
  document.getElementById("coachRoom").innerHTML='<span class="lbl">Room pulse &middot; '+esc(unitLabel())+'</span>'+
    '<div class="stat"><div><b>'+here+'/'+ks.length+'</b><span>checked in</span></div><div><b>'+data+'</b><span>“Data!” moments</span></div>'+
    '<div><b>'+pred.hard+'</b><span>predicted hard</span></div><div><b><span class="light green"></span> '+lights.green+' <span class="light yellow"></span> '+lights.yellow+' <span class="light red"></span> '+lights.red+'</b><span>Check Out lights</span></div></div>';
  renderRoster(); renderCoachClass(); renderFamilies();
}
function renderRoster(){
  var t=shownT(), ks=kidsSorted(), tb=document.getElementById("roster"), html;
  if(!ks.length) html='<tr><td class="empty" style="white-space:normal">No kids yet. Add each kid below with their station and seat. Seats decide the job rotation.</td></tr>';
  else html='<tr><th>Here</th><th>Kid</th><th>St</th><th>Job now</th><th>Level</th><th>Predict</th><th>Light</th><th>Data</th><th></th><th></th></tr>'+ks.map(function(k){
    var r=roleFor(k,t), c=ci(k.key), on=live.spot===k.key;
    return '<tr><td><input type="checkbox" class="stamp" id="here_'+esc(k.key)+'" data-here="'+esc(k.key)+'" '+(k.here[uk()]?"checked":"")+' '+(canCoach?"":"disabled")+' aria-label="'+esc(k.name)+' is here"></td>'+
      '<td><b>'+esc(k.name)+'</b></td><td>'+k.station+seatName(k.seat)+'</td>'+
      '<td>'+(r?'<span class="chip" style="background:'+cssv(r.role.c)+';color:#fff">'+r.role.k+'</span>':'<span class="faint">Together</span>')+'</td>'+
      '<td>'+esc(c.level?cap(c.level):"–")+'</td><td>'+esc(c.predict?cap(c.predict):"–")+'</td>'+
      '<td><span class="light '+esc(c.light||"")+'" title="'+esc(c.next||c.light||"no rating yet")+'"></span></td><td class="num">'+(c.data||0)+'</td>'+
      '<td>'+(canCoach?((connected && !roster.kids[k.key].perform)?'<span class="faint" title="No performance consent on file">No consent</span>':'<button class="btn sm'+(on?" on":"")+'" data-spot="'+esc(k.key)+'" aria-pressed="'+on+'">Spot</button>'):'')+'</td>'+
      '<td>'+(canCoach?'<button class="x" data-del="'+esc(k.key)+'" aria-label="Remove '+esc(k.name)+'">×</button>':'')+'</td></tr>';
  }).join("");
  if(tb._h!==html){ tb.innerHTML=html; tb._h=html; }
  var s=unit(), sc=document.getElementById("coachStamps"), sh='<span class="lbl">Passport stamps &middot; '+esc(unitLabel())+'</span>'+
    '<p class="faint" style="margin:4px 0 8px">'+s.checks.map(function(c,i){ return (i+1)+". "+esc(c); }).join(" &middot; ")+'. Help is allowed on one.</p>'+
    (ks.length?'<div class="tablewrap"><table class="r"><tr><th>Kid</th><th>1</th><th>2</th><th>3</th></tr>'+ks.map(function(k){
      var arr=k.stamps[uk()]||[false,false,false];
      return '<tr><td>'+esc(k.name)+'</td>'+[0,1,2].map(function(i){ return '<td><input type="checkbox" class="stamp" id="st_'+esc(k.key)+'_'+i+'" data-stamp="'+esc(k.key)+'" data-i="'+i+'" '+(arr[i]?"checked":"")+' '+(canCoach?"":"disabled")+' aria-label="'+esc(k.name)+': '+esc(s.checks[i])+'"></td>'; }).join("")+'</tr>';
    }).join("")+'</table></div>':'<p class="empty">Add kids to the station board to stamp Passports.</p>');
  if(sc._h!==sh){ sc.innerHTML=sh; sc._h=sh; }
}

// ---------- PARENT ----------
function renderParent(){
  var s=unit(), t=shownT(), bs=blocks(), bi=blockAt(t), B=bs[bi], st=stateName();
  var me=kidObj(document.getElementById("pWho").value), nm=me?me.name:"Your child";
  var el=document.getElementById("parentNow"); el.style.setProperty("--c",cssv(B.c));
  var r=me?roleFor(me,t):null;
  var spotMe = me && live.spot===me.key && B.def==="spot" && previewT==null && st!=="idle";
  var doing = !me ? "Pick your child above to see their station and job." :
    spotMe ? esc(nm)+" is on the main speaker right now!" :
    r ? esc(nm)+" is at Station "+me.station+" as <b>"+r.role.k+"</b>: "+esc(r.role.job.charAt(0).toLowerCase()+r.role.job.slice(1)) :
    esc(nm)+" is with the whole group for this block.";
  var head=previewT!=null?"Preview":st==="idle"?"Hasn’t started yet":st==="done"?"Finished":st==="paused"?"Paused":"Happening now";
  el.innerHTML='<span class="lbl">'+head+' &middot; '+fmt(t)+' in</span><h2>'+esc(B.name)+'</h2>'+
    '<p class="muted" style="margin:0">'+esc(B.parent)+'</p>'+
    '<div class="yours'+(spotMe?" star":"")+'">'+doing+'</div>'+
    '<div class="prog" aria-label="Progress"><i style="width:'+(t/TOTAL()*100)+'%"></i></div>'+
    '<div class="faint" style="display:flex;justify-content:space-between;gap:10px;margin-top:6px"><span>'+fmt(B.b*60-t)+' left in this block</span><span>'+fmt(TOTAL()-t)+' left</span></div>'+
    '<div class="ask" style="margin-top:12px"><span class="lbl">Ask about this part</span><p>'+esc(B.ride)+'</p></div>';
  document.getElementById("parentTl").innerHTML=bs.map(function(b,i){
    var cls=i<bi?"done":i===bi?"now":"", wall=wallAt(b.a);
    return '<li class="'+cls+'" style="--c:'+cssv(b.c)+'"><span class="tm">'+(wall||(b.a+":00"))+'</span><span class="d"></span><span><b>'+esc(b.name)+'</b><p>'+esc(b.parent)+'</p></span></li>';
  }).join("");
  document.getElementById("pHere").textContent = me ? (me.here[uk()] ? "Checked in at "+new Date(me.here[uk()]).toLocaleTimeString([], {hour:"numeric",minute:"2-digit"}) : "Not checked in yet") : "";
  renderParentKid();
}
function renderParentKid(){
  var s=unit(), me=kidObj(document.getElementById("pWho").value), el=document.getElementById("parentKid");
  var c=me?ci(me.key):{}, nm=me?esc(me.name):"Your child", lt={green:"I got it",yellow:"Getting there",red:"Not yet"};
  var glow=me?me.glow[uk()]:"";
  var logs=(c.mixlog||[]).slice(-2).reverse();
  var html='<span class="lbl">Today &middot; '+esc(unitLabel())+(fast()?' &middot; '+esc(s.covers):'')+'</span>'+
    '<h3 style="font-size:1.2rem;margin:6px 0 4px">'+esc(s.title)+'</h3>'+
    '<p style="margin:0"><b>Mission:</b> '+esc(s.mission)+'</p>'+
    '<div class="facts">'+
      '<div><span class="lbl">Predicted</span><p>'+(c.predict?esc(cap(c.predict)):'<span class="faint">Not yet</span>')+'</p></div>'+
      '<div><span class="lbl">Self-rating</span><p>'+(c.light?'<span class="light '+esc(c.light)+'"></span> '+lt[c.light]:'<span class="faint">At Check Out</span>')+'</p></div>'+
      '<div><span class="lbl">Level chosen</span><p>'+(c.level?esc(cap(c.level)):'<span class="faint">In Deck Time</span>')+'</p></div>'+
      '<div><span class="lbl">Crashes turned to data</span><p class="num">'+(c.data||0)+'</p></div>'+
    '</div>'+
    (c.next?'<p style="margin:12px 0 0"><b>Next time '+nm+' will:</b> '+esc(c.next)+'</p>':'')+
    (glow?'<div class="ask" style="margin-top:12px; border-left:4px solid var(--sc)"><span class="lbl">Coach’s glow for '+nm+'</span><p>'+esc(glow)+'</p></div>':'')+
    (logs.length?'<div style="margin-top:12px"><span class="lbl">From the Mix Log</span><ul class="logs">'+logs.map(function(m){ return '<li><b>'+esc(m.pair||"Mix")+'</b><br>'+esc(m.what||"")+'</li>'; }).join("")+'</ul></div>':'')+
    '<div class="ask" style="margin-top:12px"><span class="lbl">Ask at dinner</span><p>'+esc(s.home)+'</p></div>';
  if(el._h!==html){ el.innerHTML=html; el._h=html; }
  var pp=document.getElementById("parentPass"), total=0;
  if(fast()){
    var fg=0, fh='<span class="lbl">'+nm+'’s Fast-Track Passport</span><div class="passport" style="margin-top:10px;grid-template-columns:repeat(6,minmax(0,1fr))">'+W.map(function(w){
      var got=0; if(me){ (me.stamps["w"+w.n]||[]).forEach(function(x){ if(x) got++; }); } fg+=got;
      return '<div class="'+(got>=3?"got":"")+(DARK_INK[w.color]?" lt":"")+'" style="--c:'+cssv(COLORS[w.color])+'">W'+w.n+'<small>'+got+'/3</small></div>'; }).join("")+'</div>'+
      '<p class="faint" style="margin:8px 0 0">'+fg+' of 18 fast-track stamps. Three stamps complete a workshop. The six workshops cover the full course&rsquo;s colors in a shorter season.</p>';
    if(pp._h!==fh){ pp.innerHTML=fh; pp._h=fh; }
    renderParentRecap();
  } else {
  var ph='<span class="lbl">'+nm+'’s Rainbow Passport</span><div class="passport" style="margin-top:10px">'+ORDER.map(function(col,i2){
    var got=0; if(me){ ["s"+(i2*2+1),"s"+(i2*2+2)].forEach(function(k){ (me.stamps[k]||[]).forEach(function(x){ if(x) got++; }); }); }
    total+=got;
    return '<div class="'+(got>=6?"got":"")+(DARK_INK[col]?" lt":"")+'" style="--c:'+cssv(COLORS[col])+'">'+cap(col)+'<small>'+got+'/6</small></div>';
  }).join("")+'</div>';
  var fastGot=0; if(me){ for(var w=1;w<=6;w++){ (me.stamps["w"+w]||[]).forEach(function(x){ if(x) fastGot++; }); } }
  ph+='<p class="faint" style="margin:8px 0 0">'+total+' of 42 course stamps'+(fastGot?' &middot; '+fastGot+' of 18 fast-track stamps':'')+'. A full color (6 stamps) is a badge.</p>';
  if(pp._h!==ph){ pp.innerHTML=ph; pp._h=ph; }
  renderParentRecap();
  }
  var f=document.getElementById("feed"), items=(live.feed||[]).slice().reverse();
  var fh=items.length?items.map(function(m){ return '<li><span>'+esc(new Date(m.at).toLocaleTimeString([], {hour:"numeric",minute:"2-digit"}))+'</span>'+esc(m.text)+'</li>'; }).join(""):'<li class="empty" style="border:0;padding:0">No messages yet.</li>';
  if(f._h!==fh){ f.innerHTML=fh; f._h=fh; }
}

// ---------- pickers ----------
function fillPickers(){
  var ks=kidsSorted();
  var opts=ks.map(function(k){ return '<option value="'+esc(k.key)+'">'+esc(k.name)+' · Station '+k.station+'</option>'; }).join("");
  [["kidWho",'<option value="">Pick your name or station</option><optgroup label="Shared station screen"><option value="st:1">Station 1 screen</option><option value="st:2">Station 2 screen</option><option value="st:3">Station 3 screen</option></optgroup><optgroup label="Kids">'+opts+'</optgroup>'],
   ["pWho",'<option value="">Pick your child</option>'+opts],["gKid",'<option value="">Pick a kid</option>'+opts]].forEach(function(p){
    var sel=document.getElementById(p[0]), cur=sel.value||store("djlab-"+p[0])||"";
    if(sel._h!==p[1]){ sel.innerHTML=p[1]; sel._h=p[1]; }
    if(cur.indexOf("st:")===0||roster.kids[cur]) sel.value=cur; else sel.value="";
  });
  if(MODE==="family" && ks.length===1){ document.getElementById("pWho").value=ks[0].key; }
  document.getElementById("cMode").value=live.mode;
  var cs=document.getElementById("cSession"), list=fast()?W:S;
  var ch=list.map(function(s){ return '<option value="'+s.n+'">'+(fast()?"W":"")+s.n+'. '+cap(s.color)+' · '+esc(s.title)+'</option>'; }).join("");
  if(cs._h!==ch){ cs.innerHTML=ch; cs._h=ch; }
  cs.value=String(fast()?live.ws:live.session);
}

// ---------- orchestration ----------
function renderAll(){
  renderHeader();
  if(view==="kid") renderKid(); else if(view==="coach") renderCoach(); else renderParent();
}
function renderData(){ fillPickers(); renderAll(); }
function setView(v){
  view=v; store("djlab-view",v);
  ["kid","coach","parent"].forEach(function(x){ document.getElementById("view-"+x).hidden=x!==v; document.getElementById("tab-"+x).setAttribute("aria-selected",String(x===v)); });
  if(location.hash!=="#"+v){ try{ history.replaceState(null,"","#"+v); }catch(e){} }
  renderAll();
}

// ---------- events ----------
function $(id){ return document.getElementById(id); }
document.querySelectorAll("nav.views button").forEach(function(b){ b.addEventListener("click",function(){ setView(b.dataset.v); }); });
$("backLive").addEventListener("click",function(){ previewT=null; renderAll(); });
$("cStart").addEventListener("click",startPause);
$("cBack").addEventListener("click",function(){ jumpBlock(-1); });
$("cNext").addEventListener("click",function(){ jumpBlock(1); });
$("cAdd").addEventListener("click",function(){ setT(liveT()-60); toast("One more minute added to this block."); });
$("cReset").addEventListener("click",function(){
  var b=this;
  if(b.dataset.armed){ delete b.dataset.armed; b.textContent="Reset"; saveLive({running:false, base:0, markAt:sNow(), spot:null}); }
  else { b.dataset.armed="1"; b.textContent="Tap again to reset"; setTimeout(function(){ if(b.dataset.armed){ delete b.dataset.armed; b.textContent="Reset"; } },3000); }
});
$("cMode").addEventListener("change",function(){ previewT=null; saveLive({mode:this.value, running:false, base:0, markAt:sNow(), spot:null}); });
$("cSession").addEventListener("change",function(){ previewT=null; var n=Number(this.value); saveLive(fast()?{ws:n,running:false,base:0,markAt:sNow(),spot:null}:{session:n,running:false,base:0,markAt:sNow(),spot:null}); });
$("castSend").addEventListener("click",function(){
  var v=$("castIn").value.trim(); if(!v) return;
  saveLive({msg:v, msgAt:sNow(), feed:(live.feed||[]).concat([{text:v, at:sNow()}]).slice(-20)}); $("castIn").value=""; toast("Sent to every screen.");
});
$("castIn").addEventListener("keydown",function(e){ if(e.key==="Enter") $("castSend").click(); });
$("castClear").addEventListener("click",function(){ saveLive({msg:""}); });
$("rAdd").addEventListener("click",function(){
  var n=$("rName").value.trim(); if(!n) return;
  if(connected && !$("rPaper").checked){ toast("Add children through online registration, or tick that their paper forms are on file."); return; }
  addKid(n.slice(0,24), Number($("rStation").value), Number($("rSeat").value), {paper_forms:$("rPaper").checked, tracking_consent:$("rTrack").checked, performance_consent:$("rPerf").checked, media_consent:$("rMedia").checked});
  $("rName").value=""; toast(n+" added to Station "+$("rStation").value+".");
});
$("rName").addEventListener("keydown",function(e){ if(e.key==="Enter") $("rAdd").click(); });
$("roster").addEventListener("click",function(e){
  var d=e.target.closest("[data-del]"), sp=e.target.closest("[data-spot]");
  if(sp){ var k=sp.dataset.spot; if(connected && live.spot!==k && !roster.kids[k].perform){ toast("No performance consent on file for "+roster.kids[k].name+"."); return; }
    saveLive({spot: live.spot===k?null:k}); if(live.spot) toast(roster.kids[k].name+" is in the Spotlight."); return; }
  if(!d) return;
  if(!d.dataset.armed){ d.dataset.armed="1"; d.textContent="Remove?"; return; }
  delKid(d.dataset.del);
});
$("roster").addEventListener("change",function(e){
  var c=e.target; if(!c.dataset||!c.dataset.here) return;
  var k=c.dataset.here, kid=roster.kids[k]; if(!kid) return;
  var here=Object.assign({},kid.here||{}); if(c.checked) here[uk()]=sNow(); else delete here[uk()];
  patchKid(k,{here:here});
});
$("coachStamps").addEventListener("change",function(e){
  var c=e.target; if(!c.dataset||!c.dataset.stamp) return;
  var k=c.dataset.stamp, kid=roster.kids[k]; if(!kid) return;
  var stamps=Object.assign({},kid.stamps||{}), arr=(stamps[uk()]||[false,false,false]).slice(); arr[Number(c.dataset.i)]=c.checked; stamps[uk()]=arr;
  patchKid(k,{stamps:stamps});
  if(c.checked) toast(arr.filter(Boolean).length===3 ? kid.name+": all three stamps for today!" : kid.name+": stamp "+arr.filter(Boolean).length+" of 3.");
});
$("gKid").addEventListener("change",function(){ var k=kidObj(this.value); $("gText").value=k?(k.glow[uk()]||""):""; $("gMsg").textContent=""; });
$("gSave").addEventListener("click",function(){
  var k=$("gKid").value, kid=roster.kids[k]; if(!kid) { $("gMsg").textContent="Pick a kid first."; return; }
  var glow=Object.assign({},kid.glow||{}), v=$("gText").value.trim(); if(v) glow[uk()]=v.slice(0,200); else delete glow[uk()];
  patchKid(k,{glow:glow}); $("gMsg").textContent="Saved. "+kid.name+"’s family can see it.";
});
$("kidWho").addEventListener("change",function(){ store("djlab-kidWho",this.value); $("kidNext").value=""; renderAll(); });
$("pWho").addEventListener("change",function(){ store("djlab-pWho",this.value); renderAll(); });
$("kidActInner").addEventListener("click",function(e){
  var b=e.target.closest("[data-kid]"); if(!b) return;
  var patch={}; patch[b.dataset.f]=b.dataset.v; saveCheckin(b.dataset.kid,patch);
});
$("kidJob").addEventListener("click",function(e){
  var sel=screenSel();
  var lv=e.target.closest("[data-level]");
  if(lv && sel.kid){ saveCheckin(sel.kid.key,{level:lv.dataset.level}); toast(cap(lv.dataset.level)+" level. You chose it. Go."); return; }
  if(e.target.closest("#dataBtn")){
    var tgt=logTarget(); if(!tgt){ toast("Data! Name one reason it crashed."); return; }
    saveCheckin(tgt.key,function(cur){ return {data:(cur.data||0)+1}; },"inc_data");
    toast("Data! "+(sel.station?tgt.name+", name":"Name")+" one reason it crashed.");
  }
});
$("kidNextSave").addEventListener("click",function(){
  var sel=screenSel(); if(!sel.kid) return;
  var v=$("kidNext").value.trim(); if(!v) return;
  saveCheckin(sel.kid.key,{next:v.slice(0,140)}).then(function(ok){ $("kidSaveMsg").textContent=ok?"Saved. Your family can see it too.":"Couldn’t save. Tell your coach."; });
});
$("logSave").addEventListener("click",function(){
  var tgt=logTarget(); if(!tgt){ $("logMsg").textContent="Pick a name or station first."; return; }
  var e={pair:$("logPair").value.trim().slice(0,80), what:$("logWhat").value.trim().slice(0,120), fix:$("logFix").value.trim().slice(0,120), at:sNow()};
  if(!e.pair&&!e.what){ $("logMsg").textContent="Write the song pair or what happened."; return; }
  saveCheckin(tgt.key,function(cur){ return {mixlog:(cur.mixlog||[]).concat([e]).slice(-10)}; },"append_mixlog",{pair:e.pair,what:e.what,fix:e.fix}).then(function(ok){ $("logMsg").textContent=ok?"Logged.":"Couldn’t save. Tell your coach."; });
  $("logPair").value=""; $("logWhat").value=""; $("logFix").value="";
});
$("ovClose").addEventListener("click",function(){ var B=blocks()[blockAt(liveT())]; overlayFor=uk()+"|"+B.id+"|closed"; $("overlay").hidden=true; });
document.addEventListener("keydown",function(e){
  if(view!=="coach"||!canCoach) return;
  var tag=(e.target.tagName||"").toUpperCase(); if(tag==="INPUT"||tag==="SELECT"||tag==="TEXTAREA"||tag==="BUTTON") return;
  if(e.code==="Space"){ e.preventDefault(); startPause(); }
  else if(e.key==="ArrowRight"){ jumpBlock(1); }
  else if(e.key==="ArrowLeft"){ jumpBlock(-1); }
});
window.addEventListener("hashchange",function(){ var h=location.hash.slice(1); if(["kid","coach","parent"].indexOf(h)>=0 && h!==view) setView(h); });

// ---------- demo data (only until the shared store connects) ----------
function demoSeed(){
  var now=sNow();
  roster.kids={
    d1:{name:"Example: Jada M.",station:1,seat:0,stamps:{s1:[true,true,false]},here:{s1:now-1500000},glow:{s1:"Faded song 2 in right on the chorus. Ask her to show you!"}},
    d2:{name:"Example: Marcus T.",station:1,seat:1,stamps:{},here:{s1:now-1440000},glow:{}},
    d3:{name:"Example: Aaliyah R.",station:1,seat:2,stamps:{},here:{s1:now-1400000},glow:{}},
    d4:{name:"Example: Devon K.",station:1,seat:3,stamps:{},here:{},glow:{}},
    d5:{name:"Example: Nia W.",station:2,seat:0,stamps:{},here:{s1:now-1300000},glow:{}}
  };
  checkins={d1_s1:{kid:"d1",unit:"s1",predict:"medium",data:2,mixlog:[{pair:"Example song A + song B",what:"Faded in too early, tried again on the chorus",fix:"Wait for the phrase",at:now-200000}]},d2_s1:{kid:"d2",unit:"s1",predict:"hard",data:1}};
  live={mode:"course",session:1,ws:1,running:true,base:23*60+40,markAt:now,msg:"",msgAt:0,feed:[{text:"Example message: Station 1 nailed their first fade!",at:now-120000}],spot:null};
}

// ---------- access: room code, family link, coach (Supabase + Resend) ----------
// Three ways in, each seeing only what it needs:
//  * room   — in-room Kid/Station screens, with a room code the coach issues
//             for each class; it expires after the class.
//  * family — a parent's private link (?f=KEY): ONLY their own child.
//  * coach  — signed in by emailed link; the whole class, plus safety tools.
// With none of these the page is empty until someone picks "See a demo".
var REG_URL = "https://selassiefest.com/dj-lab/enroll/register.html";
var MODE = null, FAMILY = null, ROOM_EXPIRES = null, safety = [], safetyAt = 0;
function setCoach(sess){
  coachSess=sess; try{ if(sess) localStorage.setItem("djlab-coach", JSON.stringify(sess)); else localStorage.removeItem("djlab-coach"); }catch(e){}
  if(!sess && MODE==="coach") leaveClass();
  canCoach = MODE==="demo" ? true : (MODE==="coach" && !!coachSess);
  note(MODE==="room" ? "This is an in-room screen. Coaches sign in on the Coach tab." : "");
  if(coachSess) loadCoachClasses(); else coachClasses=[];
  applyTabs(); renderData();
}
function applyTabs(){
  var show = MODE==="family" ? ["parent"] : MODE==="room" ? ["kid","coach"] : ["kid","coach","parent"];
  ["kid","coach","parent"].forEach(function(v){ $("tab-"+v).hidden = show.indexOf(v)<0; });
  if(show.indexOf(view)<0) setView(show[0]);
}
function loadCoachClasses(){
  if(!coachSess) return;
  rpc("djlab_coach_cohorts",{p_session:coachSess.token}).then(function(d){ coachClasses=d.cohorts||[]; renderAll(); }).catch(coachErr);
}
function applyState(d){
  if(!d) return;
  if(d.error){ var m=MODE; leaveClass(); toast(m==="family"?"That family link isn't valid any more. Ask Stephen for a new one.":m==="coach"?"That class isn't available.":"That room code has expired. Ask your coach for today's code."); return; }
  VERSION=Number(d.version)||VERSION;
  if(d.unchanged) return;
  COHORT=Object.assign({}, COHORT||{}, d.cohort||{});
  if(d.room_code!==undefined){ CODE=(d.expires_at && new Date(d.expires_at)>new Date())?d.room_code:null; ROOM_EXPIRES=d.expires_at; }
  if(MODE==="room" && d.expires_at) ROOM_EXPIRES=d.expires_at;
  var L=d.live||{};
  live={mode:L.mode==="fast"?"fast":"course", session:L.session||1, ws:L.ws||1, running:!!L.running, base:Number(L.base)||0, markAt:Number(L.markAt)||sNow(), msg:L.msg||"", msgAt:L.msgAt||0, feed:Array.isArray(L.feed)?L.feed:[], spot:L.spot||null};
  var m={}; (d.kids||[]).forEach(function(k){ m[k.id]={name:k.name, station:k.station, seat:k.seat, stamps:k.stamps||{}, here:k.here||{}, glow:k.glow||{}, recap:!!k.recap, tracking:!!k.tracking, perform:!!k.perform}; });
  roster={kids:m}; checkins=d.checkins||{};
  renderData();
}
function poll(){
  var t0=Date.now(), call;
  if(MODE==="family") call=rpc("djlab_family_state",{p_key:FAMILY, p_since:VERSION});
  else if(MODE==="coach") call=rpc("djlab_coach_state",{p_session:coachSess.token, p_cohort:COHORT.id, p_since:VERSION});
  else if(MODE==="room") call=rpc("djlab_state",{p_code:CODE, p_since:VERSION});
  else return;
  call.then(function(d){ syncClock(t0, Date.now(), d&&d.now); applyState(d); }).catch(function(e){ if(MODE==="coach") coachErr(e); });
  if(MODE==="coach") loadSafety(false);
}
function startMode(mode){
  MODE=mode; connected=true; VERSION=0; previewT=null; roster={kids:{}}; checkins={}; safety=[]; safetyAt=0;
  ["pWho","kidWho","gKid"].forEach(function(id){ $(id)._h=""; });
  setCoach(coachSess);
  clearInterval(pollTimer); poll(); pollTimer=setInterval(poll, 2000);
}
function joinRoom(code){
  code=String(code||"").trim().toUpperCase(); if(!code) return;
  var t0=Date.now();
  rpc("djlab_state",{p_code:code, p_since:0}).then(function(d){
    syncClock(t0, Date.now(), d&&d.now);
    if(!d || d.error){ toast("That room code isn't active. Ask your coach for today's code."); return; }
    CODE=code; try{ localStorage.setItem("djlab-room", code); }catch(e){}
    startMode("room"); applyState(d);
  }).catch(function(){ toast("Couldn't reach the class. Check your connection."); });
}
function joinFamily(key){
  FAMILY=String(key||"").trim().toLowerCase(); if(!FAMILY) return;
  try{ localStorage.setItem("djlab-family", FAMILY); }catch(e){}
  startMode("family");
}
function openCoachClass(cls){
  COHORT={id:cls.id, name:cls.name, code:cls.code}; CODE=null;
  try{ localStorage.setItem("djlab-coach-class", JSON.stringify(COHORT)); }catch(e){}
  startMode("coach");
  rpc("djlab_coach_room_code", coachArgs({p_renew:false})).then(function(r){ CODE=r.room_code; ROOM_EXPIRES=r.expires_at; renderAll(); }).catch(coachErr);
}
function leaveClass(){
  var was=MODE; MODE=null; CODE=null; COHORT=null; FAMILY=null; connected=false; VERSION=0; clearInterval(pollTimer); CLOCK_OFFSET=0; bestRtt=Infinity;
  try{ localStorage.removeItem("djlab-room"); localStorage.removeItem("djlab-family"); localStorage.removeItem("djlab-coach-class"); }catch(e){}
  ["pWho","kidWho","gKid"].forEach(function(id){ $(id)._h=""; });
  emptyState(); if(was) { canCoach=false; applyTabs(); renderData(); }
}
function emptyState(){
  roster={kids:{}}; checkins={}; live={mode:"course",session:1,ws:1,running:false,base:0,markAt:Date.now(),msg:"",msgAt:0,feed:[],spot:null};
}
function startDemo(){ demoSeed(); MODE="demo"; connected=false; canCoach=true; applyTabs(); fillPickers(); if(!$("pWho").value) $("pWho").value="d1"; if(!$("kidWho").value) $("kidWho").value="d1"; renderData(); }
function fmtExp(iso){ return iso ? new Date(iso).toLocaleTimeString([], {hour:"numeric", minute:"2-digit"}) : ""; }
function renderJoin(){
  var el=$("joinBar"), h;
  if(MODE==="family"){
    h='<span><b>Family view</b> &middot; '+esc(COHORT&&COHORT.name||"")+' &middot; only your child is shown</span><span class="sp"></span><button class="btn sm" id="leaveBtn">Close</button>';
  } else if(MODE==="room"){
    h='<span>In-room screen &middot; <b>'+esc(COHORT&&COHORT.name||"")+'</b> &middot; room code <span class="code">'+esc(CODE)+'</span>'+(ROOM_EXPIRES?' &middot; ends '+fmtExp(ROOM_EXPIRES):'')+'</span><span class="sp"></span><button class="btn sm" id="leaveBtn">Leave</button>';
  } else if(MODE==="coach"){
    h='<span>Coach &middot; <b>'+esc(COHORT&&COHORT.name||"")+'</b></span><span class="sp"></span><span class="faint">'+esc(coachSess?coachSess.name:"")+'</span><button class="btn sm" id="leaveBtn">Close class</button>';
  } else if(MODE==="demo"){
    h='<span><b>Demo class</b> with example kids. Nothing here is real or saved.</span><span class="sp"></span><button class="btn sm" id="leaveBtn">Exit demo</button>';
  } else {
    h='<span><b>Parents:</b> open the private link we emailed you. <b>In the classroom:</b> enter today&rsquo;s room code.</span><span class="sp"></span>'+
      '<input id="codeIn" maxlength="8" placeholder="ROOM CODE" aria-label="Room code" autocomplete="off"><button class="btn primary sm" id="joinBtn">Join</button><button class="btn sm" id="demoBtn">See a demo</button>';
  }
  if(el._h!==h){ el.innerHTML=h; el._h=h; }
}
function renderCoachClass(){
  var el=$("coachClass"), h;
  if(MODE==="room"){ h='<span class="lbl">Coach tools</span><p class="faint" style="margin:4px 0 0">This is an in-room screen showing the coach script. The station board, safety roster and family tools are only on a signed-in coach&rsquo;s device.</p>'; }
  else if(!coachSess){
    h='<span class="lbl">Coach sign-in</span><p class="faint" style="margin:4px 0 8px">Coaches run the clock, the station board, Passports and the safety roster. Families use their private link; in-room screens use today&rsquo;s room code.</p>'+
      '<div class="row" style="flex-wrap:nowrap"><input class="field" id="coachEmail" type="email" placeholder="coach@example.com" autocomplete="email"><button class="btn primary" id="coachSend">Email me a sign-in link</button></div><p class="faint" id="coachMsg" style="margin:6px 0 0"></p>';
  } else {
    var opts=coachClasses.map(function(c){ return '<option value="'+esc(c.id)+'"'+(COHORT&&c.id===COHORT.id?' selected':'')+'>'+esc(c.name)+'</option>'; }).join("");
    var live_room = CODE && ROOM_EXPIRES && new Date(ROOM_EXPIRES)>new Date();
    h='<div class="row" style="justify-content:space-between"><span class="lbl">Coach &middot; '+esc(coachSess.name)+'</span><button class="btn sm" id="coachOut">Sign out</button></div>'+
      '<div class="row" style="margin-top:8px"><select class="pick" id="classPick"><option value="">Choose a class</option>'+opts+'</select><button class="btn sm" id="classOpen">Open</button>'+
      '<span class="sp"></span><input class="field" id="className" placeholder="New class name" style="width:200px"><button class="btn sm" id="classNew">Create class</button></div>'+
      (MODE==="coach"?'<div class="linkbox"><b>Today&rsquo;s room code for in-room screens:</b> '+(live_room?'<span class="code" style="font-size:1.2rem">'+esc(CODE)+'</span> (ends '+fmtExp(ROOM_EXPIRES)+')':'<i>none active</i>')+
        ' <button class="btn sm" id="roomNew">'+(live_room?'New code':'Start room')+'</button>'+(live_room?' <button class="btn sm" id="roomEnd">End room now</button>':'')+
        '<br><span class="faint">Show it only on screens in the room. It stops working when it ends. Families never use it: they get a private link when you approve them.</span>'+
        '<br><b>Registration link:</b> '+esc(REG_URL)+'?c='+esc(COHORT.code||"")+'</div>':'<p class="faint" style="margin:8px 0 0">Open or create a class to run it live.</p>');
  }
  if(el._h!==h){ el.innerHTML=h; el._h=h; }
}
function loadRegs(force){
  if(!(coachSess && COHORT && MODE==="coach")) return;
  if(!force && Date.now()-regsAt<20000) return; regsAt=Date.now();
  rpc("djlab_coach_registrations", coachArgs({})).then(function(d){ regs=d||[]; renderAll(); }).catch(coachErr);
}
function loadSafety(force){
  if(!(coachSess && COHORT && MODE==="coach")) return;
  if(!force && Date.now()-safetyAt<30000) return; safetyAt=Date.now();
  rpc("djlab_coach_safety_roster", coachArgs({})).then(function(d){ safety=d||[]; renderAll(); }).catch(coachErr);
}
function renderFamilies(){
  var el=$("coachFamilies"), sc=$("coachSafety"); var on=!!(coachSess && MODE==="coach" && COHORT);
  el.hidden=!on; sc.hidden=!on; if(!on) return;
  loadRegs(false); loadSafety(false);
  // Safety now: one tap, no search.
  var here=safety.filter(function(k){ return k.here && k.here[uk()]; });
  var flagged=here.filter(function(k){ return (k.allergies && !/^none$/i.test(k.allergies)) || k.epinephrine || k.medical || k.custody_note; });
  var sh='<div class="row" style="justify-content:space-between"><span class="lbl">Safety now &middot; '+here.length+' checked in</span><a class="btn sm primary" href="/dj-lab/portal/signout.html">Sign-out &amp; full roster</a></div>'+
    (flagged.length?flagged.map(function(k){ return '<div class="reg"><b>'+esc(k.name)+'</b> <span class="faint">Station '+k.station+'</span><div>'+
      (k.allergies && !/^none$/i.test(k.allergies)?'<span class="chip" style="background:var(--bad-soft);color:var(--bad)">Allergy: '+esc(k.allergies)+'</span> ':'')+
      (k.epinephrine?'<span class="chip" style="background:var(--bad-soft);color:var(--bad)">EpiPen: with trained adult</span> ':'')+
      (k.medical?'<span class="chip" style="background:var(--warn-soft);color:var(--warn)">'+esc(k.medical)+'</span> ':'')+
      (k.custody_note?'<span class="chip" style="background:var(--bad-soft);color:var(--bad)">Custody: '+esc(k.custody_note)+'</span>':'')+
      '</div><div class="faint">Guardian '+esc(k.guardian||"")+(k.guardian_phone?' &middot; <a href="tel:'+esc(String(k.guardian_phone).replace(/[^0-9+]/g,""))+'">'+esc(k.guardian_phone)+'</a>':'')+'</div></div>'; }).join("")
      :'<p class="faint" style="margin:6px 0">No allergy, medical or custody flags for the children checked in.</p>')+
    '<p class="faint" style="margin:8px 0 4px"><b>Emergency:</b> 911 &middot; Poison Center 1-800-222-1222 &middot; Suspected abuse: DCFS 1-800-25-ABUSE &middot; <a href="/dj-lab/safety/emergency-action-plan.html">Emergency plan</a> &middot; <a href="/dj-lab/safety/epinephrine-protocol.html">EpiPen steps</a> &middot; <a href="/dj-lab/safety/lost-child-plan.html">Lost child</a></p>'+
    '<details style="margin-top:8px"><summary style="cursor:pointer;font-weight:800">Log an incident</summary>'+
      '<div class="row" style="margin-top:8px"><select class="pick" id="incKind"><option value="injury">Injury</option><option value="illness">Illness</option><option value="allergic_reaction">Allergic reaction</option><option value="behavior">Behavior</option><option value="peer_harm">Peer harm</option><option value="safeguarding">Safeguarding concern</option><option value="lost_child">Lost child</option><option value="pickup">Pickup issue</option><option value="other">Other</option></select>'+
      '<select class="pick" id="incKid"><option value="">No specific child</option>'+safety.map(function(k){ return '<option value="'+esc(k.id)+'">'+esc(k.name)+'</option>'; }).join("")+'</select></div>'+
      '<textarea class="field" id="incWhat" rows="2" style="margin-top:8px" placeholder="What happened (facts only: who, what, when, where)"></textarea>'+
      '<textarea class="field" id="incAction" rows="2" style="margin-top:8px" placeholder="What you did"></textarea>'+
      '<label class="faint" style="display:block;margin-top:6px"><input type="checkbox" id="incParent"> Parent has been called</label><label class="faint" style="display:block"><input type="checkbox" id="incCall"> 911 was called</label>'+
      '<button class="btn primary sm" id="incSave" style="margin-top:8px">Log incident and email Stephen</button> <span class="faint" id="incMsg"></span>'+
      '<p class="faint" style="margin:6px 0 0">Suspected abuse or neglect: call the DCFS Hotline yourself, right away. Logging here does not replace that call. <a href="/dj-lab/safety/incident-reporting.html">Incident reporting</a></p></details>';
  if(sc._h!==sh){ sc.innerHTML=sh; sc._h=sh; }
  var ks=kidsSorted(), recapKids=ks.filter(function(k){ return roster.kids[k.key].recap; }), hereRecap=recapKids.filter(function(k){ return k.here[uk()]; });
  var withGuardian=safety.filter(function(k){ return k.guardian; });
  var h='<span class="lbl">Families &middot; '+esc(unitLabel())+'</span>'+
    '<p class="faint" style="margin:4px 0 8px">'+recapKids.length+' of '+ks.length+' kids have a family signed up for recap emails; '+hereRecap.length+' of them are checked in today.</p>'+
    '<button class="btn primary" id="recapSend"'+(hereRecap.length?'':' disabled')+'>Email today&rsquo;s recaps ('+hereRecap.length+')</button> <span class="faint" id="recapMsg"></span>'+
    '<p class="faint" style="margin:6px 0 0">Recaps go to families of checked-in kids: Mission, self-rating, &ldquo;Next time I&rsquo;ll&hellip;&rdquo;, your glow, stamps and the dinner question. Each family gets one per session.</p>'+
    (withGuardian.length?'<details style="margin-top:10px"><summary style="cursor:pointer;font-weight:700">Resend a family&rsquo;s private link</summary>'+withGuardian.map(function(k){ return '<div class="row" style="margin-top:6px"><span style="flex:1">'+esc(k.name)+' <span class="faint">('+esc(k.guardian)+')</span></span><button class="btn sm" data-famlink="'+esc(k.id)+'">Email link</button></div>'; }).join("")+'</details>':'')+
    '<div style="margin-top:12px"><span class="lbl">Waiting for approval ('+regs.length+')</span>'+
    (regs.length?regs.map(function(r){
      return '<div class="reg"><div><b>'+esc(r.kid)+'</b>'+(r.age?' &middot; age '+esc(r.age):'')+' &middot; <span class="faint">guardian '+esc(r.guardian)+(r.recap?' &middot; wants recaps':'')+(r.photo?' &middot; photo OK':' &middot; no photos')+'</span></div>'+
        (r.accommodations?'<div class="faint">Needs: '+esc(r.accommodations)+'</div>':'')+
        '<div class="row"><select class="pick" data-rst="'+esc(r.id)+'"><option value="1">Station 1</option><option value="2">Station 2</option><option value="3">Station 3</option></select>'+
        '<select class="pick" data-rse="'+esc(r.id)+'"><option value="0">Seat A</option><option value="1">Seat B</option><option value="2">Seat C</option><option value="3">Seat D</option></select>'+
        '<button class="btn sm primary" data-approve="'+esc(r.id)+'">Approve &amp; email family link</button><button class="btn sm" data-decline="'+esc(r.id)+'">Decline</button></div></div>';
    }).join(""):'<p class="empty" style="margin:6px 0 0">No one waiting. Share the registration link above.</p>')+'</div>';
  if(el._h!==h){ el.innerHTML=h; el._h=h; }
}
function renderParentRecap(){
  var el=$("parentRecap");
  var h='<span class="lbl">Family guide</span><p style="margin:6px 0 8px">Pickup rules, safety, privacy and how to reach us.</p>'+
    '<a class="btn" href="/dj-lab/families/handbook.html">Handbook</a> <a class="btn" href="/dj-lab/safety/arrival-signout.html">Pickup</a> <a class="btn" href="/dj-lab/privacy/parent-data-rights.html">Your data rights</a> <a class="btn" href="/dj-lab/safety/report-a-concern.html">Report a concern</a>';
  if(el._h!==h){ el.innerHTML=h; el._h=h; }
}
document.addEventListener("click", function(e){
  var t=e.target;
  if(t.closest("#joinBtn")){ joinRoom($("codeIn").value); return; }
  if(t.closest("#demoBtn")){ startDemo(); return; }
  if(t.closest("#leaveBtn")){ if(MODE==="demo"){ MODE=null; emptyState(); canCoach=false; ["pWho","kidWho","gKid"].forEach(function(id){ $(id)._h=""; }); applyTabs(); renderData(); } else leaveClass(); return; }
  if(t.closest("#coachSend")){
    var em=$("coachEmail").value.trim(); if(!em) return; $("coachMsg").textContent="Sending…";
    window.sfSupabaseReady.then(function(c){ return c.from("djlab_coach_login_links").insert({email:em}); }).then(function(r){
      $("coachMsg").textContent = r.error ? "That email isn't on the coach list. Ask Stephen to add you." : "Check your email for the sign-in link (works for 30 minutes).";
    });
    return;
  }
  if(t.closest("#coachOut")){ setCoach(null); return; }
  if(t.closest("#classOpen")){ var v=$("classPick").value, c=coachClasses.filter(function(x){ return x.id===v; })[0]; if(c) openCoachClass(c); return; }
  if(t.closest("#classNew")){
    var nm=$("className").value.trim(); if(!nm){ toast("Name the class first, e.g. Spring Cohort A."); return; }
    rpc("djlab_coach_new_cohort",{p_session:coachSess.token, p_name:nm}).then(function(c){ toast("Created "+c.name+"."); loadCoachClasses(); openCoachClass(c); }).catch(coachErr);
    return;
  }
  if(t.closest("#roomNew")){ rpc("djlab_coach_room_code", coachArgs({p_renew:true})).then(function(r){ CODE=r.room_code; ROOM_EXPIRES=r.expires_at; toast("Room code "+r.room_code+" until "+fmtExp(r.expires_at)+"."); renderAll(); }).catch(coachErr); return; }
  if(t.closest("#roomEnd")){ rpc("djlab_coach_end_room", coachArgs({})).then(function(){ ROOM_EXPIRES=new Date().toISOString(); toast("Room code ended. In-room screens are disconnected."); renderAll(); }).catch(coachErr); return; }
  var fl=t.closest("[data-famlink]");
  if(fl){ rpc("djlab_coach_send_family_link", coachArgs({p_kid:fl.getAttribute("data-famlink")})).then(function(){ toast("Family link emailed."); }).catch(coachErr); return; }
  if(t.closest("#incSave")){
    var what=$("incWhat").value.trim(); if(!what){ $("incMsg").textContent="Describe what happened."; return; }
    rpc("djlab_coach_incident", coachArgs({p_kid:$("incKid").value||null, p_unit:uk(), p_kind:$("incKind").value, p_what:what, p_action:$("incAction").value.trim(), p_parent:$("incParent").checked, p_911:$("incCall").checked}))
      .then(function(){ $("incMsg").textContent="Logged and emailed to Stephen."; $("incWhat").value=""; $("incAction").value=""; }).catch(coachErr);
    return;
  }
  var ap=t.closest("[data-approve]"), de=t.closest("[data-decline]");
  if(ap||de){
    var id=(ap||de).getAttribute(ap?"data-approve":"data-decline");
    var st=document.querySelector('[data-rst="'+id+'"]'), se=document.querySelector('[data-rse="'+id+'"]');
    rpc("djlab_coach_approve", coachArgs({p_reg:id, p_station:Number(st&&st.value)||1, p_seat:Number(se&&se.value)||0, p_approve:!!ap}))
      .then(function(d){ toast(ap?(d.name+" added. Their family link is on its way."):"Registration declined."); loadRegs(true); loadSafety(true); poll(); }).catch(coachErr);
    return;
  }
  if(t.closest("#recapSend")){
    var s=unit(), btn=$("recapSend"); btn.disabled=true; $("recapMsg").textContent="Sending…";
    window.sfSupabaseReady.then(function(c){
      return c.functions.invoke("djlab-send-recaps",{body:{session:coachSess.token, cohort:COHORT.id, unit:uk(),
        lesson:{label:unitLabel(), color:s.color, title:s.title, mission:s.mission, home:s.home, checks:s.checks}}});
    }).then(function(r){
      btn.disabled=false;
      if(r.error){ $("recapMsg").textContent="Couldn't send. Try again."; return; }
      var d=r.data||{}; $("recapMsg").textContent="Sent "+(d.sent||0)+(d.skipped?" · "+d.skipped+" already sent":"")+(d.failed&&d.failed.length?" · failed: "+d.failed.join(", "):"");
    });
  }
});
document.addEventListener("keydown", function(e){ if(e.key==="Enter" && e.target && e.target.id==="codeIn") joinRoom(e.target.value); });

// ---------- boot ----------
var startView=location.hash.slice(1);
if(["kid","coach","parent"].indexOf(startView)<0) startView=store("djlab-view")||"kid";
emptyState(); fillPickers();
setView(startView);
setInterval(renderAll,1000);

(async function boot(){
  var q=new URLSearchParams(location.search), tok=q.get("coach_token"), room=q.get("c"), fam=q.get("f");
  try{ coachSess=JSON.parse(localStorage.getItem("djlab-coach")||"null"); }catch(e){ coachSess=null; }
  if(tok || room || fam){ try{ history.replaceState(null,"",location.pathname+location.hash); }catch(e){} }
  if(tok){
    try{ var r=await rpc("djlab_verify_login_link",{p_token:tok}); if(r&&r.length){ coachSess={token:r[0].session_token, name:r[0].display_name, email:r[0].email}; toast("Signed in as coach: "+r[0].display_name); } else toast("That coach link is invalid or expired."); }
    catch(e){ toast("That coach link is invalid or expired."); }
  }
  setCoach(coachSess);
  if(fam) return joinFamily(fam);
  if(room) return joinRoom(room);
  var savedClass=null; try{ savedClass=JSON.parse(localStorage.getItem("djlab-coach-class")||"null"); }catch(e){}
  if(coachSess && savedClass) return openCoachClass(savedClass);
  var f=store("djlab-family"); if(f) return joinFamily(f);
  var rc=store("djlab-room"); if(rc) return joinRoom(rc);
  applyTabs();
})();
})();
