$(function(){
  function initTailWindows(){
    $('.stream').each(function(){
      var container = $(this);
      var params = container.data();

      $('<kbd></kbd>')
        .insertBefore(container)
        .addClass('title')
        .text(params['title'] || params['name'] || "untitled");

      container.data('autoscroll', true);

      container.scroll(function(e){
        var offset = container.find('pre').height() - container.innerHeight();
        var scrollTop = $(this).scrollTop();

        if (scrollTop < offset) {
          container.addClass('no-autoscroll');
          container.data('autoscroll', false);
        } else {
          container.removeClass('no-autoscroll');
          container.data('autoscroll', true);
        }

      });
      container.empty().append('<pre></pre>');
    });

    onTabChanged(function(tab){
      tab.find('.stream').each(function(){
        scrollTailWindow(this);
      });
    });

    $(window).resize(resizeTailWindows);
  };

  function scrollTailWindow(container) {
    var container = $(container);
    container.scrollTop(container.find('pre').height());
  };

  function resizeTailWindows() {
    $('.stream').each(function(){
      var container = $(this);
      var h = $(window).innerHeight() / 2 - 60;
      var colspan = container.parent().attr('colspan');
      var w = $(window).innerWidth() / (2 / (colspan || 1)) - 30;
      container.css({height: h+'px', width: w+'px'});
    });
  };

  function initTailSource() {
    var params = [];

    $('.stream').each(function(){
      if ($(this).data('name')) {
        params.push($(this).data());
      }
    });

    var eventSource = new EventSource('/stream?files='+JSON.stringify(params));

    eventSource.addEventListener('tail', function(e) {
      var data = JSON.parse(e.data);
      var container = $('.stream[data-name="'+data.filename+'"]');
      container.find('pre').append(data.line+"\n");

      if (container.data('autoscroll'))
        scrollTailWindow(container);

    }, false);
  };

  function onTabChanged(callback) {
    $('a[data-toggle="tab"]').on('shown.bs.tab', function (e) {
      var selector = $(e.target).attr('href');
      callback($(selector));
    });
  };

  function callService(name, action, container) {
    $.ajax({
      url: '/service/'+name+'/'+action,
      success: function(data){
        if (action != 'status') return;

        var data = JSON.parse(data);

        container.removeClass('alert-warning');
        container.removeClass('alert-danger');
        container.removeClass('alert-info');
        container.addClass('alert-'+(data.status == 0 ? 'info' : 'danger'));
        container.find('h4 > small').text(data.status == 0 ? 'Active' : 'Stopped');
      },
      error: function(jqXHR, textStatus, errorThrown) {
        container.addClass('alert-warning');
        container.removeClass('alert-danger');
        container.removeClass('alert-info');
        container.find('h4 > small').text('Unknown status');
      }
    });
  };

  function initServices() {
    $('.service').each(function(){
      var container = $(this);
      var name = container.data('name');

      $(this).find('.btn-start').click(function(){
        callService(name, 'start', container);
      });

      $(this).find('.btn-stop').click(function(){
        callService(name, 'stop', container);
      });

      setInterval(function(){
        callService(name, 'status', container);
      }, 1500);
    });
  };

  // main

  initTailWindows();
  initTailSource();
  resizeTailWindows();
  initServices();
});
