function initAnalytics() {
  var google_conversion_id = 1005290876;
  var google_custom_params = window.google_tag_params;
  var google_remarketing_only = true;

  // drip
  var _dcq = _dcq || [];
  var _dcs = _dcs || {};
  _dcs.account = '1032548';

  (function () {
    var dc = document.createElement('script');
    dc.type = 'text/javascript'; dc.async = true;
    dc.src = '//tag.getdrip.com/1032548.js';
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(dc, s);
  })();

  // GA
  (function (i, s, o, g, r, a, m) {
  i["GoogleAnalyticsObject"] = r; i[r] = i[r] || function () {
    (i[r].q = i[r].q || []).push(arguments)
  }, i[r].l = 1 * new Date(); a = s.createElement(o),
    m = s.getElementsByTagName(o)[0]; a.async = 1; a.src = g; m.parentNode.insertBefore(a, m)
  })(window, document, "script", "//www.google-analytics.com/analytics.js", "ga");

  ga("create", "UA-11839548-2", "auto");

  ga('set', 'anonymizeIp', true);

  ga("require", "cleanUrlTracker");
  ga("require", "eventTracker");
  ga("require", "outboundFormTracker");
  ga("require", "outboundLinkTracker");

  ga("send", "pageview");

  // fb
  !function (f, b, e, v, n, t, s) {
    if (f.fbq) return; n = f.fbq = function () {
      n.callMethod ?
      n.callMethod.apply(n, arguments) : n.queue.push(arguments)
    }; if (!f._fbq) f._fbq = n;
    n.push = n; n.loaded = !0; n.version = '2.0'; n.queue = []; t = b.createElement(e); t.async = !0;
    t.src = v; s = b.getElementsByTagName(e)[0]; s.parentNode.insertBefore(t, s)
  }(window,
    document, 'script', 'https://connect.facebook.net/en_US/fbevents.js');
  fbq('init', '374754519556589'); // Insert your pixel ID here.
  fbq('track', 'PageView');

  var conversionScript = document.createElement('script');
  conversionScript.src = '//www.googleadservices.com/pagead/conversion.js'
  document.body.appendChild(conversionScript)
}
