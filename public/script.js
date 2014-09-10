$(function(){
  function attachEventSource(contentContainer) {
    var contentContainer = $(contentContainer);
    var filepath = contentContainer.data('path');
    var unique = contentContainer.data('unique');
    var titleElem = $('<kbd class="title"></kbd>').insertBefore(contentContainer).text("untitled");

    if (filepath) {
      contentContainer.empty();
      var eventSource = new EventSource('/stream/'+filepath+"?unique="+unique);
      titleElem.text(contentContainer.data('title') || filepath);
      var preElem = $('<pre></pre>').appendTo(contentContainer);

      eventSource.onmessage = function(e) {
        preElem.append(e.data + "\n");
        scrollStream(contentContainer);
      };
    }
  };

  function resize() {
    $('.stream').css('height', ($(window).innerHeight() / 2 - 60) + 'px');
    $('.stream').css('width', ($(window).innerWidth() / 2 - 30) + 'px');
  };

  function scrollStream(container) {
    var container = $(container);
    container.scrollTop(container.find('pre').height());
  };

  function onTabChanged(callback) {
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
      var selector = $(e.target).attr('href');
      callback($(selector));
    });
  };

  // On Ready

  onTabChanged(function(tab){
    tab.find('.stream').each(function(){
      scrollStream(this);
    });
  });

  $('.stream').each(function(){
    attachEventSource(this);
  });

  $(window).resize(resize);

  resize();
});
