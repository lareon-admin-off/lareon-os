// Lareon's wallpaper: a night sky (or dawn, in the light theme) with layered mountains that drift and shift with the pointer.
(function () {
  var css = '.wall{position:fixed;inset:0;z-index:0;overflow:hidden;pointer-events:none;background:linear-gradient(180deg,var(--sky1),var(--sky2) 52%,var(--sky3))}' +
    '.wall .ly{position:absolute;left:-4%;right:-4%;bottom:0;transition:transform .9s cubic-bezier(.2,.7,.2,1);will-change:transform}' +
    '.wall .ly svg{display:block;width:100%;height:100%}' +
    '.wall .stars{position:absolute;inset:0 0 35% 0;opacity:var(--star);transition:opacity .6s}.wall .stars svg{width:100%;height:100%}' +
    '.wall .orb{position:absolute;right:17%;top:13vh;width:76px;height:76px;border-radius:50%;background:radial-gradient(circle at 38% 36%,#fff,var(--orb) 60%);box-shadow:0 0 90px 30px var(--orb-glow);animation:wOrb 14s ease-in-out infinite alternate}' +
    '.wall .glow{position:absolute;left:0;right:0;bottom:0;height:70vh;background:radial-gradient(60% 70% at 50% 100%,var(--glow),transparent 70%)}' +
    '.wall .veil{position:absolute;inset:0;background:linear-gradient(180deg,transparent 40%,var(--bg) 130%);opacity:.55}' +
    '.sc-star{animation:wTw 4s ease-in-out infinite}' +
    '@keyframes wTw{0%,100%{opacity:.2}50%{opacity:1}}@keyframes wOrb{to{transform:translateY(14px) scale(1.04)}}' +
    '.wall .d1{animation:wDr 46s ease-in-out infinite alternate}.wall .d2{animation:wDr 62s ease-in-out infinite alternate-reverse}.wall .d3{animation:wDr 80s ease-in-out infinite alternate}' +
    '@keyframes wDr{from{transform:translateX(-16px)}to{transform:translateX(16px)}}' +
    '@media(prefers-reduced-motion:reduce){.wall *{animation:none!important;transition:none!important}}';
  var st = document.createElement('style'); st.textContent = css; document.head.appendChild(st);
  var seed = 11; function rnd() { seed = (seed * 9301 + 49297) % 233280; return seed / 233280; }
  var stars = '';
  for (var i = 0; i < 90; i++) {
    var x = (rnd() * 100).toFixed(2), y = (rnd() * 100).toFixed(2), r = (0.4 + rnd() * 1.3).toFixed(2), d = (rnd() * 6).toFixed(2), o = (0.4 + rnd() * 0.6).toFixed(2);
    stars += '<circle class="sc-star" cx="' + x + '%" cy="' + y + '%" r="' + r + '" fill="#fff" opacity="' + o + '" style="animation-delay:-' + d + 's;animation-duration:' + (3 + rnd() * 5).toFixed(1) + 's"/>';
  }
  function grad(id, a, b) { return '<linearGradient id="' + id + '" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="var(' + a + ')"/><stop offset="1" stop-color="var(' + b + ')"/></linearGradient>'; }
  window.mountScene = function () {
    var d = document.createElement('div'); d.className = 'wall'; d.setAttribute('aria-hidden', 'true');
    d.innerHTML =
      '<div class="stars"><svg preserveAspectRatio="none">' + stars + '</svg></div><div class="glow"></div>' +
      '<div class="ly" data-p="6" style="height:64vh"><div class="d3" style="height:100%"><svg viewBox="0 0 1440 520" preserveAspectRatio="xMidYMax slice"><defs>' + grad('wg1', '--m1a', '--m1b') + '</defs>' +
      '<path d="M-60 520V330L90 250L190 310L330 170L450 290L560 230L700 330L830 120L950 260L1070 190L1200 300L1330 210L1500 330V520Z" fill="url(#wg1)"/>' +
      '<path d="M330 170L292 214L322 206L338 228L354 202L384 214Z M830 120L784 182L820 172L838 204L858 168L898 184Z" fill="var(--snow)"/></svg></div></div>' +
      '<div class="ly" data-p="12" style="height:50vh"><div class="d2" style="height:100%"><svg viewBox="0 0 1440 420" preserveAspectRatio="xMidYMax slice"><defs>' + grad('wg2', '--m2a', '--m2b') + '</defs>' +
      '<path d="M-60 420V300L100 220L220 290L360 190L500 300L610 250L740 330L880 210L1010 300L1140 230L1270 310L1400 250L1500 310V420Z" fill="url(#wg2)"/>' +
      '<path d="M360 190L330 224L352 218L366 236L380 216L402 224Z" fill="var(--snow)" opacity=".6"/></svg></div></div>' +
      '<div class="ly" data-p="20" style="height:34vh"><div class="d1" style="height:100%"><svg viewBox="0 0 1440 300" preserveAspectRatio="xMidYMax slice"><defs>' + grad('wg3', '--m3a', '--m3b') + '</defs>' +
      '<path d="M-60 300V210L120 160L260 220L410 140L560 225L700 185L850 240L1000 170L1150 235L1290 190L1500 240V300Z" fill="url(#wg3)"/></svg></div></div>' +
      '<div class="veil"></div>';
    document.body.insertBefore(d, document.body.firstChild);
    var lys = d.querySelectorAll('.ly');
    window.addEventListener('pointermove', function (e) {
      var x = (e.clientX / innerWidth - 0.5), y = (e.clientY / innerHeight - 0.5);
      for (var i = 0; i < lys.length; i++) { var p = +lys[i].getAttribute('data-p'); lys[i].style.transform = 'translate(' + (-x * p).toFixed(1) + 'px,' + (-y * p * 0.5).toFixed(1) + 'px)'; }
    }, { passive: true });
    return d;
  };
})();
