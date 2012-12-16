$(document).ready(function() {
  $('.content').hide();
  $('.read').click (function(event) {
    event.preventDefault();
    var id = $(this).attr('id')
    $('.content').filter('#' + id).toggle();
      var url = $('.link').filter('#' + id).attr('href');
      if ($('.link').filter('#' + id).is(":visible")) {
         $.getJSON('/getbody', { link : url }, function(response) {
            var body = response.content;
            console.log(body);
            $('.content').filter('#' + id).append(body);
         });
      }
    });
});
