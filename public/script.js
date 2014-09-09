$(function(){
  function attachEventSource(contentContainer) {
    var contentContainer = $(contentContainer);
    var filepath = contentContainer.data('path');

    if (filepath) {
      var eventSource = new EventSource('/tail/'+btoa(filepath));
      var title = contentContainer.data('title') || filepath;

      contentContainer.empty();
      $('<kbd class="title"></kbd>').appendTo(contentContainer).text(title);
      var preElem = $('<pre></pre>').appendTo(contentContainer);

      eventSource.onmessage = function(e) {
        preElem.append(e.data + "\n");
        contentContainer.scrollTop(preElem.height());
      };
    }
  };

  function resize() {
    $('.stream').css('height', ($(window).innerHeight() / 2 - 40) + 'px');
    $('.stream').css('width', ($(window).innerWidth() / 2 - 30) + 'px');
  };


  // On Ready

  $('.stream').each(function(){
    attachEventSource(this);
  });

  $(window).resize(resize);

  resize();
});
