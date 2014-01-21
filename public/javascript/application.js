var lines = $(".text");
var i = -1;
var goTo;

function showNext(url, time) {
  i++;
  if (i == lines.length - 1) {
    lines.eq(i).fadeIn(2000).delay(2000);
    setTimeout(redirect(url), time);
  }
  else {
    lines.eq(i).fadeIn(800).delay(2000).fadeOut(800, function(){
      showNext(url, time);
    });
  }
}

function redirect(url) {
  window.location = "/" + url;
}

$(document).ready(function() {
  if (window.location.pathname === "/starters") {
    showNext("choose_starter", 2000);
  }
  else if (window.location.pathname === "/battle") {
    showNext("choose_opponent", 2000);
  }
  else if (window.location.pathname === "/starter") {
    showNext("battle", 50000);
  }
  else if (window.location.pathname === "/opponent") {
    showNext("first_fight", 50000);
  }
  else if (window.location.pathname === "/") {
    showNext("starters", 2000);
  }
  else {
    return false;
  }
});