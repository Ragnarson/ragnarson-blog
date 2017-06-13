document.addEventListener('DOMContentLoaded', function() {
  var newsletterEl = document.getElementsByClassName('newsletter-popup')[0];
  var newsletterCloseBtnEl = document.getElementById('newsletter-close-btn');
  var newsletterSubscribeBtnEl = document.getElementById('mc-embedded-subscribe');
  var joinNewsletterBtnEl = document.getElementById('js-join-newsletter');

  newsletterCloseBtnEl.addEventListener('click', function(e) {
    newsletterEl.style.display = 'none';
    document.cookie = 'seenNewsletterPopup=true';
    e.preventDefault();
  });

  newsletterSubscribeBtnEl.addEventListener('click', function(e) {
    newsletterEl.style.display = 'none';
    document.cookie = 'seenNewsletterPopup=true';
  });

  joinNewsletterBtnEl.addEventListener('click', function(e) {
    newsletterEl.style.display = 'block';
    e.preventDefault();
  });

  if(!readCookie('seenNewsletterPopup')) {
    newsletterEl.style.display = 'block';
  }
});

function readCookie(name) {
  var nameEQ = name + '=';
  var splittedCookie = document.cookie.split(';');

  for(var i = 0; i < splittedCookie.length; i++) {
    var cookie = splittedCookie[i];
    while (cookie.charAt(0) == ' ') cookie = cookie.substring(1, cookie.length);
    if(cookie.indexOf(nameEQ) == 0) return cookie.substring(nameEQ.length, cookie.length);
  }

  return null;
}
