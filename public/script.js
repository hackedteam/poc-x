$(function(){

  $('.stream').each(function(){
    var eventSource = null;
    var contentContainer = $(this);

    var filepath = contentContainer.data('path');

    if (filepath) {
      eventSource = new EventSource('/tail/'+btoa(filepath));

      contentContainer.empty();
      var preElem = $('<pre></pre>').appendTo(contentContainer);

      eventSource.onmessage = function(e) {
        preElem.append(e.data + "\n");
        contentContainer.scrollTop(preElem.height());
      };
    }
  });

  function resizeContainer() {
    $('.stream').css('height', ($(window).innerHeight() / 2 - 30) + 'px');
    $('.stream').css('width', ($(window).innerWidth() / 2 - 10) + 'px');
  };

  $(window).resize(resizeContainer);
  resizeContainer();
});
