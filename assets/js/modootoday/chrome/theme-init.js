// Pre-paint theme and showcase dismissal (modootoday.csp: strict), blocking in <head>.
try{var d=document.documentElement,t=localStorage.getItem("mt-theme");if((t=="light"||t=="dark")&&document.currentScript.dataset.mtNoTheme==null)d.dataset.theme=t}catch(e){}
try{if(d.dataset.mtShowcase&&sessionStorage.getItem("mt-showcase"))d.dataset.mtShowcase="off"}catch(e){}
