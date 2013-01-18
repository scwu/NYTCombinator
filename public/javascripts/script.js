// display the lightbox
function lightbox(insertContent, link){

  // add lightbox/shadow <div/>'s if not previously added
  if($('#lightbox').size() == 0){
    var theLightbox = $('<div id="lightbox"/>');
    var theShadow = $('<div id="lightbox-shadow"/>');
    $(theShadow).click(function(e){
      closeLightbox();
    });
    $('body').append(theShadow);
    $('#lightbox-shadow').height($(document).height());
    $('body').append(theLightbox);
  }

  // remove any previously added content
  $('#lightbox').empty();

  // insert HTML content
  if(insertContent != null){
    $('#lightbox').append(insertContent);
  }

  // insert AJAX content
  if(link != null){
    // temporarily add a "Loading..." message in the lightbox
    $('#lightbox').append('<p class="loading">Loading...</p>');

    // request AJAX content
    $.getJSON('/getbody', { link : link }, function(response) {
            var body = response.content;
            $('#lightbox').empty();
            $('#lightbox').append(body);
    });
  }

  // move the lightbox to the current window top + 100px
  $('#lightbox').css('top', $(window).scrollTop() + 100 + 'px');

  // display the lightbox
  $('#lightbox').show();
  $('#lightbox-shadow').show();

}

// close the lightbox
function closeLightbox(){

  // hide lightbox and shadow <div/>'s
  $('#lightbox').hide();
  $('#lightbox-shadow').hide();

  // remove contents of lightbox in case a video or other content is actively playing
  $('#lightbox').empty();
}

$(document).ready(function() {
  $('.read').click (function(event) {
    event.preventDefault();
    var id = $(this).attr('id');
    var url = $('.link').filter('#' + id).attr('href');
    $.getJSON('/getbody', { link : url }, function(response) {
          var body = response.content;
    lightbox(null, url);
    });
  });
});
