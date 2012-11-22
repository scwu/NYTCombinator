$(document).ready(function() {
 $('.content').hide();
  $('.read').click (function(event) {
    event.preventDefault();
    var id = $(this).attr('id')
    $('.content').filter('#' + id).toggle(function() {
    });
  });
});
