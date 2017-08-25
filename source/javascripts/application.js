//= require jquery
//= require tether
//= require bootstrap-sprockets
//= require autotrack

document.getElementById('js-arrow').onclick = function() {
    var el = document.getElementById('js-box');
    var arrow = document.getElementById('js-arrow');

    el.classList.toggle('hide');
    arrow.classList.toggle('icon-chevron-right');
    el.classList.toggle('newsletter-show');
    arrow.classList.toggle('icon-chevron-left');
}
